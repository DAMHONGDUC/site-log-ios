#if DEBUG
    // Dev menu: back to first launch for the access flow
    public struct ResetAllAccessDataUseCase {
        private let repository: any AccessRepository

        public init(repository: any AccessRepository) {
            self.repository = repository
        }

        public func execute() async {
            await repository.resetAllData()
        }
    }
#endif
