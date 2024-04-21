import { Request } from '@hms/basic/Index'
// 登录接口实现
import { LoginFormModel, UserInfoModel } from '../models'
import { UserTaskInfoModel, UserTaskInfoParams } from '../models/user_task'

export const login = (data: LoginFormModel) => {
  return Request.post<string>("/login/account", data)
}

// 获取用户信息
export const getUserInfo = () => {
  return Request.get<UserInfoModel>("/users")
}

// 获取用户任务数据
export const getUserTaskInfo = (data: UserTaskInfoParams) => {
  return Request.get<UserTaskInfoModel>("/users/taskReport", data)
}