// 导出封装的axios的实例
import { Log } from '@abner/log'
import axios, { AxiosError, AxiosResponse, InternalAxiosRequestConfig } from '@ohos/axios'

// 创建一个axios的实例
const instance = axios.create({
  baseURL: 'https://zhyl-harmony.itheima.net', // 基础地址  http://www.ithiema.net + /a/b/c/d
  timeout: 20000 // 网络请求超时时间
})

// 两个拦截器
instance.interceptors.request.use((config: InternalAxiosRequestConfig) => {
  // config就是请求的参数 地址 以及一些头信息
  // 一般在这个位置统一注入token
  Log.info("1.请求参数：" + JSON.stringify(config))
  config.headers.Authorization =
    'eyJhbGciOiJIUzI1NiJ9.eyJjdXJyZW50VXNlciI6IntcInVzZXJuYW1lXCI6XCIzNTQyMzQ4NEBxcS5jb21cIixcInBhc3N3b3JkXCI6XCJcIixcIm5pY2tOYW1lXCI6XCLmiqTnkIblkZgxXCIsXCJlbWFpbFwiOlwiMzU0MjM0ODRAcXEuY29tXCIsXCJyZWFsTmFtZVwiOlwi5oqk55CG5ZGYMVwiLFwibW9iaWxlXCI6XCIxODIxMTAyMTg5NlwiLFwic2V4XCI6XCIwXCIsXCJkZXB0Tm9cIjpcIjEwMDAwMTAwNTAwMDAwMFwiLFwicG9zdE5vXCI6XCIxMDAwMDEwMDUwMDMwMDBcIixcImRhdGFTdGF0ZVwiOlwiMFwiLFwiYXZhdGFyXCI6XCJodHRwczovL3lqeS1vc3MtdmlkZW9zLm9zcy1hY2NlbGVyYXRlLmFsaXl1bmNzLmNvbS9ncnp4aHouanBnXCIsXCJpZFwiOjE2NzE0MDMyNTY1MTkwNzgyNzUsXCJjcmVhdGVUaW1lXCI6MTcxNTU2ODM5MDAwMCxcInVwZGF0ZVRpbWVcIjoxNzE1NTY4MzkwMDAwLFwiY3JlYXRlQnlcIjoxNjcxNDAzMjU2NTE5MDc4MTM4fSIsImV4cCI6MTQ2NzU2NTk0Nzd9.8PrMKBNrVVCfcI4DgICxp6oBQGqy46m3oglFQCiKtzw'
  return config // 返回的这个参数是必须的 axios就是用我们返回的这个config发送请求
}, (error: AxiosError) => {
  // 说明失败了
  Log.error("3.异常信息：" + JSON.stringify(error))
  return Promise.reject(error)
}) // 注册请求拦截器- 看看你是不是把参数带全了 有没有必要报个错

// Promise pending  fullfilled rejected
instance.interceptors.response.use((response: AxiosResponse) => {
  // response是服务器返回给我的结果
  // axios的默认返回选项是 包了一层data的数据
  // 判断 是否执行成功
  if (response.data && response.data.code !== 200) {
    // 说明执行出现问题 要提示错误 返回promise的异常
    AlertDialog.show({ message: response.data.msg }) // 提示错误
    return Promise.reject(new Error(response.data.msg))
  }
  Log.info("2.响应结果：" + JSON.stringify(response.data))
  return response.data.data // 直接返回我们需要的数据

}, (error: AxiosError) => {
  AlertDialog.show({ message: error.message }) // 弹出错误信息
  Log.error("3.异常信息：" + JSON.stringify(error))
  return Promise.reject(error)

}) // 注册响应拦截器- 数据回来，有些东西是不是没有必要啊 没有必要 就脱掉 去掉 删掉

export { instance }