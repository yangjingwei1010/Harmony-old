import { ResManager, RouterConfig } from '@hm/basic/Index'
import { promptAction, router } from '@kit.ArkUI'
import { BlueData } from '../../viewmodel'
import { blueManager } from '../../utils'
import { Log } from '@abner/log'
import { emitter } from '@kit.BasicServicesKit'

@Entry
@Component
struct ConnectNet {
  @StorageProp('topHeight')
  topHeight: number = 0
  // wifi 连接状态: true 连接中 ｜ false 未连接
  @State
  linking: boolean = false
  // 连接倒计时
  @State
  time: number = 10
  timer: number = -1
  @State
  wifiAccount: string = ''
  @State
  wifiPassword: string = ''

  run() {
    this.timer = setInterval(() => {
      if (this.time === 0) {
        return clearInterval(this.timer)
      }
      this.time--
    }, 1000)
  }

  // 开始连接网络
  async start() {
    // 开始连接状态
    this.linking = true
    // 连接设置一个10s倒计时
    this.run()
    try {
      // 组装数据
      let data: BlueData = {
        command: 'wifi',
        data: [this.wifiAccount, this.wifiPassword]
      }
      const isOk = await blueManager.sendData(data) // 发送数据
      // promptAction.showToast({ message: isOk ? "发送账号成功" : "发送账号失败" })
      // 实现通过蓝牙给门禁发送数据
    } catch (error) {
      Log.error(error)
    }
  }

  aboutToAppear() {
    emitter.on('WifiConnect', (res) => {
      router.pushUrl({
        url: RouterConfig.DEVICE_DOOR_CONNECT_TIP_URL,
        params: {
          tips: res.data?.status === 200 ? 1 : 2
        }
      })
    })
  }

  onPageShow(): void {
    const params = router.getParams() as object
    if (params && params['ssid']) {
      this.wifiAccount = params['ssid']
    }
  }

  build() {
    Navigation() {
      if (!this.linking) {
        // 未连接=》配置
        Column({ space: 5 }) {
          Text('为设备连接Wi-Fi')
            .margin({ bottom: 10 })
            .fontColor(ResManager.EC_MID_19)
            .fontSize(ResManager.EC_PAGE_TITLE_FS)
            .fontWeight(500)
          Text('1、请确保接入区络可正常使用')
            .fontColor(ResManager.EC_MID_19)
            .fontSize(ResManager.EC_NORMAL_FS)
          Text('2、清匆连接公共Wi-Fi、办公Wi-Fi等需要短信验证码或页面登录的Wi-Fi')
            .fontColor(ResManager.EC_MID_19)
            .fontSize(ResManager.EC_NORMAL_FS)
          Text('3、请勿连提名称前有“5G”的Wi-Fi')
            .fontColor(ResManager.EC_MID_19)
            .fontSize(ResManager.EC_NORMAL_FS)
        }
        .width('100%')
        .padding({ left: 20, bottom: 12, right: 20 })
        .alignItems(HorizontalAlign.Start)

        Image($r('app.media.img_wifi_demo'))
          .width(330)
          .height(196)
        // 选择 wifi 连接
        Column() {
          List() {
            ListItem() {
              Row() {
                Text(this.wifiAccount || '--')
                  .fontColor(ResManager.EC_MID_19)
                  .fontSize(ResManager.EC_MODULE_TITLE_FS)
                  .fontWeight(500)
                Row() {
                  Image($r('app.media.ic_arrow_black'))
                    .width(7)
                    .height(16)
                }
              }
              .width('100%')
              .padding({ top: 14, bottom: 14 })
              .justifyContent(FlexAlign.SpaceBetween)
              .onClick(() => {
                router.pushUrl({
                  url: RouterConfig.DEVICE_DOOR_SCAN_WIFI_URL
                })
              })
            }

            ListItem() {
              Row() {
                Text('Wi-Fi-密码')
                  .fontColor(ResManager.EC_MID_19)
                  .fontSize(ResManager.EC_MODULE_TITLE_FS)
                  .fontWeight(500)

                Row() {
                  TextInput({ placeholder: '请输入密码', text: $$this.wifiPassword })
                    .placeholderColor(ResManager.EC_MID_99)
                    .placeholderFont({ size: ResManager.EC_NORMAL_FS })
                    .backgroundColor('#fff')
                    .width(150)
                    .textAlign(TextAlign.End)
                    .padding({ right: 20 })
                    .type(InputType.Password)
                }
              }
              .width('100%')
              .padding({ top: 5, bottom: 5 })
              .justifyContent(FlexAlign.SpaceBetween)
            }
          }
          .width('100%')
          .height('auto')
          .padding({ left: 14, right: 18, })
          .divider({ strokeWidth: 1, color: ResManager.EC_MID_LINE })
        }
        .margin({
          top: ResManager.EC_CONTENT_SPACE,
          left: ResManager.EC_CONTENT_SPACE,
          right: ResManager.EC_CONTENT_SPACE
        })
        // .width('100%')
        .backgroundColor('#fff')
        .borderRadius(ResManager.EC_NORMAL_RD)

        // 下一步
        Button('下一步')
          .margin({ top: 50 })
          .width(230)
          .backgroundColor(ResManager.EC_MAIN_COLOR)
          .enabled(!!(this.wifiAccount && this.wifiPassword))
          .onClick(() => {
            this.start()
          })
      } else {
        // 连接中...
        Column({ space: 5 }) {
          Text() {
            Span('连接中，等待不超过')
            Span(this.time + '')
              .fontColor(ResManager.EC_MAIN_COLOR)
            Span('秒')
          }
          .margin({ bottom: 10 })
          .fontColor(ResManager.EC_MID_19)
          .fontSize(ResManager.EC_PAGE_TITLE_FS)
          .fontWeight(500)

        }
        .width('100%')
        .padding({ left: 20, bottom: 12, right: 20 })
        .alignItems(HorizontalAlign.Start)

        // 连接动图
        Image($r('app.media.pic_linking'))
          .width(240)
          .height(80)
          .margin({ top: 58 })
        Column() {
          Text('设备正在连接 WiFi中，连接过程大概需要1-2分钟请稍等片刻')
            .fontColor('#50A0D8')
            .fontSize(ResManager.EC_NORMAL_FS)
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ top: 40, left: 30, right: 30 })
        .padding(15)
        .backgroundColor('#E9F6FF')
        .borderRadius(5)
      }


    }
    .title('')
    .titleMode(NavigationTitleMode.Mini)
    .padding({ top: this.topHeight })
    .backgroundColor(ResManager.EC_MID_BG)
  }
}