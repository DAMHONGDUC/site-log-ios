import DataLayer
import DomainLayer
import FactoryKit

extension Container {
    var accessRepository: Factory<any AccessRepository> {
        self { AccessRepositoryImpl() }.singleton
    }
}
