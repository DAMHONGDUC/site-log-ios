"""Build, install, launch and attach SiteLog on the iOS simulator, for VS Code debugging.

Used two ways:
  python3 .vscode/sitelog_sim.py build      -> manual build (task "sitelog: build")
  (lldb) command script import <this file>  -> launch.json: `sitelog_build` builds into the
                                               Debug Console; `sitelog_launch` (re)builds on
                                               Restart, installs the
                                               fresh build, launches it through the simulator
                                               and attaches by the pid simctl returns, then
                                               streams that pid's AppLogger logs into the
                                               Debug Console (`sitelog_stop_logs` ends it).

Launching through `simctl` (never letting LLDB start the binary) is what keeps UIKit happy;
using the pid simctl prints (never guessing by name) is what makes Restart reliable.
"""

import glob
import json
import os
import plistlib
import pty
import shutil
import signal
import subprocess
import sys
import threading
import time

SIMULATOR_NAME = "iPhone 17 Pro Max"
SCHEME = "SiteLog"
CONFIGURATION = "Debug"
REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PROJECT = os.path.join(REPO_ROOT, "SiteLog.xcodeproj")
LOG_SUBSYSTEM = "app.dd.site.log"
INJECTION_NEXT_APP = "/Applications/InjectionNext.app"
LOG_PREDICATE = f'subsystem == "{LOG_SUBSYSTEM}"'
# Matches our `log stream` command lines (xcrun, simctl and log) for cleanup.
LOG_STREAM_SIGNATURE = f"log stream --level debug --style compact --predicate {LOG_PREDICATE}"

# The `log stream` process feeding the Debug Console; one per debug session, replaced on Restart.
_log_stream = None


def simulator_udid():
    """The booted simulator with SIMULATOR_NAME, else the one on the newest runtime (booted on demand)."""
    listing = subprocess.run(
        ["xcrun", "simctl", "list", "devices", "available", "-j"],
        capture_output=True, text=True, check=True,
    )
    matches = []
    for runtime, devices in json.loads(listing.stdout)["devices"].items():
        for device in devices:
            if device["name"] == SIMULATOR_NAME:
                matches.append((device["state"] == "Booted", runtime, device["udid"]))
    if not matches:
        raise RuntimeError(f"No simulator named '{SIMULATOR_NAME}'")
    is_booted, _, udid = max(matches)
    if not is_booted:
        subprocess.run(["xcrun", "simctl", "boot", udid], check=True)
        subprocess.run(["open", "-a", "Simulator"], check=False)
    return udid


def app_path():
    """SiteLog.app from this repo's DerivedData folder (other SiteLog-* folders belong to other checkouts)."""
    for folder in glob.glob(os.path.expanduser("~/Library/Developer/Xcode/DerivedData/SiteLog-*")):
        try:
            with open(os.path.join(folder, "info.plist"), "rb") as file:
                workspace = plistlib.load(file).get("WorkspacePath")
        except OSError:
            continue
        if workspace == PROJECT:
            path = os.path.join(folder, "Build", "Products", f"{CONFIGURATION}-iphonesimulator", f"{SCHEME}.app")
            if os.path.isdir(path):
                return path
    raise RuntimeError("SiteLog.app not built yet; run the build task first")


def bundle_id(path):
    with open(os.path.join(path, "Info.plist"), "rb") as file:
        return plistlib.load(file)["CFBundleIdentifier"]


def build(write=None):
    """Incremental simulator build into Xcode's DerivedData (shared with Xcode and buildServer.json).

    write=None: full xcbeautify output to stdout (the `build` CLI / task).
    write=fn:   Flutter-style for the Debug Console: a start line, only warnings and errors,
                then the result and duration.
    Returns xcodebuild's exit code.
    """
    udid = simulator_udid()
    command = [
        "xcodebuild", "-project", PROJECT, "-scheme", SCHEME, "-configuration", CONFIGURATION,
        "-destination", f"platform=iOS Simulator,id={udid}", "build",
    ]
    out = write or (lambda line: print(line, flush=True))
    out(f"Building {SCHEME} for {SIMULATOR_NAME}...")
    started = time.monotonic()

    xcodebuild = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    beautify = shutil.which("xcbeautify")
    if beautify:
        flags = ["--quiet", "--disable-colored-output"] if write else []
        formatter = subprocess.Popen([beautify, *flags], stdin=xcodebuild.stdout,
                                     stdout=subprocess.PIPE, text=True)
        xcodebuild.stdout.close()  # xcbeautify owns the pipe now
        for line in formatter.stdout:
            line = line.rstrip()
            if write and (not line or line in ("Build Succeeded", "Build Failed")
                          or line.startswith(("-----", "Version: "))):
                continue  # blank lines, xcbeautify's banner, and its own result line
            out(line)
        formatter.wait()
    else:
        for line in xcodebuild.stdout:
            out(line.decode(errors="replace").rstrip())
    code = xcodebuild.wait()

    seconds = time.monotonic() - started
    out(f"Build succeeded in {seconds:.1f}s" if code == 0 else f"Build failed (exit {code}) after {seconds:.1f}s")
    return code


