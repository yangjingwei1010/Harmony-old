import { request } from '@hm/basic'
import { DeviceStatusDataModel, UnBindProductItemModel } from '../viewmodel'

/**
 * iot 平台 api
 * 查询未绑定设备产品列表
 * @returns
 */
export function getUnbindDeviceListApi(): Promise<UnBindProductItemModel[]> {
  return request<UnBindProductItemModel[]>({ url: '/employee/iot/deviceTree' })
}

/**
 * 绑定设备
 * @param iotId 物联网设备id
 * @returns
 */
export function bindDeviceApi(iotId: string): Promise<null> {
  return request({ url: `/employee/iot/bindingDevice/${iotId}`, method: 'put' })
}

/**
 * 获取我的设备列表
 * @returns
 */
export function getMyDeviceListApi(): Promise<UnBindProductItemModel[]> {
  return request<UnBindProductItemModel[]>({ url: `/employee/iot/listDeviceByCurrentUser` })
}

/***
 * 解除绑定
 * **/
export function unbindDeviceApi(iotId: string): Promise<null> {
  return request({ url: `/employee/iot/unBindingDevice/${iotId}`, method: 'put' })
}

/**
 * 获取设备状态
 * @param iotId 物联网设备id
 * @returns
 */
export function getDeviceStatusApi(iotId: string): Promise<DeviceStatusDataModel> {
  return request<DeviceStatusDataModel>({ url: `/employee/iot/getDeviceStatus/${iotId}` })
}