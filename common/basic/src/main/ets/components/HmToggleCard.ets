@Component
struct HmToggleCard {
  title: string = ''
  @State
  toggleState: boolean = false
  // 尾随闭包
  @BuilderParam
  CardContent: () => void

  build() {
    Column() {
      Column() {
        Row() {
          Text(this.title)
            .fontSize(16)
            .fontColor($r("app.color.text_primary"))
            .fontWeight(500)
          Image(this.toggleState ? $r("app.media.ic_btn_cut") : $r("app.media.ic_btn_add"))
            .width(24)
            .aspectRatio(1)
            .onClick(() => {
              animateTo({ duration: 300 }, () => {
                this.toggleState = !this.toggleState
              })

            })
        }
        .width("100%")
        .height(50)
        .justifyContent(FlexAlign.SpaceBetween)

        if (this.toggleState && this.CardContent) {
          this.CardContent()
        }
      }
      .backgroundColor($r("app.color.white"))
      .borderRadius(10)
      .padding({
        left: 18,
        right: 18
      })

    }
    .padding(10)

  }
}

export { HmToggleCard }