# True right after `sitelog_build` (first F5), so `sitelog_launch` does not build twice.
_fresh_build = False


def build_command(debugger, command, result, internal_dict):
    """lldb command `sitelog_build`: build, streaming progress into the Debug Console."""
    global _fresh_build
    try:
        ensure_injection_next()  # started early so it is ready when the app connects
        if build(console_writer(debugger)) != 0:
            result.SetError("sitelog_build: build failed, see the errors above")
            return
        _fresh_build = True
    except Exception as error:
        result.SetError(f"sitelog_build failed: {error}")


def create_target(debugger, command, result, internal_dict):
    """lldb command `sitelog_target`: load SiteLog.app so breakpoints and symbols resolve."""
    try:
        debugger.HandleCommand(f'target create "{app_path()}"')
    except Exception as error:
        result.SetError(f"sitelog_target failed: {error}")


def console_writer(debugger):
    """A function that writes one line to the VS Code Debug Console, callable from any thread.

    CodeLLDB only forwards `print` made while an lldb command runs; a background thread has to
    send the line as a DebuggerMessage event itself. Outside CodeLLDB (plain lldb) it prints.
    """
    try:
        from codelldb import interface
    except ImportError:
        return lambda line: print(line, flush=True)
    debugger_id = debugger.GetID()

    def write(line):
        interface.fire_event(debugger_id, dict(type="DebuggerMessage", output=line + "\n", category="stdout"))

    return write


def start_logs(debugger, udid, pid):
    """Stream AppLogger logs (all levels) of one app process into the Debug Console.

    `log stream` buffers when it writes to a pipe, so it runs on a pseudo-terminal and every
    line arrives as soon as the app logs it. Returns once the stream is live (at most 3 s), so
    the app's first lines are not missed.
    """
    global _log_stream
    stop_logs()
    write = console_writer(debugger)
    leader, follower = pty.openpty()
    _log_stream = subprocess.Popen(
        ["xcrun", "simctl", "spawn", udid, "log", "stream", "--level", "debug", "--style", "compact",
         "--predicate", LOG_PREDICATE],
        stdout=follower, stderr=subprocess.DEVNULL, stdin=subprocess.DEVNULL,
        start_new_session=True,  # own process group, so stop_logs can end xcrun and its child
    )
    os.close(follower)
    this_app = f"[{pid}:"  # compact lines look like "SiteLog[57313:3c9d22] [subsystem:category] ..."
    ready = threading.Event()

    def forward():
        with os.fdopen(leader, "r", errors="replace") as lines:
            try:
                for line in lines:
                    line = line.rstrip()
                    if line.startswith("Filtering the log data"):
                        ready.set()  # header line: the stream is live
                    elif this_app in line:
                        write(line)
            except OSError:
                pass  # the stream was stopped
        ready.set()

    def stop_when_app_exits(stream):
        # Ends the stream once the app process is gone, whatever ended it (Stop, Restart, crash).
        while stream.poll() is None:
            if not app_is_running(pid):
                try:
                    os.killpg(stream.pid, signal.SIGTERM)
                except ProcessLookupError:
                    pass
                return
            time.sleep(1)

    threading.Thread(target=forward, daemon=True).start()
    threading.Thread(target=stop_when_app_exits, args=(_log_stream,), daemon=True).start()
    ready.wait(timeout=3)


def stop_logs(debugger=None, command=None, result=None, internal_dict=None):
    """lldb command `sitelog_stop_logs`; also runs before each new stream.

    Kills every SiteLog log stream by its command line, not by a saved handle: the handle is
    lost if the module is imported again, and one debug session runs at a time anyway.
    """
    global _log_stream
    subprocess.run(["pkill", "-f", LOG_STREAM_SIGNATURE], check=False)
    _log_stream = None
    if debugger is not None:  # the Stop button, not the call from start_logs
        stop_console()


