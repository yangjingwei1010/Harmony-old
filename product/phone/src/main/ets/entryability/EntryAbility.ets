import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import "../utils/plugin"
import { Log } from '@abner/log';

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
    sub.setUIContent('@bundle:com.yang.yanglao.pro/home/ets/pages/Splash/Splash') // 设置路径 跨包页面加载
    windowStage.loadContent('pages/Index');
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