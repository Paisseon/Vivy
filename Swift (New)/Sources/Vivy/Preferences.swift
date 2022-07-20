import Cephei

class Preferences {
	static let shared = Preferences()
	
	private let preferences = HBPreferences(identifier: "emt.paisseon.vivy")
    
    // These vars are read from the tweak
    
	private(set) var enabled = true
	private(set) var animate = false
    private(set) var eliza   = false
    private(set) var label   = false
    private(set) var theme   = 0
    
    // For some reason, Cephei uses ObjCBool instead of the standard Bool type
    
    private var enabledI: ObjCBool = true
    private var animateI: ObjCBool = false
    private var elizaI  : ObjCBool = false
    private var labelI  : ObjCBool = false
	
    // Cephei stuff. Extra features are disabled by default, just experiment because they break some apps and fix others.
    
	private init() {
		preferences.register(defaults: [
			"enabled" : true,
			"animate" : false,
            "eliza"   : false,
            "label"   : false,
            "theme"   : 0
		])
	
		preferences.register(_Bool: &enabledI, default: true,  forKey: "enabled")
		preferences.register(_Bool: &animateI, default: false, forKey: "animate")
        preferences.register(_Bool: &elizaI,   default: false, forKey: "eliza")
        preferences.register(_Bool: &labelI,   default: false, forKey: "label")
        preferences.register(integer: &theme,  default: 0,     forKey: "theme")
        
        enabled = enabledI.boolValue
        animate = animateI.boolValue
        eliza   = elizaI.boolValue
        label   = labelI.boolValue
	}
}
