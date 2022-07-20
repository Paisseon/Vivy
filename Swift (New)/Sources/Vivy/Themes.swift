import UIKit
import VivyC

// Also, I should give credit to the designer who made linear, the default theme here. I can't seem to recall who it is though. When you're as famous as I am, you meet so many people it's impossible to remember them all. What is that guy's name? It's on the tip of my tongue... yeah, idk, I want to say... timeloop?

final class LinearBattery: UIView {
    private let animationLayer  = CAGradientLayer()
    private let backgroundLayer = CALayer()
    private let batteryLayer    = CALayer()
    private let maskLayer       = CAShapeLayer()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink.add(to: .current, forMode: .common)
        
        layer.addSublayer(backgroundLayer)
        layer.addSublayer(animationLayer)
        
        animationLayer.mask                 = batteryLayer
        animationLayer.locations            = [0.35, 0.5, 0.65]
        animationLayer.startPoint           = CGPoint(x: 0, y: 0.5)
        
        if !Preferences.shared.animate {
            return
        }
        
        let flowAnimation                   = CABasicAnimation(keyPath: "locations")
        
        flowAnimation.fromValue             = [-0.3, -0.15, 0]
        flowAnimation.toValue               = [1, 1.15, 1.3]
        flowAnimation.isRemovedOnCompletion = false
        flowAnimation.repeatCount           = Float.infinity
        flowAnimation.duration              = 1
        
        animationLayer.add(flowAnimation, forKey: "flowAnimation")
    }
    
    override func draw( _ frame: CGRect) {
        maskLayer.path               = UIBezierPath(roundedRect: frame, cornerRadius: 69.0).cgPath
        layer.mask                   = maskLayer
        
        let batteryFrame             = CGRect(origin: .zero, size: CGSize(width: frame.width, height: frame.height))
        
        backgroundLayer.frame        = batteryFrame
        backgroundLayer.opacity      = 0.5
        
        batteryLayer.frame           = batteryFrame
        batteryLayer.backgroundColor = UIColor.black.cgColor
        
        animationLayer.frame         = frame
        animationLayer.colors        = [UIColor.green.cgColor, UIColor.white.cgColor, UIColor.green.cgColor]
        animationLayer.endPoint      = CGPoint(x: 1.0, y: 0.5)
    }
    
    @objc func update() {
        if !Preferences.shared.animate {
            VivyController.shared.flash = VivyController.shared.colour
        }
        
        batteryLayer.frame              = CGRect(origin: .zero, size: CGSize(width: self.frame.width * VivyController.shared.percent, height: self.frame.height))
        backgroundLayer.frame           = CGRect(origin: .zero, size: CGSize(width: self.frame.width, height: self.frame.height))
        animationLayer.colors           = [VivyController.shared.colour.cgColor, VivyController.shared.flash.cgColor, VivyController.shared.colour.cgColor]
        animationLayer.endPoint         = CGPoint(x: VivyController.shared.percent, y: 0.5)
        backgroundLayer.backgroundColor = VivyController.shared.colour.cgColor
    }
}

// Use a circular or ring-shaped battery

final class CircleBattery: UIView {
    private let animationLayer  = CAGradientLayer()
    private let backgroundLayer = CAShapeLayer()
    private let batteryLayer    = CAShapeLayer()
    private let maskLayer       = CAShapeLayer()

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink.add(to: .current, forMode: .common)
        
        maskLayer.lineWidth        = 1.5
        maskLayer.fillColor        = nil
        maskLayer.strokeColor      = UIColor.black.cgColor
        layer.mask                 = maskLayer
        
        backgroundLayer.lineWidth  = 1.5
        backgroundLayer.fillColor  = nil
        
        batteryLayer.lineWidth     = 1.5
        batteryLayer.fillColor     = nil
        
        layer.addSublayer(backgroundLayer)
        layer.addSublayer(animationLayer)
        layer.transform            = CATransform3DMakeRotation(CGFloat(90.0 * Double.pi / 180.0), 0, 0, -1)
        
        animationLayer.mask        = batteryLayer
        animationLayer.locations   = [0.35, 0.5, 0.65]
        
        if !Preferences.shared.animate {
            return
        }
        
