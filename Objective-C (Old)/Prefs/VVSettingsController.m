#import "VVSettingsController.h"

@implementation VVSettingsController
- (void) viewDidLoad {
	[super viewDidLoad];
}

- (void) layoutHeader {
	[super layoutHeader];
}

- (NSBundle *)resourceBundle {
	return [NSBundle bundleWithPath:@"/Library/PreferenceBundles/VivyPrefs.bundle"];
}

- (void) respring {
	setuid(0);
	pid_t pid;
	const char *args[] = {"sbreload", NULL, NULL, NULL};
	posix_spawn(&pid, "usr/bin/sbreload", NULL, NULL, (char *const *)args, NULL);
}
@end
