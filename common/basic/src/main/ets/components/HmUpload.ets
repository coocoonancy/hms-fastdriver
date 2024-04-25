import { picker } from '@kit.CoreFileKit'
import { ImageList } from '../models'
import { HmPreview } from './HmPreview'
@Component
struct HmUpload {
  title: string = "" // 作为标题
  maxNumber: number = 3 // 最大选择数量
  @State
  imgList: ImageList[] = [] // 提交接口
  index: number = -1
  preview: CustomDialogController = new CustomDialogController({
    builder: HmPreview({
      urls: this.imgList.map(item => item.url),
      selectIndex: this.index
    }),
    customStyle: true
  })

  async selectImg() {
    const photo = new picker.PhotoViewPicker() // 图片选择对象
    const result = await photo.select({
      MIMEType: picker.PhotoViewMIMETypes.IMAGE_TYPE,
      maxSelectNumber: this.maxNumber - this.imgList.length // 还剩多少张可以选
    })
    if (result.photoUris.length) {
      // 追加操作
      this.imgList = this.imgList.concat(result.photoUris.map(url => ({
        url
      } as ImageList)))
    }
  }

  build() {
    Column() {
      Text(this.title)
        .fontSize(14)
        .fontColor($r("app.color.text_secondary"))
        .margin({
          top: 16,
          bottom: 16
        })
      Grid() {
        ForEach(this.imgList, (item: ImageList, index: number) => {
          GridItem() {
            Image(item.url)
              .width(100)
              .height(100)
              .borderRadius(4)
              .onClick(() => {
                this.index = index;
                this.preview.open()
              })
          }
        })
        // 显示上传 还没有达到最满情况下 可以显示 上传按钮
        if (this.imgList.length < this.maxNumber) {
          GridItem() {
            Row() {
              Image($r("app.media.ic_add_img"))
                .width(30)
                .height(30)
            }
            .justifyContent(FlexAlign.Center)
            .backgroundColor($r("app.color.background_page"))
            .width(100)
            .height(100)
            .borderRadius(4)
            .onClick(() => {
              this.selectImg()
            })
          }

        }
      }
      .height(Math.ceil(this.maxNumber / 3) * 110)
      .rowsGap(10) // 行间距
      .columnsGap(10) // 列间距
      .columnsTemplate("1fr 1fr 1fr")

    }
    .alignItems(HorizontalAlign.Start)
    .width("100%")
  }
}

export { HmUpload }