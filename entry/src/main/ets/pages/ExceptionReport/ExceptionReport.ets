import {
  CommonRouterParams,
  DateFormat,
  HmCard,
  HmCardItem,
  HmNavBar,
  HmUpload,
  HmSelectCard,
  ImageList
} from '@hms/basic/Index'
import { ExceptionParamsType, ExceptionParamsTypeModel } from '../../models'
import { promptAction, router } from '@kit.ArkUI'
import { exceptionReport } from '../../api'

@Entry
@Component
struct ExceptionReport {
  maxNumber: number = 50
  exceptionList: string[] = ["发动机启用困难", "不着车，漏油", "照明失灵", "有异常响动", "排烟异常温度异常", "其他问题"]
  @State
  selectIndex: number = -1
  @State
  exceptionForm: ExceptionParamsTypeModel = new ExceptionParamsTypeModel({} as ExceptionParamsType)
  // 选择类型的弹层
  selectTypeDialog: CustomDialogController = new CustomDialogController({
    builder: HmSelectCard({
      cardContent: () => {
        // 必须调用一个builder的函数
        this.getCardContent()
      },
      confirm: () => {
        if (this.selectIndex > -1) {
          this.exceptionForm.exceptionType = this.exceptionList[this.selectIndex]
        }
        this.selectTypeDialog.close()
      }
    }),
    customStyle: true,
    alignment: DialogAlignment.Bottom
  })

  aboutToAppear() {
    const params = router.getParams() as CommonRouterParams
    if (params && params.id) {
      this.exceptionForm.transportTaskId = params.id
    }
  }

  onPageShow() {
    const params = router.getParams() as CommonRouterParams
    if (params && params.id) {
      this.exceptionForm.transportTaskId = params.id
    }
    if (params && params.location) {
      this.exceptionForm.exceptionPlace = params.location
    }
  }

  async btnReport() {
    await exceptionReport(this.exceptionForm)
    promptAction.showToast({
      message: '上报异常成功'
    })
    router.back()
  }

  getBtnEnable() {
    return !!(this.exceptionForm.exceptionDescribe &&
    this.exceptionForm.exceptionPlace &&
    this.exceptionForm.exceptionTime &&
    this.exceptionForm.exceptionType &&
    this.exceptionForm.exceptionDescribe)
  }

  @Builder
  getSingleItem(item: string, index: number, showBorder: boolean) {
    Row() {
      Text(item)
        .fontSize(14)
        .fontColor($r("app.color.text_primary"))
      Image(this.selectIndex === index ? $r("app.media.ic_check_true") : $r("app.media.ic_check_false"))
        .width(32)
        .height(32)
    }
    .onClick(() => {
      this.selectIndex = index // 赋值索引
    })
    .height(60)
    .width("100%")
    .justifyContent(FlexAlign.SpaceBetween)
    .border({
      color: $r("app.color.background_divider"),
      width: {
        bottom: showBorder ? 1 : 0
      }
    })
  }

  // 传入HmSelectCard组件
  @Builder
  getCardContent() {
    ForEach(this.exceptionList, (item: string, index: number) => {
      this.getSingleItem(item, index, index !== this.exceptionList.length - 1)
    })
  }

  build() {
    Column() {
      HmNavBar({ title: '上报异常' })
      Scroll() {
        Column() {
          HmCard() {
            HmCardItem({
              leftTitle: '异常时间',
              rightText: this.exceptionForm.exceptionTime || '请选择',
              showRightIcon: true,
              showBottomBorder: false,
              onRightClick: () => {
                DatePickerDialog.show({
                  showTime: true,
                  useMilitaryTime: true,
                  onDateAccept: (value) => {
                    this.exceptionForm.exceptionTime = DateFormat(value)
                  }
                })
              }
            })
            HmCardItem({
              leftTitle: '上报位置', rightText: '请选择', onRightClick: () => {
                router.pushUrl({
                  url: 'pages/SelectLocation/SelectLocation'
                })
              }
            })
            HmCardItem({
              leftTitle: '异常类型', rightText: this.exceptionForm.exceptionType || '请选择', onRightClick: () => {
                this.selectTypeDialog.open()
              }
            })
            HmCardItem({ leftTitle: '异常描述', rightText: '', showRightIcon: false, showBottomBorder: false })
            TextArea({
              placeholder: '请输入异常描述',
              text: this.exceptionForm.exceptionDescribe!
            })
              .height(130)
              .borderRadius(8)
              .placeholderColor($r('app.color.text_secondary'))
              .fontSize(14)
              .onChange((value) => {
                this.exceptionForm.exceptionDescribe = value
              })
              .maxLength(this.maxNumber)
            Text(`${this.exceptionForm.exceptionDescribe?.length || 0}/${this.maxNumber}`)
              .margin({
                top: -30
              })
              .textAlign(TextAlign.End)
              .width('100%')
              .padding({ right: 15 })
              .fontColor($r('app.color.text_secondary'))
            Row().height(20)

          }

          HmCard() {
            HmUpload({
              title: '上传图片(最多6张)',
              imgList: this.exceptionForm.exceptionImagesList || [],
              canUpload: true,
              onListChange: (list) => {
                this.exceptionForm.exceptionImagesList = list // 接回传回的数组 相册地址 并不是线上地址
              }
            })
            Row().height(20)
          }
        }
      }.padding({
        bottom: 80
      })
      .layoutWeight(1)


      Row() {
        Button("提交").height(50).width(207).backgroundColor(
          this.getBtnEnable() ? $r('app.color.primary') :
          $r('app.color.primary_disabled')).enabled(this.getBtnEnable())
      }
      .height(70)
      .translate({
        y: -70
      })
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .backgroundColor($r('app.color.white'))
    }
    .height('100%').backgroundColor($r('app.color.background_page'))
  }
}