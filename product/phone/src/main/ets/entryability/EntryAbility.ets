import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import "../utils/plugin"
import { Log } from '@abner/log';
import { RouterConfig, TokenManager } from '@hm/basic';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    Log.info('Ability onDestroy');
  }

  onDestroy(): void {
    Log.info('Ability onDestroy');
  }

  async onWindowStageCreate(windowStage: window.WindowStage): Promise<void> {
    // Main window is created, set main page for this ability
    Log.info('Ability onWindowStageCreate');
    const sub = await windowStage.createSubWindow('add_win')
    sub.showWindow()
    sub.setUIContent(RouterConfig.SPLASH_URL) // 设置路径 跨包页面加载
    TokenManager.context = this.context
    if (!(await TokenManager.getUser()).token) {
      windowStage.loadContent('pages/Index');
    } else {
      windowStage.loadContent(RouterConfig.LOGIN_URL)
    }

  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    Log.info('Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    Log.info('Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    Log.info('Ability onBackground');
  }
}