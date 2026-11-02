import DataLayer
import DomainLayer
import FactoryKit

extension Container {
    var accessRepository: Factory<any AccessRepository> {
        self {
            AccessRepositoryImpl(
                accessLocalDataSource: self.accessLocalDataSource(),
                biometricLocalDataSource: self.biometricLocalDataSource()
            )
        }
        .singleton
    }
}
