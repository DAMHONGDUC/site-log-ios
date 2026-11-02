import DomainLayer

enum AccessSettingMapper {
    static func toEntity(model: AccessSettingModel) -> AccessSetting {
        let setting = AccessSetting(
            isShowWelcomeScreen: model.isShowWelcomeScreen,
            isLockOn: model.isLockOn,
            isFaceIdOn: model.isFaceIdOn,
            lockAfterTime: .seconds(model.lockAfterSeconds)
        )
        return setting
    }

    static func toModel(setting: AccessSetting) -> AccessSettingModel {
        let seconds = Int(setting.lockAfterTime.components.seconds)
        let model = AccessSettingModel(
            isShowWelcomeScreen: setting.isShowWelcomeScreen,
            isLockOn: setting.isLockOn,
            isFaceIdOn: setting.isFaceIdOn,
            lockAfterSeconds: seconds
        )
        return model
    }
}