def app_is_running(pid):
    """False once the process is gone or only a zombie is left."""
    state = subprocess.run(["ps", "-o", "stat=", "-p", str(pid)], capture_output=True, text=True).stdout.strip()
    return state != "" and not state.startswith("Z")


def ensure_injection_next():
    """Start InjectionNext.app in the background if installed and not running (hot reload)."""
    if subprocess.run(["pgrep", "-x", "InjectionNext"], capture_output=True).returncode == 0:
        return
    if os.path.isdir(INJECTION_NEXT_APP):
        subprocess.run(["open", "-g", INJECTION_NEXT_APP], check=False)


def launch_app(debugger, udid, bundle):
    """Launch the app through the simulator, stopped until a debugger attaches; return its pid.

    `--console-pty` keeps simctl connected to the app's stdout/stderr (InjectionNext's
    "🔥 Injected" lines, crash messages); they go to the Debug Console. It runs on a
    pseudo-terminal so lines arrive at once. SIMCTL_CHILD_* variables reach the app.
    """
    stop_console()
    environment = dict(os.environ, SIMCTL_CHILD_INJECTION_PROJECT_ROOT=REPO_ROOT)
    leader, follower = pty.openpty()
    subprocess.Popen(
        ["xcrun", "simctl", "launch", "--console-pty", "--wait-for-debugger", "--terminate-running-process",
         udid, bundle],
        stdout=follower, stderr=follower, stdin=subprocess.DEVNULL, env=environment,
        start_new_session=True,
    )
    os.close(follower)
    lines = os.fdopen(leader, "r", errors="replace")

    # The first line is "<bundle id>: <pid>".
    first = lines.readline().strip()
    try:
        pid = int(first.rsplit(":", 1)[1])
    except (IndexError, ValueError):
        raise RuntimeError(f"simctl launch failed: {first or 'no output'}")

    write = console_writer(debugger)

    def forward():
        with lines:
            try:
                for line in lines:
                    line = line.rstrip()
                    if line:
                        write(line)
            except OSError:
                pass  # simctl exited with the app

    threading.Thread(target=forward, daemon=True).start()
    return pid


def stop_console():
    """End an earlier `simctl launch --console-pty` (normally it exits with its app)."""
    subprocess.run(["pkill", "-f", "simctl launch --console-pty --wait-for-debugger"], check=False)


def launch_and_attach(debugger, command, result, internal_dict):
    """lldb command `sitelog_launch`: install, launch waiting for a debugger, attach by pid."""
    global _fresh_build
    try:
        # Restart: rebuild first. The first F5 already built in `sitelog_build`.
        if not _fresh_build and build(console_writer(debugger)) != 0:
            result.SetError("sitelog_launch: build failed, see the errors above")
            return
        _fresh_build = False

        udid = simulator_udid()
        path = app_path()
        bundle = bundle_id(path)

        try:
            subprocess.run(["xcrun", "simctl", "install", udid, path], check=True, timeout=90)
        except subprocess.TimeoutExpired:
            raise RuntimeError(
                "install timed out: an older SiteLog is still held by another debugger "
                "(another VS Code or Xcode session). Stop that session, then F5 again"
            )
        pid = launch_app(debugger, udid, bundle)
        print(f"SiteLog launched on {SIMULATOR_NAME}, pid {pid}")
        start_logs(debugger, udid, pid)
        debugger.HandleCommand(f"process attach --pid {pid}")
    except Exception as error:  # surface the reason in the Debug Console
        result.SetError(f"sitelog_launch failed: {error}")


def __lldb_init_module(debugger, internal_dict):
    debugger.HandleCommand(f"command script add -o -f {__name__}.build_command sitelog_build")
    debugger.HandleCommand(f"command script add -o -f {__name__}.create_target sitelog_target")
    debugger.HandleCommand(f"command script add -o -f {__name__}.launch_and_attach sitelog_launch")
    debugger.HandleCommand(f"command script add -o -f {__name__}.stop_logs sitelog_stop_logs")


if __name__ == "__main__":
    if sys.argv[1:] == ["build"]:
        sys.exit(build())
    print("usage: sitelog_sim.py build", file=sys.stderr)
    sys.exit(2)
