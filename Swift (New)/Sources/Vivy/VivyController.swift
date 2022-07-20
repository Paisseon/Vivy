import UIKit

final class VivyController {
    static let shared = VivyController()
    
    public var colour   = UIColor.blue
    public var flash    = Preferences.shared.eliza ? UIColor.white : UIColor.purple
    public var percent  = 1.0
    public var charging = false
    public var lpm      = false
    
    private func labelText() -> String {
        if Preferences.shared.theme != 3 {
            return "\(Int(percent * 100.0))"
        }
        
        if charging || percent >= 0.75 {
            return "(> ◡ <)"
        } else if percent >= 0.3 {
            return "(*'ω'*)"
        }
        
        return "(• Д •)"
    }
    
    public func update(_ arg0: UIView) {
        if charging {
            colour = UIColor(red: 0.0, green: 0.61, blue: 0.47, alpha: 1.0)
        } else if lpm {
            colour = UIColor(red: 1.0, green: 0.78, blue: 0.17, alpha: 1.0)
        } else {
            colour = Preferences.shared.eliza ? UIColor(hue: VivyController.shared.percent / 3.0, saturation: 1.0, brightness: 1.0, alpha: 1.0) : .white
        }
        
        if Preferences.shared.label {
            if arg0.subviews.count < 2 {
                return
            }
            
            arg0.subviews[1].removeFromSuperview()
            
            let label                                       = UILabel()
            label.frame                                     = Preferences.shared.theme == 1 ? arg0.subviews[0].frame : CGRect(x: 0.0, y: -6.5, width: 26.5, height: 12.5)
            label.font                                      = UIFont.boldSystemFont(ofSize: 6)
            label.textAlignment                             = .center
            label.translatesAutoresizingMaskIntoConstraints = true
            label.text                                      = labelText()
            label.textColor                                 = Preferences.shared.eliza ? colour : .white
            
            arg0.addSubview(label)
        }
    }
    
    private init() {}
}