import { EcDialogTips } from '@itheima/wing-care'
import router from '@ohos.router'
import { getDeviceMap, ResManager, RouterConfig } from '@hm/basic/Index'
import { util } from '@kit.ArkTS'
import { Log } from '@abner/log'
import { currentLot, DeviceItem, DeviceItemModel, UnBindProductItem, UnBindProductItemModel } from '../../viewmodel'
import { getUnbindDeviceListApi } from '../../api'
import { blueManager } from '../../utils'
import { promptAction } from '@kit.ArkUI'

@Entry
@Component
struct BindDevice {
  @StorageProp('topHeight')
  topHeight: number = 0
  // 1. 列表
  @State
  list: UnBindProductItemModel[] = []
  @State
  refreshNum: number = 0
  @State
  currentProduct: UnBindProductItemModel = new UnBindProductItemModel({} as UnBindProductItem)
  @State
  currentSelect: DeviceItemModel = new DeviceItemModel({} as DeviceItem)
  // 加载数据
  load = async () => {
    // 请求数据
    this.list = await getUnbindDeviceListApi()
  }

  // 2. 产品选择和折叠
  // 加载更多和收起
  toggle(item: UnBindProductItemModel) {
    item.isExpand = !item.isExpand
    this.refreshNum++
  }

  // 选择某个产品下设备
  /**
   *
   * @param item 当前选择产品
   * @param device 当前点击产品下的某个设备
   */
  selectDevice(item: UnBindProductItemModel, device: DeviceItemModel) {
    this.list.forEach(prod => {
      prod.deviceList.forEach(dev => {
        if (dev.isSelected) {
          dev.isSelected = false
        }
      })
    })
    device.isSelected = !device.isSelected
    this.currentSelect = device
    this.currentProduct = item
    this.refreshNum++
  }

  async bindDevice() {
    try {
      // 这里面检查蓝牙
      const isOK = await blueManager.checkBlue() // 检查蓝牙是否授权
      promptAction.showToast({ message: isOK ? '授权成功' : "授权失败" })
      if (isOK) {
        // 单利记录nodeId
        currentLot.nodeId = this.currentSelect.nodeId
        // 单利记录当前的iotId
        currentLot.iotId = this.currentSelect.iotId
        // 进行下一步的通信 扫描蓝牙
        router.pushUrl({
          url: RouterConfig.DEVICE_NEAR_URL
        })
      }
    } catch (error) {
      promptAction.showToast({ message: error.message })
    }
  }

  @Builder
  productItem(item: UnBindProductItemModel) {
    Column({ space: 18 }) {
      // 1. 产品分类
      Row() {
        Text(getDeviceMap(item.productName)?.cn || '--')
          .fontColor(ResManager.EC_MID_19)
          .fontSize(ResManager.EC_MODULE_TITLE_FS)
          .fontWeight(500)
        // 点击查看更多后显示
        if (item.isExpand) {
          Text() {
            Span('收起')
            ImageSpan($r('app.media.ic_arrow_up'))
              .width(12.8)
              .height(5.6)
              .verticalAlign(ImageSpanAlignment.CENTER)
              .margin({ bottom: 2 })
          }
          .fontColor(ResManager.EC_MAIN_COLOR)
          .fontSize(ResManager.EC_SMALL_FS)
          .onClick(() => {
            this.toggle(item)
          })
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      //  2. 设备列表
      GridRow({ columns: 2, gutter: 10 }) {
        // 数据超出 6 同时没有点击查看更多
        if (item.deviceList?.length! > 6 && !item.isExpand) {
          ForEach(item.deviceList?.slice(0, 6), (device: DeviceItemModel, i: number) => {
            GridCol() {
              // Column() {
              if (i < 5) {
                Column() {
                  // 选择设备
                  Text(device.deviceName)
                    .fontColor(device.isSelected ? '#fff' : ResManager.EC_MID_19)
                    .fontSize(ResManager.EC_SMALL_FS)
                }
                .width('100%')
                .padding({
                  left: 15,
                  right: 15,
                  top: 10,
                  bottom: 10
                })
                .borderRadius(ResManager.EC_NORMAL_RD)
                .backgroundColor(device.isSelected && i < 5 ? ResManager.EC_MAIN_COLOR : '#fff')
                .onClick(() => {
                  this.selectDevice(item, device)
                })
              } else {
                Column() {
                  // 数据超出 6条 显示
                  Text() {
                    Span('查看更多')
                    ImageSpan($r('app.media.ic_arrow_down'))
                      .width(12.8)
                      .height(5.6)
                      .verticalAlign(ImageSpanAlignment.CENTER)
                      .margin({ bottom: 2 })
                  }
                  .fontColor(ResManager.EC_MAIN_COLOR)
                  .fontSize(ResManager.EC_SMALL_FS)
                  .onClick(() => {
                    this.toggle(item)
                  })
                }
                .width('100%')
                .padding({
                  left: 15,
                  right: 15,
                  top: 10,
                  bottom: 10
                })
                .borderRadius(ResManager.EC_NORMAL_RD)
                .backgroundColor(device.isSelected && i < 5 ? ResManager.EC_MAIN_COLOR : '#fff')
                .onClick(() => {
                  this.toggle(item)
                })
              }
            }
          }
          )
        } else {
          ForEach(item.deviceList, (device: DeviceItemModel) => {
            GridCol() {
              Column() {
                Text(device.deviceName)
                  .fontColor(device.isSelected ? '#fff' : ResManager.EC_MID_19)
                  .fontSize(ResManager.EC_SMALL_FS)
              }
              .width('100%')
              .padding({
                left: 15,
                right: 15,
                top: 10,
                bottom: 10
              })
              .borderRadius(ResManager.EC_NORMAL_RD)
              .backgroundColor(device.isSelected ? ResManager.EC_MAIN_COLOR : '#fff')
              .onClick(() => {
                this.selectDevice(item, device)
              })
            }
          }
          )
        }

      }

    }
    .width('100%')

  }

  aboutToAppear() {
    this.load()
  }

  build() {
    Navigation() {
      Stack({ alignContent: Alignment.Bottom }) {
        // 产品列表
        Column() {
          List({
            space: 10
          }) {
            ForEach(this.list, (item: UnBindProductItemModel) => {
              ListItem() {
                this.productItem(item)
              }
            }, (item: UnBindProductItemModel) => `${JSON.stringify(item)}_${this.refreshNum}`
            )
          }
          .width('100%')
          .height('100%')
          .scrollBar(BarState.Off)
        }
        .margin({ top: 18 })
        .padding({ bottom: 72, left: 15, right: 15 })

        // 确认选择
        Column() {
          Button('确认')
            .width(312)
            .backgroundColor(ResManager.EC_MAIN_COLOR)
            .onClick(() => {
              // 检查蓝牙是否授权
              this.bindDevice()
              // router.pushUrl({
              //   url: 'pages/device/NearDevicePage'
              // })
            })
            .enabled(!!this.currentSelect.iotId)
        }
        .justifyContent(FlexAlign.Center)
        .width('100%')
        .height(72)
        .backgroundColor('#fff')
        .shadow({
          offsetX: 0,
          offsetY: -2,
          radius: 60,
          color: '#0F000000'
        })

      }
    }
    .title('设备绑定')
    .titleMode(NavigationTitleMode.Mini)
    .padding({ top: this.topHeight })
    .backgroundColor(ResManager.EC_MID_BG)
  }
}