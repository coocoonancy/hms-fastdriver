import { promptAction, router } from '@kit.ArkUI'
import {
  CommonRouterParams,
  HmNavBar,
  HmToggleCard,
  HmUpload,
  ImageList,
  UploadFile,
  HmLoading,
  HmSkeleton
} from '@hms/basic/Index'
import {
  DeliverParamsTypeModel,
  ExceptionList,
  PickUpParamsModel,
  TaskDetailInfo,
  TaskDetailInfoModel,
  TaskTypeEnum
} from '../../models'
import { deliver, getTaskDetail, pickUp } from '../../api'
import { common } from '@kit.AbilityKit'
import { call } from '@kit.TelephonyKit'


@Entry
@Component
struct TaskDetail {
  // 详情数据
  @State
  taskDetailData: TaskDetailInfoModel = new TaskDetailInfoModel({} as TaskDetailInfo)
  scroller: Scroller = new Scroller()
  loading: CustomDialogController = new CustomDialogController({
    builder: HmLoading(),
    customStyle: true
  })

  aboutToAppear(): void {
    const params = router.getParams() as CommonRouterParams
    if (params && params.id) {
      this.getTaskDetail(params.id)
    }
  }

  onPageShow(): void {
    const params = router.getParams() as CommonRouterParams
    if (params && params.addExcept) {
      this.updateException()
    }
  }

  async updateException() {
    this.taskDetailData.exceptionList = (await getTaskDetail(this.taskDetailData.id))?.exceptionList ?? []
  }

  async getTaskDetail(id: string) {
    this.loading.open()
    this.taskDetailData = await getTaskDetail(id)
    this.loading.close()
  }

  @Builder
  getBaseContentItem(item: BaseBuilderClass) {
    Row() {
      Text(item.title).fontSize(14).fontColor($r('app.color.text_secondary'))
        .lineHeight(20)
      Row() {
        Text(item.value).fontSize(14).fontColor($r('app.color.text_secondary'))
        if (item.icon) {
          Image(item.icon).width(24).height(24).onClick(() => {
            item.iconClick && item.iconClick()
          })
        }
      }
    }.justifyContent(FlexAlign.SpaceBetween).width('100%').margin({
      top: 14
    })
  }

  // 获取基础信息
  @Builder
  getBaseContent() {
    Row() {
      Column() {
        Row() {
          Text("起").baseTextOneStyle()
          Text(this.taskDetailData.startAddress).baseTextTwoStyle()
        }.margin({ top: 21 })

        Row() {
          Text("止").baseTextOneStyle().backgroundColor($r('app.color.primary'))
          Text(this.taskDetailData.endAddress).baseTextTwoStyle()
        }.margin({ top: 14.5 })
      }.alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({
        right: 20
      })

      // 在途情况下 才显示导航
      if (this.taskDetailData.status === TaskTypeEnum.Line) {
        Column() {
          Image($r("app.media.ic_navigation")).width(22).height(22)
          Text("开始导航").fontSize(14).margin({ top: 10, bottom: 10 })
        }.justifyContent(FlexAlign.SpaceBetween)
        .margin({
          top: 20
        })
      }

    }.justifyContent(FlexAlign.SpaceBetween).alignItems(VerticalAlign.Center).width('100%')

    Divider().vertical(false).height(2).color($r('app.color.background_divider')).margin({ left: 8, right: 8, top: 21 })
    this.getBaseContentItem({
      title: '任务编号',
      value: this.taskDetailData.transportTaskId
    })

    this.getBaseContentItem({
      title: '联系人',
      value: this.taskDetailData.startHandoverName
    })
    this.getBaseContentItem({
      title: '联系电话',
      value: this.taskDetailData.startHandoverPhone,
      icon: $r('app.media.ic_phone'),
      iconClick: () => {
        call.makeCall(this.taskDetailData.startHandoverPhone)
      }
    })
    this.getBaseContentItem({
      title: '提货时间',
      value: this.taskDetailData.planDepartureTime
    })
    this.getBaseContentItem({
      title: '预计送达时间',
      value: this.taskDetailData.planArrivalTime
    })

  }

