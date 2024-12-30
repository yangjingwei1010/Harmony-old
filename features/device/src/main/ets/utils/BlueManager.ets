import { access, ble, constant } from '@kit.ConnectivityKit'
import { abilityAccessCtrl, bundleManager, common } from '@kit.AbilityKit'
import { promptAction } from '@kit.ArkUI'
import { Log } from '@abner/log'
import { BusinessError, emitter } from '@kit.BasicServicesKit'
import { BlueData } from '../viewmodel'
import { util } from '@kit.ArkTS'

class BlueManager {
  timer: number = -1
  currentClient: ble.GattClientDevice | null = null

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
      // todo: 模拟蓝牙已经授权成功并且蓝牙开关已经打开
      if (this.checkBlueOpen()) {
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

  // 扫描蓝牙
  scanDevice(callback: (res: ble.ScanResult[]) => void) {
    try {
      clearTimeout(this.timer) // 清除上一次的 重新开始
      // 当找到蓝牙时会触发
      const resList: ble.ScanResult[] = [] // 汇总所有的发现蓝牙
      ble.on("BLEDeviceFind", (list: ble.ScanResult[]) => {
        Log.info("扫描到的蓝牙列表：" + JSON.stringify(list))
        // [1,2,3] [2]
        resList.push(...list.filter(dv =>!resList.some(item => item.deviceId === dv.deviceId)))
        // 告诉页面
        callback(resList) // 回传汇总的数据
      });
      let scanOptions: ble.ScanOptions = {
        interval: 500,
        dutyMode: ble.ScanDuty.SCAN_MODE_LOW_POWER,
        matchMode: ble.MatchMode.MATCH_MODE_AGGRESSIVE
      }
      ble.startBLEScan(null, scanOptions);
      this.timer = setTimeout(() => {
        ble.stopBLEScan() // 停止扫描
        ble.off("BLEDeviceFind") // 停止监听该事件
      }, 5000)
    } catch (err) {
      Log.error('errCode: ' + (err as BusinessError).code + ', errMessage: ' + (err as BusinessError).message);
    }
  }

  // 连接蓝牙
  connectBlue(deviceId: string, callback: () => void) {
    if (deviceId) {
      // 创建gatt的实例对象
      this.currentClient = ble.createGattClientDevice(deviceId) // 和蓝牙通信的对象的实例
      this.currentClient.on("BLEConnectionStateChange", async (res) => {
        if (res.state === constant.ProfileConnectionState.STATE_CONNECTED) {
          callback() // 连接成功
          promptAction.showToast({ message: '蓝牙连接成功' })
          this.currentClient?.on('BLECharacteristicChange', (res) => {
            const td = util.TextDecoder.create()
            const buffer = new Uint8Array(res.characteristicValue)
            const result = JSON.parse(td.decodeWithStream(buffer)) as BlueData
            if (result.command === 'wifi') {
              emitter.emit('WifiConnect', {
                data: {
                  status: result.status
                }
              })
            }
          })
          const serviceList = await this.currentClient?.getServices() // 获取所有服务
          const ser = serviceList?.find(item => item.serviceUuid.startsWith('0000AE30'))
          const messageObj = ser?.characteristics.find(item => item.characteristicUuid.startsWith('0000AE04'))!
          await this.currentClient?.setCharacteristicChangeNotification(messageObj, true)
        }
      })
      this.currentClient.connect() // 连接蓝牙
    }
  }

  async sendData(data: BlueData) {
    try {
      // 发送数据
      if (this.currentClient) {
        const list = await this.currentClient?.getServices()
        const doorService = list.find(item => item.serviceUuid.startsWith("0000AE30")) // 找到门禁服务
        if (doorService) {
          // 再找门禁服务的读写特征值的对象
          const writeObj =
            doorService.characteristics.find(item => item.characteristicUuid.startsWith("0000AE10")) // 写入特征值
          if (writeObj) {
            const encoder = new util.TextEncoder() // 生成一个编码对象
            const unit8Array = encoder.encodeInto(JSON.stringify(data))
            // 有了写入特征值 就可以通过蓝牙进行通信了
            await this.currentClient.writeCharacteristicValue({
              serviceUuid: writeObj.serviceUuid,
              characteristicUuid: writeObj.characteristicUuid,
              characteristicValue: unit8Array.buffer, // 将数据转化成二进制的arrayBuffer
              descriptors: []// 要写入的数据,
            }, ble.GattWriteType.WRITE)
          }
        }
      }
    } catch (error) {
      promptAction.showToast({ message: '发送数据失败，' + error.message })
    }
  }
}

export const blueManager = new BlueManager()