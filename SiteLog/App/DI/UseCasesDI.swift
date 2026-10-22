import DomainLayer
import FactoryKit

extension Container {
    var checkPasscodeUseCase: Factory<CheckPasscodeUseCase> {
        self { CheckPasscodeUseCase(repository: self.accessRepository()) }
    }

    var loadAccessSettingUseCase: Factory<LoadAccessSettingUseCase> {
        self { LoadAccessSettingUseCase(repository: self.accessRepository()) }
    }

    var markWelcomeScreenUseCase: Factory<MarkWelcomeScreenUseCase> {
        self { MarkWelcomeScreenUseCase(repository: self.accessRepository()) }
    }

    var saveAccessSettingUseCase: Factory<SaveAccessSettingUseCase> {
        self { SaveAccessSettingUseCase(repository: self.accessRepository()) }
    }

    var setPasscodeUseCase: Factory<SetPasscodeUseCase> {
        self { SetPasscodeUseCase(repository: self.accessRepository()) }
    }

    var unlockWithBiometricsUseCase: Factory<UnlockWithBiometricsUseCase> {
        self { UnlockWithBiometricsUseCase(repository: self.accessRepository()) }
    }

    #if DEBUG
        var resetAllAccessDataUseCase: Factory<ResetAllAccessDataUseCase> {
            self { ResetAllAccessDataUseCase(repository: self.accessRepository()) }
        }

        var seedAccessDataUseCase: Factory<SeedAccessDataUseCase> {
            self { SeedAccessDataUseCase(repository: self.accessRepository()) }
        }
    #endif
}
