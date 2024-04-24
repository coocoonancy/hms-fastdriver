import { Request } from '@hms/basic/Index'
import { TaskDetailInfoModel, TaskListData, TaskListParams } from '../models'

export const getTaskList = (params: TaskListParams) => {
  return Request.get<TaskListData>("/tasks/list", params)
}
export const getTaskDetail = (id: string) => {
  return Request.get<TaskDetailInfoModel>(`/tasks/details/${id}`)
}