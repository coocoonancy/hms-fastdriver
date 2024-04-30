import { abilityAccessCtrl, AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { AdvertClass, defaultAd, TOKEN_KEY, UserSettingClass } from '@hms/basic/Index';

export default class EntryAbility extends UIAbility {
  async onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): Promise<void> {
    let manger = abilityAccessCtrl.createAtManager()
    await manger.requestPermissionsFromUser(this.context,
      [
        'ohos.permission.LOCATION',
        'ohos.permission.APPROXIMATELY_LOCATION',
      ])
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  async onWindowStageCreate(windowStage: window.WindowStage): Promise<void> {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
    const userSetting = new UserSettingClass(this.context)

    const ad = await new Promise<AdvertClass>((resolve) => {
      setTimeout(() => {
        resolve(defaultAd)
      })
    })

    await userSetting.setUserAd(ad)

    if (ad.showAd) {
      const win = await windowStage.createSubWindow('ad_window')
      await win.showWindow()
      win.setUIContent('pages/Start/Start')
    }

    const token = await userSetting.getUserToken()
    AppStorage.setOrCreate(TOKEN_KEY, token)

    // windowStage.getMainWindowSync().setWindowLayoutFullScreen(true)
    // AppStorage.setOrCreate("topHeight", px2vp(windowStage.getMainWindowSync().getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM)
    //   .topRect.height)  )
    // AppStorage.setOrCreate("bottomHeight", px2vp(windowStage.getMainWindowSync().getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR)
    //   .bottomRect.height)  )


    if (token) {
      windowStage.loadContent('pages/Index/Index', (err) => {
        if (err.code) {
          hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
          return;
        }
        hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');
      });
    } else {
      windowStage.loadContent('pages/Login/Login', (err) => {
        if (err.code) {
          hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
          return;
        }
        hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');
      });
    }

  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }
}
