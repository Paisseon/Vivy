#import "Vivy.h"

static void refreshPrefs() {
    CFArrayRef keyList = CFPreferencesCopyKeyList((CFStringRef)bundleIdentifier, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    if (keyList) {
        settings = (NSMutableDictionary* )CFBridgingRelease(CFPreferencesCopyMultiple(keyList, (CFStringRef)bundleIdentifier, kCFPreferencesCurrentUser, kCFPreferencesAnyHost));
        CFRelease(keyList);
    } else settings = nil;
    if (!settings) settings = [[NSMutableDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", bundleIdentifier]];

    enabled     = [([settings objectForKey:@"enabled"] ?: @(true)) boolValue];
    percent     = [([settings objectForKey:@"percent"] ?: @(false)) boolValue];
    shape       = [([settings objectForKey:@"shape"] ?: @(0)) integerValue];
    percentX    = [([settings objectForKey:@"percentX"] ?: @(5.0)) doubleValue];
    percentY    = [([settings objectForKey:@"percentY"] ?: @(-5.0)) doubleValue];
    percentFont = [([settings objectForKey:@"percentFont"] ?: @(8)) integerValue];
    theme       = [([settings objectForKey:@"theme"] ?: @(0)) integerValue];
	useLCP      = [([settings objectForKey:@"useLCP"] ?: @(false)) boolValue];
	lcpColour   = [([settings objectForKey:@"lcpColour"] ?: @"#FFFFFF") stringValue];
	// clearDrain      = [([settings objectForKey:@"clearDrain"] ?: @(false)) boolValue]; // make the drained fill clear instead of black with 0.5 alpha
	// useOverlay      = [([settings objectForKey:@"useOverlay"] ?: @(false)) boolValue]; // use an overlay icon
}

static void PreferencesChangedCallback(CFNotificationCenterRef center, void* observer, CFStringRef name, const void* object, CFDictionaryRef userInfo) {
	refreshPrefs();
}

%hook _UIBatteryView
- (void) _commonInit {
	%orig;
	[[UIDevice currentDevice] setBatteryMonitoringEnabled:true]; // make iOS monitor the battery
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getCurrentBattery) name:UIDeviceBatteryLevelDidChangeNotification object:nil]; // add observer for battery level
	[self getCurrentBattery]; // get charge percent
}

- (void) didMoveToWindow {
	%orig;
	[self getCurrentBattery]; // this fixes a bug some users have where the battery icon only appears on springboard. now done without layoutSubviews!
}

- (bool) _shouldShowBolt {return false;} // hide charging bolt
- (id) _batteryFillColor {return [UIColor clearColor];} // hide the fill
- (id) bodyColor {return [UIColor clearColor];} // hide the body
- (id) pinColor {return [UIColor clearColor];} // hide the pin
- (CGFloat) bodyColorAlpha {return 0.0;} // hide battery body again
- (CGFloat) pinColorAlpha {return 0.0;} // hide battery pin again

- (void) setChargingState: (long long) arg1 {
	%orig;
	isCharging = (arg1 == 1); // state of 1 means currently charging
	[self addIcon];
}

- (void) setSaverModeActive: (bool) arg1 {
	%orig;
	isLPM = arg1; // is low power mode activated
	[self addIcon];
}

%new
- (void) addIcon {
	UIImageView* icon = nil; // clear the definition of current icon
	UIColor* customColour;
	if (useLCP) customColour = LCPParseColorString(lcpColour, @"#FFFFFF");
	else customColour = [UIColor whiteColor];

	for (UIImageView* cachedIcon in [self subviews])
		[cachedIcon removeFromSuperview]; // remove icon from battery view

	icon = [[UIImageView alloc] initWithFrame:[self bounds]]; // init the icon view as equal to original battery view
	[icon setContentMode:UIViewContentModeScaleAspectFill]; // scale icon to fit the size of battery view if it changes
	[icon setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight]; // resize if necessary
	if (![icon isDescendantOfView:self]) [self addSubview:icon]; // add the icon to the battery view
	
	switch (theme) {
		case 0:
			iconPath = @"/Library/Application Support/Vivy/linear.png"; // linear battery icon
			[icon setImage:[UIImage imageWithContentsOfFile:iconPath]]; // set theme icon as battery icon
			break;
		case 1:
			iconPath = @"/Library/Application Support/Vivy/zelda.png"; // zelda battery icon
			[icon setImage:[UIImage imageWithContentsOfFile:iconPath]]; // set theme icon as battery icon
			break;
		case 2:
			iconPath = @"/Library/Application Support/Vivy/android.png"; // android battery icon
			[icon setImage:[UIImage imageWithContentsOfFile:iconPath]]; // set theme icon as battery icon
			break;
		case 3:
			iconPath = @"/Library/Application Support/Vivy/ring.png"; // ring battery icon
			[icon setImage:[UIImage imageWithContentsOfFile:iconPath]]; // set theme icon as battery icon
			break;
		case 4:
			iconPath = @"/Library/Application Support/Vivy/blank.png"; // no battery icon (for having percent only)
			[icon setImage:[UIImage imageWithContentsOfFile:iconPath]]; // set theme icon as battery icon
			break;
		case 5:
			[icon setImage:[UIImage imageWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"customIcon" inDomain:@"ai.paisseon.vivy"]]]; // custom icon
			break;
	}
	
	if (isCharging) icon.image = [icon.image imageWithTintColor:[UIColor colorWithRed: 0.0 green: 0.61 blue: 0.47 alpha: 1.0]]; // emerald tint if charging
	else if (isLPM) icon.image = [icon.image imageWithTintColor:[UIColor colorWithRed: 1.0 green: 0.78 blue: 0.17 alpha: 1.0]]; // saffron tint if lpm mode
	else if (useLCP) icon.image = [icon.image imageWithTintColor:customColour]; // custom tint if user chooses

	if (percent) {
		UILabel* percentLabel = [[UILabel alloc] initWithFrame:[self bounds]]; // init percent label
		[percentLabel setFont: [UIFont boldSystemFontOfSize:percentFont]]; // set font size to 8
		[percentLabel setAdjustsFontSizeToFitWidth:true]; // but change it if needed
		[percentLabel setText:[NSString stringWithFormat:@"%u%%", (int)intBattery]]; // make the label the battery plus the % symbol
		[percentLabel setCenter:CGPointMake(icon.center.x + percentX, icon.center.y + percentY)]; // centre it on the view (this isn't exactly a good way to do it but it's what i am doing)
		if (isCharging) [percentLabel setTextColor:[UIColor colorWithRed: 0.0 green: 0.61 blue: 0.47 alpha: 1.0]]; // emerald text
		else if (isLPM) [percentLabel setTextColor:[UIColor colorWithRed: 1.0 green: 0.78 blue: 0.17 alpha: 1.0]]; // saffron text
		else [percentLabel setTextColor:customColour]; // white text
		[self addSubview:percentLabel]; // add to battery view
		[self bringSubviewToFront:percentLabel]; // place it above the icon so it doesn't get erased by drain
	}

	id chargedFill = (id)[[UIColor whiteColor] CGColor]; // use the original image colour for the battery section
    id drainedFill = (id)[[UIColor colorWithWhite:1 alpha:0.5] CGColor]; // faded in uncharged area

	CAGradientLayer* fill = [CAGradientLayer layer]; // init battery fill view as a gradient layer-- this allows it to fill by percent
	fill.frame = icon.bounds; // bounds of battery icon view
	fill.colors = @[chargedFill, chargedFill, drainedFill, drainedFill]; // colourise the battery
	fill.locations = locations; // fill icon to the percentage of battery level
	
	switch (shape) {
		case 0:
			fill.startPoint = CGPointZero; // start at the beginning
			fill.endPoint = CGPointMake(1.0, 0.0); // end at the end. i am very good at comments. people die if they are killed.
			break;
		case 1:
			fill.startPoint = CGPointMake(0.5, 1.0); // start at the bottom
			fill.endPoint = CGPointMake(0.5, 0.0); // end at the top
			break;
		case 2:
			fill.type = kCAGradientLayerConic; // for some reason circular gradient is called conic?
			fill.startPoint = CGPointMake(0.5, 0.5); // start in the centre
			fill.endPoint = CGPointMake(0.5, 0); // loop around
			break;
	}
	
	icon.layer.mask = fill; // add the fill to battery
}

%new
- (double) getCurrentBattery {
	double currentBattery = [[UIDevice currentDevice] batteryLevel]; // the current battery level
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