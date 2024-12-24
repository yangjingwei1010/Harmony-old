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

/**
 * 更新用户头像
 * @param avatar
 * @returns
 */
export function updateUserAvatar(avatar: string): Promise<null> {
  return request<null>({
    url: '/employee/user/updateAvatar',
    method: 'put',
    params: {
      avatar
    }
  })
}

/**
 * 更新用户昵称
 * @param nickName
 * @returns
 */
export function updateUserNameApi(nickName: string): Promise<null> {
  return request<null>({
    url: '/employee/user/updateNickname', method: 'put', params: {
      nickName
    }
  })
}