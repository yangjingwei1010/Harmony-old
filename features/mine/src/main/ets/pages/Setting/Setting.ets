import router from '@ohos.router'
import {
  EcDialogUpload,
  getUserApi,
  ResManager,
  RouterConfig,
  updateUserAvatar,
  uploadApi,
  UserData,
  UserDataModel
} from '@hm/basic/Index'
import { Log } from '@abner/log'
import { EcLoading } from '@itheima/wing-care'
import { fileIo } from '@kit.CoreFileKit'
import { FormData } from '@ohos/axios'
import { promptAction } from '@kit.ArkUI'

enum ShowType {
  NICKNAME,
  AVATAR
}

@Entry
@Component
struct Setting {
  @StorageProp('topHeight')
  topHeight: number = 0
  // 上传弹层控制
  uploadDialog: CustomDialogController = new CustomDialogController({
    // 使用自定义弹层组件
    builder: EcDialogUpload({
      callback: (url) => {
        this.user.avatar = url
        this.upload(url)
        this.uploadDialog.close()
      }
    }),
    alignment: DialogAlignment.Bottom
  })
  // 全屏 loading 弹层
  loading: CustomDialogController = new CustomDialogController({
    builder: EcLoading({ tip: '上传中...' }),
    customStyle: true,
    autoCancel: false,
    alignment: DialogAlignment.Center
  })
  @State
  user: UserDataModel = new UserDataModel({} as UserData)

  onPageShow(): void {
    // const params = router.getParams() as UserDataModel
    // if (params) {
    //   // 一定得判断 因为鸿蒙里面没有传值的情况下 params是个undefined
    //   this.user = params
    // }
    this.getUser()
  }

  async getUser() {
    this.user = await getUserApi()
  }

  async upload(url: string) {
    try {
      this.loading.open()
      if (url) {
        // 1.拷贝到沙箱 2.调用上传接口 得到上传之后的地址
        const file = fileIo.openSync(url, fileIo.OpenMode.READ_ONLY)
        // 生成一个目标文件的路径
        const destPath = getContext().cacheDir + "/" + file.name
        // interal://cache:
        fileIo.copyFileSync(file.fd, destPath) // 拷贝到沙箱
        const data = new FormData()
        // 加上file的参数
        data.append("file", `internal://cache/${file.name}`)
        const res = await uploadApi(data) // 只是传到服务器了 但是并没有更改头像
        // AlertDialog.show({ message: JSON.stringify(res) })
        // 修改头像地址
        await updateUserAvatar(res) // 修改用户头像
        promptAction.showToast({ message: '修改用户头像成功' })
        this.loading.close() // 关闭弹层
        this.getUser()
        getContext().eventHub.emit('updateUser')
      }

    } catch (e) {
      this.loading.close()
      Log.error(e)
    }
  }

  @Builder
  cellItem(title: string, type: ShowType) {
    Row() {
      Text(title)
        .fontColor(ResManager.EC_MID_19)
        .fontSize(ResManager.EC_MODULE_TITLE_FS)
        .fontWeight(500)
      Row({ space: 10 }) {
        if (type === ShowType.NICKNAME) {
          // 昵称修改
          Text(this.user.nickName || '未命名')
            .fontColor(ResManager.EC_MID_59)
            .fontSize(ResManager.EC_NORMAL_FS)
            .onClick(() => {
              router.pushUrl({
                url: RouterConfig.USER_NAME_URL,
                params: {
                  name: this.user.nickName
                }
              })
            })
        } else {
          // 上传
          Image(this.user.avatar ||
            'https://img2.baidu.com/it/u=130573784,2479509663&fm=253&fmt=auto&app=138&f=JPEG?w=500&h=534')
            .width(34)
            .aspectRatio(1)
            .borderRadius(17)
            .onClick(() => {
              this.uploadDialog.open()
            })
        }
        Image($r('app.media.ic_arrow_black'))
          .width(7)
          .height(16)
      }
    }
    .width('100%')
    .padding({ top: 14, bottom: 14 })
    .justifyContent(FlexAlign.SpaceBetween)
  }

  build() {
    Navigation() {
      Column() {
        Column() {
          List() {
            ListItem() {
              this.cellItem('头像', ShowType.AVATAR)
            }

            ListItem() {
              this.cellItem('昵称', ShowType.NICKNAME)
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
      }
      .width('100%')
      .height('100%')
      .backgroundColor(ResManager.EC_MID_BG)
    }
    .title('个人设置')
    .padding({ top: this.topHeight })
    .titleMode(NavigationTitleMode.Mini)
  }
}