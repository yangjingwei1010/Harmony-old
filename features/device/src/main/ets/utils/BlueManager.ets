import { access } from '@kit.ConnectivityKit'
import { abilityAccessCtrl, bundleManager, common } from '@kit.AbilityKit'
import { promptAction } from '@kit.ArkUI'

class BlueManager {
  // 检查蓝牙授权
  async checkBlue() {
    try {
      // 权限的检查
      const bundleInfo =
        bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION)
      let atManager = abilityAccessCtrl.createAtManager()
      const status =
        atManager.checkAccessTokenSync(bundleInfo.appInfo.accessTokenId, "ohos.permission.ACCESS_BLUETOOTH") // 检查是否授权
      if (status === abilityAccessCtrl.GrantStatus.PERMISSION_DENIED) {
        // 要去申请蓝牙权限
        const result = await atManager.requestPermissionsFromUser(getContext(), ["ohos.permission.ACCESS_BLUETOOTH"])
        // 能否确定授权吗？？？？
        // AlertDialog.show({ message: result.authResults[0] + "" })
        if (result.authResults[0] === 0) {
          // 通过了
          if (!this.checkBlueOpen()) {
            // 应该打开蓝牙开关 检测开关是关着的
            return Promise.reject(new Error("请首先打开蓝牙开关1"))
          }
          return true // 表示检查权限成功

        } else {
          // 如果不等于0 那就是点击了禁止
          // 拉起应用系统设置页面
          let context = getContext(this) as common.UIAbilityContext;
          context.startAbility({
            bundleName: 'com.huawei.hmos.settings',
            abilityName: 'com.huawei.hmos.settings.MainAbility',
            uri: 'application_info_entry',
            parameters: {
              pushParams: 'com.yang.yanglao.pro' // 应用包名
            }
          });
          return false // 表示授权失败 跳到了设置页面
        } // 0 就是通过 -1 是不通过

      }
      // 已经有蓝牙权限
      if (!this.checkBlueOpen()) {
        // 检测开关是关着的
        promptAction.showToast({ message: JSON.stringify(access.getState()) })
        return Promise.reject(new Error("请首先打开蓝牙开关2"))
      }
      return true // 表示授权成功
    } catch (error) {
      promptAction.showToast({ message: '打开蓝牙失败' })
      return false
    }
  }

  // 检查系统的蓝牙是否打开 true/打开 false/关闭
  checkBlueOpen() {
    return access.getState() === access.BluetoothState.STATE_ON
  }
}

export const blueManager = new BlueManager()