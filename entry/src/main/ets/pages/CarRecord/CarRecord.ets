import { CarRecordType, CarRecordTypeModel, TaskDetailInfo, TaskDetailInfoModel } from '../../models'
import { promptAction, router } from '@kit.ArkUI'
import { CommonRouterParams, HmCard, HmCardItem, HmCheckBox, HmNavBar, HmLoading, DateFormat } from '@hms/basic/Index'
import { carRecord, getTaskDetail } from '../../api'

@Entry
@Component
struct CarRecord {
  loading: CustomDialogController = new CustomDialogController({
    builder: HmLoading({ title: '回车登记中...' }),
    customStyle: true
  })
  @State
  taskDetailData: TaskDetailInfoModel = new TaskDetailInfoModel({} as TaskDetailInfo)
  @State
  carRecord: CarRecordTypeModel = new CarRecordTypeModel({} as CarRecordType)

  aboutToAppear() {
    const params = router.getParams() as CommonRouterParams
    if (params && params.id) {
      this.getTaskDetail(params.id)
    }
  }

  async getTaskDetail(id: string) {
    this.taskDetailData = await getTaskDetail(id)
  }

  // 回车登记
  async btnCarRecord() {
    if (!this.carRecord.endTime) {
      promptAction.showToast({ message: '请选择回车时间' })
      return
    }
    this.loading.open()
    // 这里的回车登记的参数 有个容易犯错的点
    // 回车登记数据的中id 来自于任务详情的中的任务运输id并非id
    this.carRecord.id = this.taskDetailData.transportTaskId
    this.carRecord.startTime = this.taskDetailData.actualDepartureTime // 实际时间

    // 提交回车的登记
    await carRecord(this.carRecord)
    this.loading.close()
    // 任务已经结束了
    router.clear() // 清空前面的跳过的栈
    promptAction.showToast({ message: '回车登记成功', duration: 3000 })
    router.replaceUrl({
      url: 'pages/Index/Index'
    })
  }

  build() {
    Column() {
      HmNavBar({ title: '回车登记' })
      Scroll() {
        Column() {
          HmCard() {
            HmCardItem({
              leftTitle: '出车时间',
              rightText: this.taskDetailData.actualDepartureTime || '请选择',
              showBottomBorder: false
            })
            HmCardItem({
              leftTitle: '回车时间',
              rightText: this.carRecord.endTime || '请选择',
              showBottomBorder: false,
              onRightClick: () => {
                DatePickerDialog.show({
                  showTime: true,
                  useMilitaryTime: true,
                  onDateAccept: (value: Date) => {
                    this.carRecord.endTime = DateFormat(value)
                  }
                })
              }
            })
          }

          HmCheckBox({
            value: false, title: '车辆违章', checkChange: (value) => {
              this.carRecord.isBreakRules = value
            }
          })
          HmCheckBox({
            value: false, title: '车辆故障', checkChange: (value) => {
              this.carRecord.isFault = value
            }
          })
          HmCheckBox({
            value: false, title: '车辆事故', checkChange: (value) => {
              this.carRecord.isAccident = value
            }
          })
        }
        .height('100%')
      }
      .layoutWeight(1)

      // 底部内容
      Row() {
        Button("交车", { type: ButtonType.Capsule })
          .backgroundColor($r('app.color.primary'))
          .width(207)
          .height(50)
          .onClick(() => {
            this.btnCarRecord()
          })
      }
      .backgroundColor($r('app.color.white'))
      .height(70)
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
    }
    .backgroundColor($r('app.color.background_page'))
    .height('100%')
  }
}