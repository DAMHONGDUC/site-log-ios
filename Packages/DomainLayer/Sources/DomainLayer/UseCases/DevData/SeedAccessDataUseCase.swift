#if DEBUG
    // Dev menu: put sample access settings in place
    public struct SeedAccessDataUseCase {
        private let repository: any AccessRepository

        public init(repository: any AccessRepository) {
            self.repository = repository
        }

        public func execute() async {
            await repository.seedSampleData()
        }
    }
#endif
