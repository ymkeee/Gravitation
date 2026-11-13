#include "GRVRootListController.h"

@implementation GRVRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	return _specifiers;
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	CGFloat screenW = [[UIScreen mainScreen] bounds].size.width;
	self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenW, 100)];
	self.headerView.backgroundColor = [UIColor colorWithRed:0.07 green:0.20 blue:0.13 alpha:1.0];
	self.headerView.clipsToBounds = YES;

	NSString *title = @"GRAVITATION";
	CGFloat charWidth = 26.0;
	CGFloat totalWidth = title.length * charWidth;
	CGFloat startX = (screenW - totalWidth) / 2.0;
	if (startX < 10) startX = 10;

	for (NSUInteger i = 0; i < title.length; i++) {
		UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(startX + (i * charWidth), 30, charWidth, 40)];
		lbl.font = [UIFont boldSystemFontOfSize:22];
		lbl.textAlignment = NSTextAlignmentCenter;
		lbl.textColor = [UIColor whiteColor];
		lbl.text = [title substringWithRange:NSMakeRange(i, 1)];
		[self.headerView addSubview:lbl];
	}

	self.gravitation_gravitationAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:self.headerView];
	self.gravitation_gravitationBehavior = [[UIGravityBehavior alloc] initWithItems:self.headerView.subviews];

	self.gravitation_gravitationCollisionBehavior = [[UICollisionBehavior alloc] initWithItems:self.headerView.subviews];
	self.gravitation_gravitationCollisionBehavior.translatesReferenceBoundsIntoBoundary = YES;
	self.gravitation_gravitationCollisionBehavior.collisionMode = UICollisionBehaviorModeEverything;

	self.gravitation_motionManager = [[CMMotionManager alloc] init];
	if (self.gravitation_motionManager.isDeviceMotionAvailable) {
		self.gravitation_motionManager.deviceMotionUpdateInterval = 1.0 / 60.0;
		__weak GRVRootListController *weakSelf = self;
		[self.gravitation_motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
			if (error != nil || !weakSelf || !weakSelf.gravitation_gravitationBehavior) return;
			weakSelf.gravitation_gravitationBehavior.gravityDirection = CGVectorMake(motion.gravity.x * 3.0, -motion.gravity.y * 3.0);
		}];
	}

	[self.gravitation_gravitationAnimator addBehavior:self.gravitation_gravitationCollisionBehavior];
	[self.gravitation_gravitationAnimator addBehavior:self.gravitation_gravitationBehavior];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	if (self.gravitation_motionManager) {
		[self.gravitation_motionManager stopDeviceMotionUpdates];
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if (self.gravitation_motionManager && !self.gravitation_motionManager.isDeviceMotionActive) {
		__weak GRVRootListController *weakSelf = self;
		[self.gravitation_motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
			if (error != nil || !weakSelf || !weakSelf.gravitation_gravitationBehavior) return;
			weakSelf.gravitation_gravitationBehavior.gravityDirection = CGVectorMake(motion.gravity.x * 3.0, -motion.gravity.y * 3.0);
		}];
	}
}

- (void)dealloc {
	if (self.gravitation_motionManager) {
		[self.gravitation_motionManager stopDeviceMotionUpdates];
		self.gravitation_motionManager = nil;
	}
	if (self.gravitation_gravitationAnimator) {
		[self.gravitation_gravitationAnimator removeAllBehaviors];
		self.gravitation_gravitationAnimator = nil;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	tableView.tableHeaderView = self.headerView;
	return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}

@end
