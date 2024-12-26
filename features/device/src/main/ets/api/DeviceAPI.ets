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