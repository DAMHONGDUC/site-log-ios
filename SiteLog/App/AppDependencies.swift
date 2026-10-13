import Core
import FactoryKit

extension Container {
    var clock: Factory<any AppClock> {
        self { SystemClock() }.singleton
    }
}
