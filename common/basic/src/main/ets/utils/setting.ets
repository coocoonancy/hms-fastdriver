// 读写广告配置
import { preferences } from '@kit.ArkData'
import { TOKEN_KEY, USER_SETTING, USER_SETTING_AD } from '../constants'
import { AdvertClass } from '../models'

export const defaultAd: AdvertClass = {
  showAd: true,
  adTime: 5,
  adImg: $r('app.media.start'),
  adUrl: ''
}

export class UserSettingClass {
  context: Context

  constructor(context: Context) {
    this.context = context
  }

  // 获取仓库
  getStore() {
    return preferences.getPreferencesSync(this.context, {
      name: USER_SETTING
    })
  }

  // 设置用户广告设置
  async setUserAd(ad: AdvertClass) {
    const adStore = await this.getStore()
    await adStore.put(USER_SETTING_AD, JSON.stringify(ad))
    await adStore.flush()
  }

  // 读取用户的广告配置
  getUserAd() {
    const store = this.getStore()
    return JSON.parse(store.getSync(USER_SETTING_AD, JSON.stringify(defaultAd)) as string) as AdvertClass
  }

  async setUserToken(token: string) {
    const adStore = await this.getStore()
    await adStore.put(TOKEN_KEY, token)
    // 写入磁盘
    await adStore.flush()
  }

  async getUserToken(): Promise<string> {
    const adStore = await this.getStore()
    return await adStore.get(TOKEN_KEY, '') as string
  }
}