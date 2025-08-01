import { ResManager } from "@hm/basic/Index"
import { AVPlayerClass } from '@itheima/wing-care'
import { sensor } from '@kit.SensorServiceKit'
import { bluetoothManager } from '@kit.MDMKit'
import { blueManager } from '../../utils'
import { promptAction } from '@kit.ArkUI'
import { Log } from '@abner/log'

@Entry
@Component
struct BluetoothOpen {
  @StorageProp('topHeight')
  topHeight: number = 0
  @State angle: number = 0
  timer: number = -1
  @State
  lastX: number = 0
  @State
  lastY: number = 0
  @State
  lastZ: number = 0
  @State
  isShake: boolean = false

  // 1. 摇一摇动画
  run() {
    this.timer = setInterval(() => {
      if (this.angle !== 30) {
        this.angle = 30
      } else {
        this.angle = 0
      }
      // 播放音频
      AVPlayerClass.playAudio("audio_shake.mp3")
    }, 200)
  }

  stop() {
    setTimeout(() => {
      // 关闭动画
      clearInterval(this.timer)
    }, 1000)
  }

  onSensor() {
    sensor.on(sensor.SensorId.ACCELEROMETER, (data) => {
      let range = Math.abs(data.x - this.lastX) + Math.abs(data.y - this.lastY) + Math.abs(data.z - this.lastZ)
      // range是三个方向移动的范围 超过了 50就认为摇一摇了
      if (range > 50) {
        // 此时开始摇一摇 当它停止的时候 才进行逻辑
        this.isShake = true
      }
      if (this.isShake && range < 10) {
        // 此时认为 开始了摇一摇 并且停止了摇一摇
        // 可以动画 可以声音 可以开门了
        this.isShake = false // 再次等待下一摇一摇
        this.openDoor()

      }
      this.lastX = data.x
      this.lastY = data.y
      this.lastZ = data.z
    })
  }

  async openDoor() {
    this.run()
    await blueManager.sendData({
      command: 'open'
    })
    this.stop()
    promptAction.showToast({ message: '开门成功' })
  }

  aboutToAppear(): void {
    this.onSensor()
  }

  build() {
    Navigation() {
      Column() {
        Text('摇一摇开门')
          .fontColor(ResManager.EC_MID_19)
          .fontSize(18)
          .fontWeight(600)
          .margin({ top: 94, bottom: 58 })
        Image($r('app.media.ic_lykm_yyy'))
          .width(126)
          .aspectRatio(1)
          .rotate({
            angle: this.angle
          })
          .animation({ duration: 200 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Color.White)
    }
    .title('蓝牙开门')
    .titleMode(NavigationTitleMode.Mini)
    .padding({ top: this.topHeight })
    .backgroundColor(ResManager.EC_MID_BG)
  }
}