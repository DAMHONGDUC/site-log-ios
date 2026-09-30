-- Format-on-save for Xcode: runs swift-format's "Format File" command, then Save.
-- See docs/dev-docs/xcode-format-on-save.md for the full setup.

xcodeSave = hs.hotkey.new({"cmd"}, "s", function()
  print("xcodeSave: fired")
  local app = hs.application.frontmostApplication()
  local ok = app:selectMenuItem({"Editor", "Structure", "Format File with ‘swift-format’"})
  print("xcodeSave: format menu selected =", ok)
  hs.timer.doAfter(0.25, function()
    local okSave = app:selectMenuItem({"File", "Save"})
    print("xcodeSave: save menu selected =", okSave)
  end)
end)

-- Debug helper: press cmd+alt+d WHILE Xcode is frontmost to dump its "Editor" submenu items.
xcodeDebug = hs.hotkey.new({"cmd", "alt"}, "d", function()
  local app = hs.application.frontmostApplication()
  print("xcodeDebug: frontmost app =", app:name())
  local items = app:getMenuItems()
  for _, top in ipairs(items) do
    if top.AXTitle == "Editor" and top.AXChildren then
      for _, item in ipairs(top.AXChildren[1]) do
        if item.AXTitle == "Structure" and item.AXChildren then
          for _, sub in ipairs(item.AXChildren[1]) do
            print("xcodeDebug: Structure >", sub.AXTitle, "| enabled =", sub.AXEnabled)
          end
        end
      end
    end
  end
end)
xcodeDebug:enable()

xcodeWatcher = hs.application.watcher.new(function(name, event)
  if name ~= "Xcode" then return end
  if event == hs.application.watcher.activated then xcodeSave:enable()
  elseif event == hs.application.watcher.deactivated then xcodeSave:disable() end
end):start()