        let startAnimation         = CAKeyframeAnimation(keyPath: "startPoint")
        startAnimation.values      = [CGPoint.zero, CGPoint(x: 1, y: 0), CGPoint(x: 1, y: 1)]
        startAnimation.repeatCount = Float.infinity
        startAnimation.duration    = 1
        
        let endAnimation           = CAKeyframeAnimation(keyPath: "endPoint")
        endAnimation.values        = [CGPoint(x: 1, y: 1), CGPoint(x: 0, y: 1), CGPoint.zero]
        endAnimation.repeatCount   = Float.infinity
        endAnimation.duration      = 1
        
        animationLayer.add(startAnimation, forKey: "startPointAnimation")
        animationLayer.add(endAnimation, forKey: "endPointAnimation")
    }
    
    override func draw(_ frame: CGRect) {
        let circlePath              = UIBezierPath(ovalIn: frame.insetBy(dx: 1.5, dy: 1.5))
        maskLayer.path              = circlePath.cgPath
        
        backgroundLayer.path        = circlePath.cgPath
        backgroundLayer.strokeStart = 0
        backgroundLayer.strokeEnd   = 1.0
        backgroundLayer.strokeColor = UIColor.black.cgColor
        backgroundLayer.opacity     = 0.5
        
        batteryLayer.path           = circlePath.cgPath
        batteryLayer.lineCap        = .round
        batteryLayer.strokeStart    = 0
        batteryLayer.strokeEnd      = 1.0
        batteryLayer.strokeColor    = UIColor.black.cgColor
        
        animationLayer.frame        = frame
        animationLayer.colors       = [UIColor.green.cgColor, UIColor.white.cgColor, UIColor.green.cgColor]
    }
    
    @objc private func update() {
        if !Preferences.shared.animate {
            VivyController.shared.flash = VivyController.shared.colour
        }
        
        batteryLayer.strokeEnd          = VivyController.shared.percent
        animationLayer.colors           = [VivyController.shared.colour.cgColor, VivyController.shared.flash.cgColor, VivyController.shared.colour.cgColor]
        backgroundLayer.backgroundColor = VivyController.shared.colour.cgColor
        backgroundLayer.strokeColor     = VivyController.shared.colour.cgColor
    }
}

// The classic Vivy experience, a custom selected image from the user

final class ImageBattery: UIView {
    private let icon  = UIImageView()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink.add(to: .current, forMode: .common)
        
        icon.frame            = frame
        icon.contentMode      = .scaleAspectFill
        icon.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        icon.image            = libgc_image(); // [GcImagePickerUtils imageFromDefaults:@"emt.paisseon.vivy" withKey:@"userIcon"];
        
        let fill              = CAGradientLayer()
        fill.frame            = frame
        fill.colors           = [
            UIColor.green.cgColor as Any, 
            UIColor.green.cgColor as Any, 
            UIColor(white: 1.0, alpha: 0.5).cgColor as Any, 
            UIColor(white: 1.0, alpha: 0.5).cgColor as Any
        ]
        fill.locations        = [0 as NSNumber, 1.0 as NSNumber, 1.0 as NSNumber, 1 as NSNumber]
        fill.startPoint       = CGPoint.zero
        fill.endPoint         = CGPoint(x: 1.0, y: 0.0)
        icon.layer.mask       = fill
        
        self.addSubview(icon)
    }
    
    @objc private func update() {
        if #available(iOS 13.0, *) {
            icon.image        = Preferences.shared.eliza ? icon.image?.withTintColor(VivyController.shared.colour) : icon.image   
        }
        
        let fill              = CAGradientLayer()
        fill.frame            = self.frame
        fill.colors           = [
            VivyController.shared.colour.cgColor as Any, 
            VivyController.shared.colour.cgColor as Any, 
            UIColor(white: 1.0, alpha: 0.5).cgColor as Any, 
            UIColor(white: 1.0, alpha: 0.5).cgColor as Any
        ]
        fill.locations        = [0 as NSNumber, VivyController.shared.percent as NSNumber, VivyController.shared.percent as NSNumber, 1 as NSNumber]
        fill.startPoint       = CGPoint.zero
        fill.endPoint         = CGPoint(x: 1.0, y: 0.0)
        icon.layer.mask       = fill
    }
}

// Mimic the vertical battery icon from Android phones

final class AndroidBattery: UIView {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
}