#import "GcUniversal/GcImagePickerUtils.h"
#import <UIKit/UIKit.h>

@interface _UIBatteryView : UIView
- (bool) _shouldShowBolt;
- (void) _updateBatteryFillColor;
- (void) setBodyColor: (UIColor *) arg0;
- (void) setChargePercent: (CGFloat) arg0;
- (void) setChargingState: (long long) arg0;
- (void) setFillColor: (UIColor *) arg0;
- (void) setPinColor: (UIColor *) arg0;
- (void) setSaverModeActive: (bool) arg0;
@end

UIImage *libgc_image() {
    return [GcImagePickerUtils imageFromDefaults:@"emt.paisseon.vivy" withKey:@"userIcon"];
}