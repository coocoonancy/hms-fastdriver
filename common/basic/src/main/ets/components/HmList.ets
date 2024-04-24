@Component
struct HmList {
  @State
  refreshing: boolean = false // 下拉刷新
  @State
  refreshStr: string = '未激活'
  @State
  refreshState: RefreshStatus = RefreshStatus.Inactive
  @Prop
  dataSource: object[] = []
  @Prop
  finished: boolean = false
  @State
  loading: boolean = false // 是否加载中
  @Prop
  loadingText: string = '加载中'
  @Prop
  finishedText: string = '加载完成中'
  @BuilderParam
  renderItem: (item: object) => void
  onLoad: () => void = () => {
  }
  onRefresh: () => void = () => {
  }

  @Builder
  getBottomDisplay() {
    // 获取底部的展示内容
    Row({ space: 10 }) {
      if (this.finished) {
        // 此时应该没有动画的loading
        Text(this.finishedText)
          .fontSize(14)
          .fontColor($r("app.color.text_secondary"))
      } else {
        Text(this.loadingText)
          .fontSize(14)
          .fontColor($r("app.color.text_secondary"))
        LoadingProgress()
          .width(20)
          .aspectRatio(1)
          .color($r("app.color.text_secondary"))
      }
    }
    .width('100%')
    .height(50)
    .justifyContent(FlexAlign.Center)
  }

  getStatusText() {
    switch (this.refreshState) {
      case RefreshStatus.Inactive:
        return ""
      case RefreshStatus.Drag:
        return "继续下拉"
      case RefreshStatus.OverDrag:
        return "松手加载"
      case RefreshStatus.Refresh:
        return "加载中"
    }
    return ""
  }

  @Builder
  getRefreshDisPlay() {
    Row({ space: 10 }) {
      LoadingProgress()
        .color($r('app.color.primary'))
        .width(40)
        .height(40)
      Text(this.getStatusText())
        .fontColor($r('app.color.text_secondary'))
        .fontSize(14)
    }
    .justifyContent(FlexAlign.Center)
    .height(50)
    .width('100%')
  }

  build() {
    Refresh({ refreshing: $$this.refreshing, builder: this.getRefreshDisPlay }) {
      List() {
        ForEach(this.dataSource, (item: object) => {
          ListItem() {
            if (this.renderItem) {
              this.renderItem(item)
            }

          }
        })
        ListItem() {
          this.getBottomDisplay()
        }
      }
      .onReachEnd(async () => {
        // 上拉加载 没有请求和加载完成的情况
        if (!this.finished && !this.loading) {
          this.loading = true
          await this.onLoad()
          this.loading = false
        }

      })
    }
    .onStateChange(async state => {
      // 下拉刷新
      if (state === RefreshStatus.Refresh) {
        await this.onRefresh()
        this.refreshing = false
        // 下拉刷新
        this.loading = false
        this.refreshStr = '松手加载啦'
      }
      this.refreshState = state
      // if (state === RefreshStatus.Drag) {
      //   this.refreshStr = '往下拉'
      // } else if (state === RefreshStatus.OverDrag) {
      //   this.refreshStr = '超过值啦'
      // } else if (state === RefreshStatus.Refresh) {
      //   await this.onRefresh()
      //   this.refreshing = false
      //   // 下拉刷新
      //   this.loading = false
      //   this.refreshStr = '松手加载啦'
      // } else if (state === RefreshStatus.Done) {
      //   this.refreshStr = '完成'
      // }
    })

  }
}

export { HmList }