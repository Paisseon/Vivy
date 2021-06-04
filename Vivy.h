#import <UIKit/UIKit.h>
#import <QuartzCore/CoreAnimation.h>

static NSString* bundleIdentifier = @"ai.paisseon.vivy";
static NSMutableDictionary *settings;
static bool enabled;
static bool percent;
static int shape;
static int percentFont;
static double percentX;
static double percentY;
static NSString* theme = @"linear";

bool isCharging;
bool isLPM;
double currentBattery;
double intBattery;
id chargedFill;
id drainedFill;
NSArray* locations;
NSString* iconPath;
UIImageView* icon;
UILabel* percentLabel;
CAGradientLayer* fill;

@interface _UIBatteryView : UIView
@property (nonatomic, copy, readwrite) UIColor* fillColor;
@property (nonatomic, copy, readwrite) UIColor* bodyColor;
@property (nonatomic, copy, readwrite) UIColor* pinColor;
- (bool) _shouldShowBolt;
- (void) setChargingState: (long long) arg1;
- (void) setSaverModeActive: (bool) arg1;
- (void) addIcon;
- (double) getCurrentBattery;
@end