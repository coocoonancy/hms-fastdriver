import { CommonRouterParams, HmNavBar, HmToggleCard } from '@hms/basic/Index';
import { TaskDetailInfo, TaskDetailInfoModel } from '../../models';
import { router } from '@kit.ArkUI';
import { getTaskDetail } from '../../api';

@Entry
@Component
struct TaskDetail {
  @State
  taskDetailData: TaskDetailInfoModel = new TaskDetailInfoModel({} as TaskDetailInfo)
  scroller: Scroller = new Scroller()

  aboutToAppear(): void {
    const params = router.getParams() as CommonRouterParams
    if (params && params.id) {
      this.getTaskDetail(params.id)
    }
  }

  async getTaskDetail(id: string) {
    this.taskDetailData = await getTaskDetail(id)
  }

  @Builder
  cardContent() {

  }

  build() {
    Column() {
      HmNavBar({ title: '任务详情' })
      Scroll(this.scroller) {
        Column() {
          HmToggleCard({ title: '基本信息' }) {
            Text(JSON.stringify(this.taskDetailData))
          }

          HmToggleCard({ title: '基本信息' }) {
            Text(JSON.stringify(this.taskDetailData))
          }

          HmToggleCard({ title: '基本信息' }) {
            Text(JSON.stringify(this.taskDetailData))
          }

          HmToggleCard({ title: '基本信息' }) {
            Text(JSON.stringify(this.taskDetailData))
          }

          HmToggleCard({ title: '基本信息' }) {
            Text(JSON.stringify(this.taskDetailData))
          }
        }.padding({
          bottom: 20
        })
        .layoutWeight(1)
      }
    }
    .backgroundColor($r('app.color.background_page'))
    .height('100%')
  }
}