import { wifiManager } from '@kit.MDMKit'
import { Want } from '@kit.AbilityKit';
import { Log } from '@abner/log';

class WfManager {
  checkWifi() {
    let wantTemp: Want = {
      bundleName: 'com.yang.yanglao.pro',
      abilityName: 'EntryAbility',
    };
    try {
      let result: boolean = wifiManager.isWifiActiveSync(wantTemp);
      Log.info(`Succeeded in query is wifi active or not, result : ${result}`);
      return result
    } catch (err) {
      Log.error(`Failed to query is wifi active or not. Code: ${err.code}, message: ${err.message}`);
      return false
    }
  }
}

export const wfManager = new WfManager()