#if DEBUG

    import DomainLayer
    import Observation

    @MainActor @Observable
    final class DevMenuViewModel {
        @ObservationIgnored private let resetAllAccessData: ResetAllAccessDataUseCase
        @ObservationIgnored private let seedAccessData: SeedAccessDataUseCase

        init(resetAllAccessData: ResetAllAccessDataUseCase, seedAccessData: SeedAccessDataUseCase) {
            self.resetAllAccessData = resetAllAccessData
            self.seedAccessData = seedAccessData
        }

        // Each feature adds its seed use case here
        func seedData() async {
            await seedAccessData.execute()
        }

        // Each feature adds its reset use case here
        func deleteAllData() async {
            await resetAllAccessData.execute()
        }
    }

#endif
