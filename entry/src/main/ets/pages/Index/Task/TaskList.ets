import { HmList, HmLoading } from '@hms/basic/Index'
import { getTaskList } from '../../../api'
import { TaskInfoItem, TaskInfoItemModel, TaskListParams, TaskListParamsModel, TaskTypeEnum } from '../../../models'
import TaskItemCard from './TaskCardItem'

@Component
struct TaskList {
  @State
  reset: boolean = false
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
  loading: CustomDialogController = new CustomDialogController({
    builder: HmLoading(),
    customStyle: true
  })

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

  @Builder
  getSearchForm() {
    Column() {
      Row() {
        Search({ placeholder: '请输入任务编号' }).backgroundColor($r('app.color.background_page')).height(32)
          .onSubmit(value => {
            this.search(value)
          })
      }
      .justifyContent(FlexAlign.Center)
      .padding({ left: 15, right: 15, bottom: 5 })

      Row() {
        // 完成搜索页需要测试点击之后键盘和弹层同时弹出的情况
        Button(this.queryParams.startTime || '开始时间')
          .fontSize(14)
          .width(106)
          .height(32)
          .padding({ left: 0, right: 0 })
          .fontColor('#999')
          .backgroundColor($r('app.color.background_page'))
          .onClick(() => {
            DatePickerDialog.show({
              selected: new Date(),
              onDateAccept: (value) => {
                this.queryParams.startTime =
                  `${value.getFullYear()}-${this.addZero(value.getMonth() + 1)}-${this.addZero(value.getDate())}`
              }
            })
          })

        Text("至")
        Button(this.queryParams.endTime || '结束时间')
          .fontSize(14)
          .width(110)
          .height(32)
          .padding({ left: 0, right: 0 })
          .fontColor('#999')
          .backgroundColor($r('app.color.background_page'))
          .onClick(() => {
            DatePickerDialog.show({
              selected: new Date(),
              onDateAccept: (value) => {
                this.queryParams.endTime =
                  `${value.getFullYear()}-${this.addZero(value.getMonth() + 1)}-${this.addZero(value.getDate())}`
              }
            })
          })
        Button(this.reset ? "重置" : "筛选")
          .backgroundColor($r('app.color.primary_disabled'))
          .height(32)
          .width(60)
          .enabled(this.getSearchEnable())
          .onClick(async () => {
            if (this.reset) {
              this.queryParams.startTime = '';
              this.queryParams.endTime = '';
            }
            this.reset = !this.reset
            this.loading.open()
            this.allPage = 1;
            this.queryParams.page = 1;
            await this.getTaskList(false)
            this.loading.close()
          })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.SpaceAround)
    }
    .backgroundColor($r('app.color.white'))
    .padding(15)
    .justifyContent(FlexAlign.Center)
    .width('100%')
  }

  // 日期补零
  addZero(value: number) {
    return value.toString().padStart(2, "0")
  }

  // 控制筛选按钮可点
  getSearchEnable() {
    return !!(this.queryParams.startTime && this.queryParams.endTime)
  }

  async search(value: string) {
    this.loading.open()
    this.allPage = 1
    this.queryParams.page = 1
    if (value) {
      this.queryParams.startTime = ''
      this.queryParams.endTime = ''
      this.queryParams.transportTaskId = value
    } else {
      this.queryParams.transportTaskId = ''
    }
    await this.getTaskList(false)
    this.loading.close()
  }

  build() {
    Column() {
      if (this.queryParams.status === TaskTypeEnum.Finish) {
        this.getSearchForm()
      }
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
    }
  }
}

export default TaskList


