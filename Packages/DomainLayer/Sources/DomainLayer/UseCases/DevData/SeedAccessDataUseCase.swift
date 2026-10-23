#if DEBUG
    // Dev menu: put sample access settings in place
    public struct SeedAccessDataUseCase {
        private let accessRepository: any AccessRepository

        public init(repository accessRepository: any AccessRepository) {
            self.accessRepository = accessRepository
        }

        public func execute() async {
            await accessRepository.seedSampleData()
        }
    }
#endif
