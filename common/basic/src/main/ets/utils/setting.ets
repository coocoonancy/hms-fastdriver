// 读写广告配置
import { preferences } from '@kit.ArkData'
import { USER_SETTING, USER_SETTING_AD } from '../constants'
import { AdvertClass } from '../models'

const defaultAd: AdvertClass = {
  showAd: true,
  adTime: 5,
  adImg: '',
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

  async getUserAd(): Promise<AdvertClass> {
    const adStore = await this.getStore()
    return JSON.parse(await adStore.get(USER_SETTING_AD, JSON.stringify(defaultAd)) as string) as AdvertClass
  }
}