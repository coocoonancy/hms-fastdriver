import { TOKEN_KEY } from '@hms/basic/src/main/ets/constants/token'
import { login } from '../../api'
import { LoginFormModel } from '../../models'
import { UserSettingClass } from '@hms/basic/Index'
import { router } from '@kit.ArkUI'

@Entry
@Component
struct Login {
  @State
  loading: boolean = false
  @State
  accountForm: LoginFormModel = new LoginFormModel({
    account: 'xiaoshida1',
    password: '123456789'
  })

  // 调用登录接口
  async login() {
    try {
      this.loading = true
      const token = await login(this.accountForm)
      AppStorage.setOrCreate(TOKEN_KEY, token) // 写入全局状态
      new UserSettingClass(getContext(this)).setUserToken(token) // 存入首选项
      this.loading = false
      router.replaceUrl({
        url: 'pages/Index/Index'
      })
    } catch (error) {
    } finally {
      this.loading = false
    }
  }

  @Styles
  loginStyle() {
    .backgroundColor('#fff')
    .border({ color: $r('app.color.background_divider'), width: { bottom: 1 } })
    .width('100%')
    .height(58)
    .borderRadius(0)
  }

  getBtnEnabled() {
    if (this.accountForm.account && this.accountForm.password) {
      return true
    }
    return false
  }

  build() {
    Column() {
      // 顶部标题
      Text("小时达").fontColor($r('app.color.text_primary')).fontSize(18).height(25)
      // 账号登录
      Row() {
        Text('账号登录').fontColor($r('app.color.text_primary')).fontSize(24).fontWeight(FontWeight.Bold)
        Row() {
          Text("账号登录").fontColor($r('app.color.primary')).fontSize(16).fontWeight(FontWeight.Bold)
          Image($r("app.media.ic_angle")).width(10).height(10).margin({ left: 5 })
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ top: 50, bottom: 50 })

      // 用户名输入框
      TextInput({ placeholder: '请输入账号', text: this.accountForm.account })
        .loginStyle()
        .onChange(value => {
          this.accountForm.account = value
        })
        .onSubmit(() => {
          if (this.getBtnEnabled()) {
            this.login()
          }
        })

      // 密码框
      TextInput({ placeholder: '请输入密码', text: this.accountForm.password })
        .loginStyle()
        .type(InputType.Password)// 密码框
        .showPasswordIcon(true)// 显示密码按钮
        .onChange((value) => {
          this.accountForm.password = value
        })// 显示密码按钮
        .onSubmit(() => {
          if (this.getBtnEnabled()) {
            this.login()
          }
        })

      // 登录按钮
      Button({ type: ButtonType.Capsule }) {
        Row() {
          if (this.loading) {
            LoadingProgress().width(20).height(20).margin({ right: 12 }).color($r('app.color.white'))
          }
          Text('登录').fontColor($r('app.color.white'))
        }
      }
      .backgroundColor(this.getBtnEnabled() ? $r('app.color.primary') : $r('app.color.primary_disabled'))
      .width('100%')
      .height(50)
      .margin({ top: 50 })
      .enabled(this.getBtnEnabled())
      .onClick(() => {
        this.login()
      })
    }
    .padding({ left: 32, right: 32 })
    .margin({ top: 40 })
  }
}
