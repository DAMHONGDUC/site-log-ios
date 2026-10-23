#if DEBUG
    // Dev menu: back to first launch for the access flow
    public struct ResetAllAccessDataUseCase {
        private let accessRepository: any AccessRepository

        public init(repository accessRepository: any AccessRepository) {
            self.accessRepository = accessRepository
        }

        public func execute() async {
            await accessRepository.resetAllData()
        }
    }
#endif
