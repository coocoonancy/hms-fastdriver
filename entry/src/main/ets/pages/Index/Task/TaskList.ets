import { HmList } from '@hms/basic/Index'
import { getTaskList } from '../../../api'
import { TaskInfoItem, TaskInfoItemModel, TaskListParams, TaskListParamsModel, TaskTypeEnum } from '../../../models'
import TaskItemCard from './TaskCardItem'

@Component
struct TaskList {
  @State
  queryParams: TaskListParamsModel = new TaskListParamsModel({
    status: TaskTypeEnum.Waiting,
    page: 1,
    pageSize: 5,

  } as TaskListParams)
  @State
  taskListData: TaskInfoItem[] = []
  @State
  allPage: number = 1 // 默认只有一页

  aboutToAppear() {
    // onLoad会触发
    // this.getTaskList()
  }

  async getTaskList(append: boolean) {
    const result = await getTaskList(this.queryParams)
    if (append) {
      this.taskListData = [...this.taskListData, ...(result.items || [])]
    } else {
      this.taskListData = result.items
    }
    this.allPage = result.pages
    this.queryParams.page++
  }

  async onRefresh() {
    this.queryParams.page = 1;
    await this.getTaskList(false)
  }

  @Builder
  renderItem(item: object) {
    TaskItemCard({ taskItemData: item as TaskInfoItemModel })
  }

  build() {
    HmList({
      dataSource: this.taskListData,
      finished: this.allPage < this.queryParams.page,
      renderItem: (item: object) => {
        this.renderItem(item)
      },
      onLoad: async () => {
        await this.getTaskList(true)
      },
      onRefresh: async () => {
        await this.onRefresh()
      },
    })
      .height('100%')
    // List() {
    //   ForEach(this.taskListData, (item: TaskInfoItemModel) => {
    //     ListItem() {
    //       TaskItemCard({ taskItemData: item })
    //     }
    //   })
    // }
  }
}

export default TaskList