import Orion
import VivyC
import UIKit

class BatteryHook: ClassHook<_UIBatteryView> {
    func didMoveToWindow() {
        orig.didMoveToWindow()
        
        if target.subviews.count > 0 {
            return
        }
        
        switch Preferences.shared.theme {
            case 0:
                target.addSubview(LinearBattery(frame: CGRect(x: 0.0, y: (12.5 / 3.0), width: 26.5, height: (12.5 / 3.0))))
            case 1:
                target.addSubview(CircleBattery(frame: CGRect(x: 7.5, y: 0.0, width: 15.0, height: 15.0)))
            case 2:
                target.addSubview(ImageBattery(frame: CGRect(x: 0.0, y: 0.0, width: 26.5, height: 12.5)))
            default:
                target.addSubview(LinearBattery(frame: CGRect(x: 0.0, y: (12.5 / 3.0), width: 26.5, height: (12.5 / 3.0))))
        }
        
        let label = UILabel()
        target.addSubview(label)
    }
    
    func setChargePercent(_ arg0: Double) {
        orig.setChargePercent(arg0)
        
        if VivyController.shared.percent == 1.0 || Int(arg0 * 100.0) != Int(VivyController.shared.percent * 100.0) {
            VivyController.shared.percent = arg0
            VivyController.shared.update(target)
        }
    }
    
    func setChargingState(_ arg0: Int64) {
        orig.setChargingState(arg0)
        
        VivyController.shared.charging = (arg0 == 1)
        VivyController.shared.update(target)
    }
    
    func setSaverModeActive(_ arg0: Bool) {
        orig.setSaverModeActive(arg0)
        
        VivyController.shared.lpm = arg0
        VivyController.shared.update(target)
    }
    
    // Hide the original battery
    
    func _shouldShowBolt() -> Bool {
        false
    }
    
    func _batteryFillColor() -> UIColor {
        .clear
    }
    
    func bodyColor() -> UIColor {
        .clear
    }
    
    func pinColor() -> UIColor {
        .clear
    }
    
    func _updateBatteryFillColor() {
        return
    }
}