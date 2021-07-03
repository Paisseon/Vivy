#import "Tweak.h"

static void refreshPrefs() {
    CFArrayRef keyList = CFPreferencesCopyKeyList((CFStringRef)bundleIdentifier, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    if (keyList) {
        settings = (NSMutableDictionary *)CFBridgingRelease(CFPreferencesCopyMultiple(keyList, (CFStringRef)bundleIdentifier, kCFPreferencesCurrentUser, kCFPreferencesAnyHost));
        CFRelease(keyList);
    } else settings = nil;
    if (!settings) settings = [[NSMutableDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", bundleIdentifier]];

    enabled = [([settings objectForKey:@"enabled"] ?: @(true)) boolValue];
    percent = [([settings objectForKey:@"percent"] ?: @(false)) boolValue];
    shape = [([settings objectForKey:@"shape"] ?: @(0)) integerValue];
    percentX = [([settings objectForKey:@"percentX"] ?: @(5.0)) doubleValue];
    percentY = [([settings objectForKey:@"percentY"] ?: @(-5.0)) doubleValue];
    percentFont = [([settings objectForKey:@"percentFont"] ?: @(8)) integerValue];
    theme = [[([settings objectForKey:@"theme"] ?: @"linear") stringValue] lowercaseString];
}

static void PreferencesChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	refreshPrefs();
}

%hook _UIBatteryView
- (void) _commonInit {
	%orig;
	[[UIDevice currentDevice] setBatteryMonitoringEnabled:true]; // make ios monitor the battery
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getCurrentBattery) name:UIDeviceBatteryLevelDidChangeNotification object:nil]; // add observer for battery level
	self.pinColor = [UIColor clearColor]; // hide the pin
	self.bodyColor = [UIColor clearColor]; // hide the body. there's a joke in there somewhere
	self.fillColor = [UIColor clearColor]; // hide the default fill
}

- (void) layoutSubviews {
	%orig;
	[self getCurrentBattery]; // this fixes a bug some users have where the battery icon only appears on springboard
}

- (bool) _shouldShowBolt {return false;} // hide charging bolt

- (id) _batteryFillColor {return [UIColor clearColor];} // hide charging fill because it is different from regular fill apparently?

- (void) setChargingState: (long long) arg1 {
	%orig;
	if (arg1 == 1) isCharging = true; // 1 means currently charging
	else isCharging = false;
	[self addIcon];
}

- (void) setSaverModeActive: (bool) arg1 {
	%orig;
	isLPM = arg1; // is low power mode activated
	[self addIcon];
}

%new
- (void) addIcon {
	icon = nil; // clear the definition of current icon

	for (UIImageView* cachedIcon in [self subviews])
		[cachedIcon removeFromSuperview]; // remove icon from battery view

	icon = [[UIImageView alloc] initWithFrame:[self bounds]]; // init the icon view as equal to original battery view
	[icon setContentMode:UIViewContentModeScaleAspectFill]; // scale icon to fit the size of battery view if it changes
	[icon setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight]; // resize if necessary
	if (![icon isDescendantOfView:self]) [self addSubview:icon]; // add the icon to the battery view

	iconPath = [NSString stringWithFormat:@"/Library/Application Support/Vivy/%@/icon.png", theme]; // get normal theme icon
	[icon setImage:[UIImage imageWithContentsOfFile:iconPath]]; // set theme icon as battery icon
	if (isCharging) icon.image = [icon.image imageWithTintColor:[UIColor colorWithRed: 0.0 green: 0.61 blue: 0.47 alpha: 0.75]]; // emerald tint if charging
	else if (isLPM) icon.image = [icon.image imageWithTintColor:[UIColor colorWithRed: 1.0 green: 0.78 blue: 0.17 alpha: 0.75]]; // saffron tint if lpm mode

	if (percent) {
		percentLabel = [[UILabel alloc] initWithFrame:[self bounds]]; // init percent label
		[percentLabel setFont: [UIFont boldSystemFontOfSize:percentFont]]; // set font size to 8
		[percentLabel setAdjustsFontSizeToFitWidth:true]; // but change it if needed
		[percentLabel setText:[NSString stringWithFormat:@"%u%%", (int)intBattery]]; // make the label the battery plus the % symbol
		[percentLabel setCenter:CGPointMake(icon.center.x + percentX, icon.center.y + percentY)]; // centre it on the view (this isn't exactly a good way to do it but it's what i am doing)
		[self addSubview:percentLabel]; // add to battery view
		[self bringSubviewToFront:percentLabel]; // place it above the icon so it doesn't get erased by drain
	}

	chargedFill = (id)[[UIColor whiteColor] CGColor]; // use the original image colour for the battery section
    drainedFill = (id)[[UIColor colorWithWhite:1 alpha:0.5] CGColor]; // faded in uncharged area

	fill = [CAGradientLayer layer]; // init battery fill view as a gradient layer-- this allows it to fill by percent
	fill.frame = icon.bounds; // bounds of battery icon view
	fill.colors = @[chargedFill, chargedFill, drainedFill, drainedFill]; // colourise the battery
	fill.locations = locations; // fill icon to the percentage of battery level
	if (shape == 2) {
		fill.type = kCAGradientLayerConic; // for some reason clockwise gradient is called conic? whatever, it's what works
		fill.startPoint = CGPointMake(0.5, 0.5); // start in the centre
		fill.endPoint = CGPointMake(0.5, 0); // loop around
	} else if (shape == 1) {
		fill.startPoint = CGPointMake(0.5, 1.0); // start at the bottom
		fill.endPoint = CGPointMake(0.5, 0.0); // end at the top
	} else {
		fill.startPoint = CGPointZero; // start at the beginning
		fill.endPoint = CGPointMake(1.0, 0.0); // end at the end. i am very good at comments. people die if they are killed.
	}
	icon.layer.mask = fill; // add the fill to battery

	self.pinColor = [UIColor clearColor]; // hide it again or the battery shows up again for some reason
	self.bodyColor = [UIColor clearColor];
	self.fillColor = [UIColor clearColor];
}

%new
- (double) getCurrentBattery {
	currentBattery = [[UIDevice currentDevice] batteryLevel]; // the current battery level
	intBattery = currentBattery * 100; // battery level multiplied by 100 for easier casting to int
	locations = @[@0.0, @(currentBattery), @(currentBattery), @1.0]; // fill extends from 0% to battery, empty extends from battery to 100%
	[self addIcon];
	return currentBattery;
}
%end

%ctor {
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback) PreferencesChangedCallback, (CFStringRef)[NSString stringWithFormat:@"%@.prefschanged", bundleIdentifier], NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
    refreshPrefs();
    if (enabled) %init;
}