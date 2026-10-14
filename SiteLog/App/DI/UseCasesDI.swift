#if DEBUG
    import DomainLayer
    import FactoryKit

    extension Container {
        var resetAllAccessData: Factory<ResetAllAccessDataUseCase> {
            self { ResetAllAccessDataUseCase(repository: self.accessRepository()) }
        }

        var seedAccessData: Factory<SeedAccessDataUseCase> {
            self { SeedAccessDataUseCase(repository: self.accessRepository()) }
        }
    }
#endif
