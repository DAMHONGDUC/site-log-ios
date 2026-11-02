import Core
import DomainLayer

public actor AccessRepositoryImpl: AccessRepository {
    private static let freeTries = 5
    private static let lockoutWait: Duration = .seconds(60)

    private let accessLocalDataSource: any AccessLocalDataSource
    private let biometricLocalDataSource: any BiometricLocalDataSource

    public init(
        accessLocalDataSource: any AccessLocalDataSource,
        biometricLocalDataSource: any BiometricLocalDataSource
    ) {
        self.accessLocalDataSource = accessLocalDataSource
        self.biometricLocalDataSource = biometricLocalDataSource
    }

    public func loadAccessSetting() async -> Result<AccessSetting, AccessError> {
        do {
            let model = try await accessLocalDataSource.loadSetting()
            let setting = AccessSettingMapper.toEntity(model: model)
            return .success(setting)
        } catch {
            AppLogger.access.error("Load access setting failed: \(error.localizedDescription)")
            return .failure(.storageUnavailable)
        }
    }

    public func saveAccessSetting(newSetting: AccessSetting) async -> Result<Void, AccessError> {
        do {
            let model = AccessSettingMapper.toModel(setting: newSetting)
            try await accessLocalDataSource.saveSetting(model: model)
            AppLogger.access.info("Access setting saved")
            return .success(())
        } catch {
            AppLogger.access.error("Save access setting failed: \(error.localizedDescription)")
            return .failure(.storageUnavailable)
        }
    }

    public func markWelcomeScreen() async -> Result<Void, AccessError> {
        do {
            var model = try await accessLocalDataSource.loadSetting()
            model.isShowWelcomeScreen = true
            try await accessLocalDataSource.saveSetting(model: model)
            AppLogger.access.info("Welcome screen marked as shown")
            return .success(())
        } catch {
            AppLogger.access.error("Mark welcome screen failed: \(error.localizedDescription)")
            return .failure(.storageUnavailable)
        }
    }

    public func checkPasscode(inputPasscode: String) async -> Result<PasscodeCheck, AccessError> {
        do {
            let isCorrect = try await accessLocalDataSource.verifyPasscode(
                inputPasscode: inputPasscode
            )

            // correct
            if isCorrect {
                try await accessLocalDataSource.saveWrongTries(count: 0)
                return .success(.correct)
            }

            // wrong
            let wrongTries = try await accessLocalDataSource.loadWrongTries() + 1
            try await accessLocalDataSource.saveWrongTries(count: wrongTries)

            let triesLeft = AccessRepositoryImpl.freeTries - wrongTries
            if triesLeft > 0 {
                AppLogger.access.info("Wrong passcode, \(triesLeft) tries left")
                return .success(.wrong(triesLeft: triesLeft))
            }

            // lockout
            AppLogger.access.info("Passcode locked out")
            return .success(.lockedOut(wait: AccessRepositoryImpl.lockoutWait))
        } catch {
            AppLogger.access.error("Check passcode failed: \(error.localizedDescription)")
            return .failure(.storageUnavailable)
        }
    }

    public func setPasscode(newPasscode: String) async -> Result<Void, AccessError> {
        do {
            try await accessLocalDataSource.savePasscode(newPasscode: newPasscode)
            try await accessLocalDataSource.saveWrongTries(count: 0)
            AppLogger.access.info("Passcode changed")
            return .success(())
        } catch {
            AppLogger.access.error("Set passcode failed: \(error.localizedDescription)")
            return .failure(.storageUnavailable)
        }
    }

    public func unlockWithBiometrics() async -> Result<Bool, AccessError> {
        do {
            let isMatched = try await biometricLocalDataSource.authenticate()
            AppLogger.access.info("Face ID matched: \(isMatched)")
            return .success(isMatched)
        } catch {
            AppLogger.access.error("Face ID failed: \(error.localizedDescription)")
            return .failure(.biometricsUnavailable)
        }
    }
}

// Dev menu only
#if DEBUG
    extension AccessRepositoryImpl {
        public func resetAllData() async {
            do {
                try await accessLocalDataSource.deleteAll()
                AppLogger.devMenu.info("Access data reset")
            } catch {
                AppLogger.devMenu.error("Reset access data failed: \(error.localizedDescription)")
            }
        }

        public func seedSampleData() async {
            do {
                var model = try await accessLocalDataSource.loadSetting()
                model.isShowWelcomeScreen = false
                try await accessLocalDataSource.saveSetting(model: model)
                AppLogger.devMenu.info("Access data seeded")
            } catch {
                AppLogger.devMenu.error("Seed access data failed: \(error.localizedDescription)")
            }
        }
    }
#endif
