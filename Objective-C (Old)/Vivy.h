#import <UIKit/UIKit.h>
#import <QuartzCore/CoreAnimation.h>
#import "libimagepicker.h"
#import "libcolorpicker.h"

static NSString* bundleIdentifier = @"ai.paisseon.vivy";
static NSMutableDictionary *settings;
static bool enabled;
static bool percent;
static bool useLCP;
static int shape;
static int theme;
static int percentFont;
static double percentX;
static double percentY;
static NSString* lcpColour;

bool isCharging;
bool isLPM;
double intBattery;
NSArray* locations;
NSString* iconPath;

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

@interface NSUserDefaults (Vivy)
- (id)objectForKey:(NSString *)key inDomain:(NSString *)domain;
- (void)setObject:(id)value forKey:(NSString *)key inDomain:(NSString *)domain;
@end