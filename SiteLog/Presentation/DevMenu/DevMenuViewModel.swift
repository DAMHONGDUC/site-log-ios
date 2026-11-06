#if DEBUG

    import DomainLayer
    import Observation

    @MainActor @Observable
    final class DevMenuViewModel {
        @ObservationIgnored private let resetAllAccessDataUseCase: ResetAllAccessDataUseCase
        @ObservationIgnored private let seedAccessDataUseCase: SeedAccessDataUseCase

        init(
            resetAllAccessDataUseCase: ResetAllAccessDataUseCase,
            seedAccessDataUseCase: SeedAccessDataUseCase
        ) {
            self.resetAllAccessDataUseCase = resetAllAccessDataUseCase
            self.seedAccessDataUseCase = seedAccessDataUseCase
        }

        // Each feature adds its seed use case here
        func seedData() async {
            await seedAccessDataUseCase.execute()
        }

        // Each feature adds its reset use case here
        func deleteAllData() async {
            await resetAllAccessDataUseCase.execute()
        }
    }

#endif
