import { Request } from '@hms/basic/Index'
import { TaskListData, TaskListParams } from '../models'

export const getTaskList = (params: TaskListParams) => {
  return Request.get<TaskListData>("/tasks/list", params)
}