import { LoginParams, UserDataModel } from '../viewmodel'
import { request } from '../utils'

/**
 * 华为手机号授权登录
 * @param data
 * @returns
 */
export function loginApi(data: LoginParams): Promise<string> {
  return request<string, LoginParams>({
    url: '/employee/login',
    method: 'post',
    data
  })
}

/**
 * 获取登录用户信息
 * @returns
 */
export function getUserApi(): Promise<UserDataModel> {
  return request<UserDataModel>({ url: '/employee/user' })
}