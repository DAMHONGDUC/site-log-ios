import Core
import DataLayer
import DomainLayer
import FactoryKit

extension Container {
    var clock: Factory<any AppClock> {
        self { SystemClock() }.singleton
    }

    var accessRepository: Factory<any AccessRepository> {
        self { AccessRepositoryImpl() }.singleton
    }

    // MARK: - Dev menu (Debug only)

    #if DEBUG
        var resetAllAccessData: Factory<ResetAllAccessDataUseCase> {
            self { ResetAllAccessDataUseCase(repository: self.accessRepository()) }
        }

        var seedAccessData: Factory<SeedAccessDataUseCase> {
            self { SeedAccessDataUseCase(repository: self.accessRepository()) }
        }
    #endif
}
