import { loginApi, ResManager } from '@hm/basic/Index';
import { authentication } from '@kit.AccountKit';
import { util } from '@kit.ArkTS';
import { promptAction, router } from '@kit.ArkUI';
import { TokenManager } from '@hm/basic'

@Entry
@Component
struct Login {
  // 华为登录
  async login() {
    // 创建授权请求，并设置参数
    let authRequest = new authentication.HuaweiIDProvider().createAuthorizationWithHuaweiIDRequest();
    // 获取手机号需要传如下scope，传参数之前需要先申请对应scope权限,才能返回对应数据
    authRequest.scopes = ['phone'];
    // 获取code需传如下permission
    authRequest.permissions = ['serviceauthcode'];
    // 用户是否需要登录授权，该值为true且用户未登录或未授权时，会拉起用户登录或授权页面
    authRequest.forceAuthorization = true;
    // 用于防跨站点请求伪造，非空字符串即可
    authRequest.state = util.generateRandomUUID();
    try {
      let controller = new authentication.AuthenticationController(getContext(this));
      const result = await controller.executeRequest(authRequest) as authentication.AuthorizationWithHuaweiIDResponse;
      let state = result.state;
      if (state && authRequest.state != state) {
        return promptAction.showToast({ message: JSON.stringify(result) });
      }
      let authorizationWithHuaweiIDCredential = result.data!;
      let code = authorizationWithHuaweiIDCredential.authorizationCode!;
      // 开发者处理code
      const token = await loginApi({
        code,
        clientId: '6917560556799585232',
        clientSecret: '66c1d5ab285a50b8e2c5e46c36b0b4b11e3b27d0b5371afaaefe52c03fc0b50f'
      })
      await TokenManager.setUser({ token })
      promptAction.showToast({ message: '登录成功' })
      router.replaceUrl({
        url: 'pages/Index'
      })
    } catch (error) {
      promptAction.showToast({ message: error.message });

    }
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Column() {
        // app 信息
        Column() {
          Image($r("app.media.pic_login_icon"))
            .width(124)
            .height(76)
            .margin({ bottom: 20 })
          Text() {
            Span('翼康养老')
              .fontColor('#000')
              .fontSize(24)
              .fontWeight(700)
          }
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#fff')

        Button({ stateEffect: true }) {
          Row({ space: 6.5 }) {
            Image(ResManager.IC_HUAWEI)
              .width(24)
              .aspectRatio(1)
            Text('华为登录')
              .fontColor('#fff')
              .fontWeight(500)
              .fontSize(ResManager.EC_MODULE_TITLE_FS)
          }
        }
        .margin({ top: 150 })
        .width(250)
        .height(40)
        .backgroundColor(ResManager.EC_MAIN_COLOR)
        .onClick(() => {
          this.login()
        })
      }
    }
    .width('100%')
    .height('100%')
  }
}