import { Request } from '@hms/basic/Index'
// 登录接口实现
import { LoginFormModel } from '../models'

export const login = (data: LoginFormModel) => {
  return Request.post<string>("/login/account", data)
}