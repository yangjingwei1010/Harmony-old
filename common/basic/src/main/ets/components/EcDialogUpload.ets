import picker from '@ohos.file.picker'
import cameraPicker from '@ohos.multimedia.cameraPicker';
import camera from '@ohos.multimedia.camera';
import common from '@ohos.app.ability.common';
import { BusinessError } from '@ohos.base';
import { ResManager } from '../utils/ResManager';
import { Log } from '@abner/log';
import { promptAction } from '@kit.ArkUI';

@CustomDialog
export struct EcDialogUpload {
  // 控制器
  controller: CustomDialogController
  callback: (url: string) => void = () => {

  }

  // 拍照
  async takePhoto() {
    let mContext = getContext(this) as common.Context;
    try {
      let pickerProfile: cameraPicker.PickerProfile = {
        cameraPosition: camera.CameraPosition.CAMERA_POSITION_BACK
      };
      let pickerResult: cameraPicker.PickerResult = await cameraPicker.pick(mContext,
        [cameraPicker.PickerMediaType.PHOTO, cameraPicker.PickerMediaType.VIDEO], pickerProfile);
      console.log("the pick pickerResult is:" + JSON.stringify(pickerResult));
      Log.info(pickerResult.resultUri)

    } catch (error) {
      promptAction.showToast({ message: '不支持拍照' })
      let err = error as BusinessError;
      Log.info(`the pick call failed. error code: ${err.code}`);
    }
  }

  async selectPhoto() {
    const photosSelectOptions = new picker.PhotoSelectOptions()
    photosSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE
    photosSelectOptions.maxSelectNumber = 1
    const photoViewPicker = new picker.PhotoViewPicker()
    const result = await photoViewPicker.select(photosSelectOptions)
    if (result.photoUris.length) {
      this.callback(result.photoUris[0])
    }
  }

  build() {
    Column() {
      // 选项列表
      List() {
        ListItem() {
          Text('拍照')
            .fontColor(ResManager.EC_MAIN_COLOR)
            .fontSize(ResManager.EC_MODULE_TITLE_FS)
            .fontWeight(500)
            .width('100%')
            .textAlign(TextAlign.Center)
            .padding(15)
            .onClick(() => {
              this.takePhoto()
            })
        }

        ListItem() {
          Text('从相册选择')
            .fontColor(ResManager.EC_MAIN_COLOR)
            .fontSize(ResManager.EC_MODULE_TITLE_FS)
            .fontWeight(500)
            .width('100%')
            .textAlign(TextAlign.Center)
            .padding(15)
            .onClick(() => {
              this.selectPhoto()
            })
        }

        ListItem() {
          Text('取消')
            .fontColor(ResManager.EC_MID_59)
            .fontSize(ResManager.EC_MODULE_TITLE_FS)
            .fontWeight(500)
            .width('100%')
            .textAlign(TextAlign.Center)
            .padding(15)
            .onClick(() => {
              this.controller.close()
            })
        }
      }
      .width('100%')
      .height('auto')
      .divider({ strokeWidth: 0.5, color: ResManager.EC_MID_LINE })
      .padding(ResManager.EC_CONTENT_SPACE)
      .backgroundColor('#fff')
      .borderRadius(ResManager.EC_NORMAL_RD)

    }
  }
}