  // 司机信息
  @Builder
  getDriverContent() {
    Row() {
      Text("车牌号").fontSize(14).fontColor($r('app.color.text_secondary'))
        .lineHeight(20)
      Text(this.taskDetailData.licensePlate).fontSize(14).fontColor($r('app.color.text_secondary'))
    }.justifyContent(FlexAlign.SpaceBetween).width('100%').margin({
      top: 14
    })

    Row() {
      Text(`司机姓名`).fontSize(14).fontColor($r('app.color.text_secondary'))
        .lineHeight(20)
      Text(this.taskDetailData.driverName).fontSize(14).fontColor($r('app.color.text_secondary'))
    }.justifyContent(FlexAlign.SpaceBetween).width('100%').margin({
      top: 14
    })
  }

  // 运输路线
  @Builder
  getTransLineContent() {
    Row() {
      Column() {
        Text(this.taskDetailData.startProvince)
          .fontSize(16)
          .fontColor($r('app.color.text_primary'))
          .lineHeight(22)
          .fontWeight(600)
        Text(this.taskDetailData.startCity).fontSize(14).lineHeight(22)
      }.width(50)

      Image($r("app.media.ic_right_arrow")).width(36).height(16)
      Column() {
        Text(this.taskDetailData.endProvince)
          .fontSize(16)
          .fontColor($r('app.color.text_primary'))
          .lineHeight(22)
          .fontWeight(600)
        Text(this.taskDetailData.endCity).fontSize(14).lineHeight(22)
      }.width(50)
    }.justifyContent(FlexAlign.SpaceBetween).alignItems(VerticalAlign.Center).width('100%').padding({
      left: 60,
      right: 60
    })
  }

