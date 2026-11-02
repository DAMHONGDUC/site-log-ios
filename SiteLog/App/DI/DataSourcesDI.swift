import DataLayer
import FactoryKit

extension Container {
    var accessLocalDataSource: Factory<any AccessLocalDataSource> {
        self { AccessLocalDataSourceImpl() }.singleton
    }

    var biometricLocalDataSource: Factory<any BiometricLocalDataSource> {
        self { BiometricLocalDataSourceImpl() }.singleton
    }
}
