import { request } from '@hm/basic'
import { UnBindProductItemModel } from '../viewmodel'

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