  // 获取异常信息
  @Builder
  getExceptionContent() {
    ForEach(this.taskDetailData.exceptionList, (item: ExceptionList) => {
      Row() {
        Column() {
          Row() {
            Text("上报时间").fontSize(14).fontColor($r('app.color.text_primary'))
            Text(item.exceptionTime).margin({ left: 20 }).fontColor($r('app.color.text_secondary'))
          }.height(50).alignItems(VerticalAlign.Center).width('100%')

          Row() {
            Text("异常类型").fontSize(14).fontColor($r('app.color.text_primary'))
            Text(item.exceptionType).margin({ left: 20 }).fontColor($r('app.color.text_secondary'))
          }.height(50).alignItems(VerticalAlign.Center).width('100%')

          Row() {
            Text("处理结果").fontSize(14).fontColor($r('app.color.text_primary'))
            Text("继续运输").margin({ left: 20 }).fontColor($r('app.color.text_secondary'))
          }.height(50).alignItems(VerticalAlign.Center).width('100%')
        }

        // 跳转到详情
        Image($r("app.media.ic_btn_more")).width(24).height(24)
      }
      .width('100%')
      .padding({ left: 15, right: 15 })
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.SpaceBetween)
      .onClick(() => {
        router.pushUrl({
          url: 'pages/ExceptionReport/ExceptDetail',
          params: {
            formData: item
          }
        })
      })

    })
  }

  // 提货信息
  @Builder
  getPickUpContent() {
    // @Link修饰符 修饰只能是一层数据
    HmUpload({
      title: '请拍照上传回单凭证',
      canUpload: this.taskDetailData.status === TaskTypeEnum.Waiting,
      imgList: this.taskDetailData.cargoPickUpPictureList || [], // 父组件给子组件传
      onListChange: (list: ImageList[]) => {
        this.taskDetailData.cargoPickUpPictureList = list // 子组件给父组件传
      }
    })
    HmUpload({
      title: '请拍照上传货品照片',
      canUpload: this.taskDetailData.status === TaskTypeEnum.Waiting,
      imgList: this.taskDetailData.cargoPictureList || [],
      onListChange: (list: ImageList[]) => {
        this.taskDetailData.cargoPictureList = list
      }
    })
  }

  // 专门负责交货信息的结构
  @Builder
  getDeliverContent() {
    HmUpload({
      title: '请拍照上传交货货品凭证',
      canUpload: this.taskDetailData.status === TaskTypeEnum.Line,
      imgList: this.taskDetailData.deliverPictureList || [],
      onListChange: (list: ImageList[]) => {
        this.taskDetailData.deliverPictureList = list
      }
    })
    HmUpload({
      title: '请拍照上传交货货品照片',
      canUpload: this.taskDetailData.status === TaskTypeEnum.Line,
      imgList: this.taskDetailData.certificatePictureList || [],
      onListChange: (list: ImageList[]) => {
        this.taskDetailData.certificatePictureList = list
      }
    })
  }

  @Builder
  getBottomBtn() {
    //已完成不显示任何按钮
    Row() {
      if (this.taskDetailData.status === TaskTypeEnum.Waiting) {
        Button("延迟收货", { type: ButtonType.Capsule })
          .backgroundColor($r('app.color.btn_gray'))
          .fontColor($r('app.color.text_primary'))
          .fontSize(16)
          .height(50)
          .width(125)
          .onClick(() => {
            router.pushUrl({
              url: 'pages/Delay/Delay',
              params: {
                id: this.taskDetailData.id,
                oldTime: this.taskDetailData.planDepartureTime // 计划时间
              }
            })
          })
        Button("提货", { type: ButtonType.Capsule })
          .backgroundColor($r('app.color.primary'))
          .fontColor($r('app.color.white'))
          .height(50)
          .flexGrow(1)
          .margin({ left: 13 })
          .enabled(this.getPickUpState())
          .onClick(() => {
            this.btnPickUp()
          })
      }
      else if (this.taskDetailData.status === TaskTypeEnum.Line) {
        Button("上报异常", { type: ButtonType.Capsule })
          .backgroundColor($r('app.color.btn_gray'))
          .fontColor($r('app.color.text_primary'))
          .fontSize(16)
          .height(50)
          .width(125)
          .onClick(() => {
            router.pushUrl({
              url: 'pages/ExceptionReport/ExceptionReport',
              params: {
                id: this.taskDetailData.transportTaskId // id并不是订单的id 而是transportTaskId
              }
            })
          })
        Button("交货", { type: ButtonType.Capsule })
          .backgroundColor($r('app.color.primary'))
          .fontColor($r('app.color.white'))
          .height(50)
          .flexGrow(1)
          .enabled(this.getDeliverState())
          .margin({ left: 13 })
          .onClick(() => {
            this.btnDeliver()
          })

      } else if (this.taskDetailData.status === TaskTypeEnum.Delivered) {
        Row() {
          // 已交付显示回车登记
          Button("回车登记", { type: ButtonType.Capsule })
            .backgroundColor($r('app.color.primary'))
            .fontColor($r('app.color.white'))
            .height(50)
            .width('80%')
            .onClick(() => {
              router.pushUrl({
                url: 'pages/CarRecord/CarRecord',
                params: {
                  id: this.taskDetailData.id
                }
              })
            })
        }.width('100%').justifyContent(FlexAlign.Center)
      }

    }
    .width('100%')
    .padding({ left: 15, right: 15 })
    .height(70)
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
    .backgroundColor($r('app.color.white'))
  }

  // 去提货
  async btnPickUp() {
    this.loading.open()
    const cargoPictureList = await UploadFile(this.taskDetailData.cargoPictureList)
    const cargoPickUpPictureList = await UploadFile(this.taskDetailData.cargoPickUpPictureList)
    await pickUp(new PickUpParamsModel({
      id: this.taskDetailData.id,
      cargoPickUpPictureList: cargoPictureList,
      cargoPictureList: cargoPickUpPictureList
    }))
    this.getTaskDetail(this.taskDetailData.id) // 重新加载数据
    this.scroller.scrollEdge(Edge.Top)
    this.loading.close()
    promptAction.showToast({ message: '提货成功' })
  }

  async btnDeliver() {
    this.loading.open()
    const certificatePictureList = await UploadFile(this.taskDetailData.certificatePictureList) // 传入提货凭证
    const deliverPictureList = await UploadFile(this.taskDetailData.deliverPictureList) // 货品照片
    // 交货操作
    await deliver(new DeliverParamsTypeModel({
      id: this.taskDetailData.id,
      certificatePictureList,
      deliverPictureList
    }))
    // 只需要重新获取数据
    // 重新获取数据
    this.getTaskDetail(this.taskDetailData.id) // 重新拉取数据

    this.scroller.scrollEdge(Edge.Top)
    this.loading.close()
    // 滚动到顶部
    promptAction.showToast({ message: '交货成功' })
  }

  // 开始导航
  async beginNav() {
    try {
      let context = getContext(this) as common.UIAbilityContext
      context.startAbility({
        action: 'ohos.want.action.viewData',
        entities: ['entity.system.browsable'],
        uri: encodeURI('https://gaode.com/search?query=' + this.taskDetailData.endAddress)
      })
    } catch (error) {
      AlertDialog.show({
        message: JSON.stringify(error)
      })
    }

  }

  // 控制提货按钮可用性
  getPickUpState() {
    // 可用 凭证有图片 货品有图片 就可以点提货
    if (this.taskDetailData.cargoPickUpPictureList?.length
      && this.taskDetailData.cargoPickUpPictureList?.every(item =>!!item.url)
      && this.taskDetailData.cargoPictureList?.length
      && this.taskDetailData.cargoPictureList?.every(item =>!!item.url)) {
      return true
    }
    return false
  }

  // 控制提货按钮可用性
  getDeliverState() {
    // 可用 凭证有图片 货品有图片 就可以点提货
    if (this.taskDetailData.deliverPictureList?.length
      && this.taskDetailData.deliverPictureList?.every(item =>!!item.url)
      && this.taskDetailData.certificatePictureList?.length
      && this.taskDetailData.certificatePictureList?.every(item =>!!item.url)) {
      return true
    }
    return false
  }

  build() {
    Column() {
      if (this.taskDetailData.id) {
        // 说明数据加载完成
        HmNavBar({ title: '任务详情' })
        // Scroll组件只能放置一个子组件
        // Scroll组件只能放置一个子组件
        Scroll(this.scroller) {
          Column() {
            HmToggleCard({ title: '基本信息' }) {
              this.getBaseContent()
            }

            HmToggleCard({ title: '车辆司机信息' }) {
              this.getDriverContent()
            }

            HmToggleCard({ title: '运输路线' }) {
              this.getTransLineContent()
            }

            // 当有异常信息时 显示异常信息
            if (this.taskDetailData.exceptionList?.length) {
              HmToggleCard({ title: '异常上报' }) {
                this.getExceptionContent()
              }
            }
            if (this.taskDetailData.status === TaskTypeEnum.Waiting
              || this.taskDetailData.status === TaskTypeEnum.Delivered
            ) {
              HmToggleCard({ title: '提货信息' }) {
                // 上传组件 基础组件
                // HmUpload -
                this.getPickUpContent()
              }
            }
            if (this.taskDetailData.status === TaskTypeEnum.Line
              || this.taskDetailData.status === TaskTypeEnum.Delivered
            ) {
              HmToggleCard({ title: '交货信息' }) {
                // 上传组件 基础组件
                // HmUpload -
                this.getDeliverContent()
              }
            }

          }
        }
        .padding({
          bottom: 50
        })
        .layoutWeight(1)

        // 它需要放在底部 不能在滚动容器中
        this.getBottomBtn()
      }
      else {
        // 显示骨架屏
        HmSkeleton({ count: 4, showAvatar: true })
      }
    }
    .width("100%")
    .height("100%")
    .backgroundColor($r("app.color.background_page"))
  }
}

@Extend(Text)
function baseTextOneStyle() {
  .fontSize(12)
  .fontColor($r('app.color.white'))
  .backgroundColor($r('app.color.text_primary'))
  .width(22)
  .height(22)
  .borderRadius(11)
  .textAlign(TextAlign.Center)
}

@Extend(Text)
function baseTextTwoStyle() {
  .margin({ left: 11.5 }).fontColor($r('app.color.text_secondary')).fontSize(14).lineHeight(20)
}

class BaseBuilderClass {
  title: string = ""
  value: string = ""
  icon?: ResourceStr = ""
  iconClick?: () => void = () => {
  }
}
