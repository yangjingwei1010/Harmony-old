// 登录：参数
export interface LoginParams {
  /**
   * 华为应用id
   */
  clientId?: null | string;

  /**
   * 华为应用秘钥
   */
  clientSecret?: null | string;

  /**
   * 华为账号授权码
   */
  code: string;
}

// 我的：登录用户
export interface UserData {
  /** 头像 */
  avatar: null | string;

  /** 用户id */
  id: string;

  /** 用户昵称 */
  nickName: string;

  /** 用户账号，即邮箱 */
  username: string;
}
export class UserDataModel implements UserData {
  avatar: null | string = null
  id: string = ''
  nickName: string = ''
  username: string = ''

  constructor(model: UserData) {
    this.avatar = model.avatar
    this.id = model.id
    this.nickName = model.nickName
    this.username = model.username
  }
}