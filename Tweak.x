#import "Gravitation.h"

// Keys for storing original icon state before gravity simulation
static const void *kOriginalCenterKey = &kOriginalCenterKey;
static const void *kOriginalTransformKey = &kOriginalTransformKey;
static const void *kOriginalBoundsKey = &kOriginalBoundsKey;

// Runtime state
static BOOL isGlobalGravityActive = NO;
static NSTimeInterval lastShakeTimestamp = 0.0;
static CMMotionManager *hardwareShakeDetector = nil;

// Preference domain and notification constants
static NSString *const kPrefsDomain = @"me.kritanta.gravitationprefs";
static NSString *const kPrefsChangedNotification = @"me.kritanta.gravitationprefs/Prefs";

// Preferences variables
static BOOL isTweakEnabled = YES;
static BOOL isFingerGravityEnabled = YES;
static BOOL shouldHideLabels = NO; // Default NO: names stay visible with enlarged hitbox!
static BOOL statusBarCollision = YES;
static BOOL dynamicIslandCollision = YES;
static BOOL dockBarrier = YES;
static BOOL dockGravity = NO;
static BOOL shouldWidgetsFall = YES;
static CGFloat bounciness = 0.35;

// #pragma mark - Preferences Loading

static BOOL getBoolPref(NSDictionary *dict, NSString *key, BOOL defaultVal) {
    if (dict && dict[key] != nil) {
        return [dict[key] boolValue];
    }
    Boolean exists = false;
    Boolean val = CFPreferencesGetAppBooleanValue((__bridge CFStringRef)key, (__bridge CFStringRef)kPrefsDomain, &exists);
    return exists ? (BOOL)val : defaultVal;
}

static void loadPreferences(void) {
    isTweakEnabled = YES;
    isFingerGravityEnabled = YES;
    shouldHideLabels = NO;
    statusBarCollision = YES;
    dynamicIslandCollision = YES;
    dockBarrier = YES;
    dockGravity = NO;
    shouldWidgetsFall = YES;
    bounciness = 0.35;

    CFPreferencesAppSynchronize((__bridge CFStringRef)kPrefsDomain);

    // Direct plist fallback to ensure compatibility across rootless and roothide
    NSString *userPrefsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences/me.kritanta.gravitationprefs.plist"];
    NSDictionary *prefsDict = [NSDictionary dictionaryWithContentsOfFile:userPrefsPath];
    if (!prefsDict) {
        prefsDict = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/me.kritanta.gravitationprefs.plist"];
    }

    isTweakEnabled = getBoolPref(prefsDict, @"tweakEnabled", YES);
    isFingerGravityEnabled = getBoolPref(prefsDict, @"fingerGravity", YES);
    shouldHideLabels = getBoolPref(prefsDict, @"hideLabels", NO);
    statusBarCollision = getBoolPref(prefsDict, @"statusBarCollision", YES);
    dynamicIslandCollision = getBoolPref(prefsDict, @"dynamicIslandCollision", YES);
    dockBarrier = getBoolPref(prefsDict, @"dockBarrier", YES);
    dockGravity = getBoolPref(prefsDict, @"dockGravity", NO);
    shouldWidgetsFall = getBoolPref(prefsDict, @"widgetsFall", YES);

    if (prefsDict && prefsDict[@"bounciness"] != nil) {
        bounciness = [prefsDict[@"bounciness"] doubleValue];
    } else {
        CFPropertyListRef bRef = CFPreferencesCopyAppValue(CFSTR("bounciness"), (__bridge CFStringRef)kPrefsDomain);
        if (bRef) {
            if (CFGetTypeID(bRef) == CFNumberGetTypeID()) {
                bounciness = [(__bridge NSNumber *)bRef doubleValue];
            }
            CFRelease(bRef);
        }
    }
    if (bounciness < 0.0) bounciness = 0.0;
    if (bounciness > 1.0) bounciness = 1.0;
}

// #pragma mark - App Label Visibility Helper

static void setIconLabelsHidden(UIView *view, BOOL hidden, BOOL animated) {
    void (^applyAlpha)(void) = ^{
        if ([view respondsToSelector:@selector(setIconLabelAlpha:)]) {
            [(SBIconView *)view setIconLabelAlpha:(hidden ? 0.0 : 1.0)];
        }
        for (UIView *sub in view.subviews) {
            NSString *cls = NSStringFromClass([sub class]);
            if ([cls containsString:@"Label"] || [cls containsString:@"Legibility"]) {
                sub.alpha = hidden ? 0.0 : 1.0;
            }
        }
    };
    if (animated) {
        [UIView animateWithDuration:0.35
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:applyAlpha
                         completion:nil];
    } else {
        applyAlpha();
    }
}

// #pragma mark - Check if Home Screen is Currently Active

static BOOL isHomeScreenVisible(void) {
    // 1. If an application is currently frontmost, we are inside an app!
    SpringBoard *sb = (SpringBoard *)[UIApplication sharedApplication];
    if ([sb respondsToSelector:@selector(_accessibilityFrontMostApplication)]) {
        if ([sb _accessibilityFrontMostApplication] != nil) {
            return NO; // Inside an application, do NOT trigger!
        }
    }

    // 2. If locked or screen is off, do NOT trigger
    SBLockScreenManager *lockScreenMgr = [%c(SBLockScreenManager) sharedInstance];
    if (lockScreenMgr) {
        if ([lockScreenMgr respondsToSelector:@selector(isLockScreenVisible)] && [lockScreenMgr isLockScreenVisible]) {
            return NO;
        }
        if ([lockScreenMgr respondsToSelector:@selector(isUILocked)] && [lockScreenMgr isUILocked]) {
            return NO;
        }
    }

    // 3. If CoverSheet / Notification Center is pulled down, do NOT trigger
    id coverSheet = [%c(SBCoverSheetPresentationManager) sharedInstance];
    if (coverSheet && [coverSheet respondsToSelector:@selector(hasContentUnderCoverSheet)]) {
        if ([coverSheet hasContentUnderCoverSheet]) {
            return NO;
        }
    }

    // 4. Verify that the Home Screen window is visible
    BOOL foundVisibleHomeWindow = NO;
    for (UIWindow *win in [[UIApplication sharedApplication] windows]) {
        if ([win isKindOfClass:%c(SBHomeScreenWindow)]) {
            if (!win.hidden && win.alpha > 0.05) {
                foundVisibleHomeWindow = YES;
                break;
            }
        }
    }

    return foundVisibleHomeWindow;
}

// #pragma mark - Shake Trigger Handler

static void handleShakeTrigger(void) {
    NSTimeInterval now = CACurrentMediaTime();
    if (now - lastShakeTimestamp < 0.7) {
        return; // Debounce rapid shakes
    }
    lastShakeTimestamp = now;

    if (!isTweakEnabled) return;

    // CRITICAL: Only trigger when ON HOME SCREEN (no app open!)
    if (!isHomeScreenVisible()) {
        return;
    }

    // Do not trigger while editing icons (jiggle mode)
    SBIconController *iconController = [%c(SBIconController) sharedInstance];
    if (iconController && [iconController respondsToSelector:@selector(isEditing)] && [iconController isEditing]) {
        return;
    }

    // Completely silent - NO vibration, NO haptics!

    // Broadcast toggle event to active icon list view
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GravitationToggleNotification" object:nil];
}

// #pragma mark - Hardware Accelerometer Shake Detector (CoreMotion Fallback)

static void startHardwareShakeDetector(void) {
    if (hardwareShakeDetector) return;

    hardwareShakeDetector = [[CMMotionManager alloc] init];
    if (hardwareShakeDetector.isAccelerometerAvailable) {
        // 30 Hz polling uses negligible CPU/battery
        hardwareShakeDetector.accelerometerUpdateInterval = 1.0 / 30.0;
        [hardwareShakeDetector startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue]
                                                    withHandler:^(CMAccelerometerData * _Nullable data, NSError * _Nullable error) {
            if (error || !data) return;

            // Only evaluate shake if on Home Screen
            if (!isHomeScreenVisible()) {
                return;
            }

            double x = data.acceleration.x;
            double y = data.acceleration.y;
            double z = data.acceleration.z;
            double gForce = sqrt(x * x + y * y + z * z);

            // Resting device = 1.0g. Deliberate physical shake produces spikes > 2.2g.
            if (gForce > 2.2) {
                handleShakeTrigger();
            }
        }];
    }
}

// #pragma mark - UIKit Motion Shake Hook (Only Home Screen Window)

%hook SBHomeScreenWindow

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    %orig;
    if (motion == UIEventSubtypeMotionShake || (event && event.type == 1 && event.subtype == 1)) {
        handleShakeTrigger();
    }
}

%end

%hook SpringBoard

- (void)applicationDidFinishLaunching:(id)application {
    %orig;
    startHardwareShakeDetector();
}

%end

// #pragma mark - SBIconView Hook (Collision Shape & App Launch)

%hook SBIconView

- (UIDynamicItemCollisionBoundsType)collisionBoundsType {
    if (isGlobalGravityActive) {
        return UIDynamicItemCollisionBoundsTypePath;
    }
    if ([%c(UIView) instancesRespondToSelector:@selector(collisionBoundsType)]) {
        return %orig;
    }
    return UIDynamicItemCollisionBoundsTypeRectangle;
}

- (UIBezierPath *)collisionBoundingPath {
    if (isGlobalGravityActive) {
        CGRect b = self.bounds;
        CGFloat w = b.size.width;
        CGFloat h = b.size.height;

        if (shouldHideLabels) {
            // When labels are hidden: Hitbox is EXACTLY the square icon image (w x w)
            // This completely ELIMINATES the empty 30pt gap below icons!
            return [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0.0, 0.0, w, w) cornerRadius:14.0];
        } else {
            // When labels are visible: ENLARGED HITBOX!
            // Add comfortable horizontal padding so the label text is fully enclosed within the hitbox!
            // Adjacent icons cannot touch the label text, preventing overlap.
            CGFloat pad = 8.0;
            return [UIBezierPath bezierPathWithRoundedRect:CGRectMake(-pad, 0.0, w + (pad * 2.0), h + 2.0) cornerRadius:14.0];
        }
    }
    if ([%c(UIView) instancesRespondToSelector:@selector(collisionBoundingPath)]) {
        return %orig;
    }
    return [UIBezierPath bezierPathWithRect:self.bounds];
}

- (void)_handleTap:(id)arg1 {
    if (isGlobalGravityActive) {
        // App is opening! Cleanly restore icons so the home screen is ready when returning
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GravitationRestoreNotification" object:nil];
    }
    %orig;
}

%end

%hook SBIconController

- (void)iconWasTapped:(id)arg1 {
    if (isGlobalGravityActive) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GravitationRestoreNotification" object:nil];
    }
    %orig;
}

%end

// #pragma mark - SBIconListView Hook

%hook SBIconListView

%property (nonatomic, assign) BOOL isGravitySimulating;
%property (nonatomic, strong) UIDynamicAnimator *gravityAnimator;
%property (nonatomic, strong) UIGravityBehavior *gravityBehavior;
%property (nonatomic, strong) UICollisionBehavior *gravityCollisionBehavior;
%property (nonatomic, strong) UIDynamicItemBehavior *gravityItemBehavior;
%property (nonatomic, strong) UIFieldBehavior *gravityFingerBehavior;
%property (nonatomic, strong) CMMotionManager *gravityMotionManager;
%property (nonatomic, strong) NSMutableArray *gravityFallingViews;

- (void)didMoveToWindow {
    %orig;
    if (self.window && !objc_getAssociatedObject(self, "gravitation_observed")) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(gravitation_handleToggleNotification)
                                                     name:@"GravitationToggleNotification"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(gravitation_handleRestoreNotification)
                                                     name:@"GravitationRestoreNotification"
                                                   object:nil];
        objc_setAssociatedObject(self, "gravitation_observed", @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (void)layoutIconsNow {
    if (self.isGravitySimulating) {
        return; // Do not disrupt active physics animation
    }
    %orig;

    if (!objc_getAssociatedObject(self, "gravitation_observed")) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(gravitation_handleToggleNotification)
                                                     name:@"GravitationToggleNotification"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(gravitation_handleRestoreNotification)
                                                     name:@"GravitationRestoreNotification"
                                                   object:nil];
        objc_setAssociatedObject(self, "gravitation_observed", @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (void)layoutSubviews {
    if (self.isGravitySimulating) {
        return;
    }
    %orig;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GravitationToggleNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GravitationRestoreNotification" object:nil];
    %orig;
}

// Notification handler for shake toggle
%new
- (void)gravitation_handleToggleNotification {
    // If this list view is already simulating gravity, stop it and restore icons
    if (self.isGravitySimulating) {
        [self stopGravitySimulation];
        return;
    }

    // Must be in a window and visible
    if (!self.window || self.hidden || self.alpha < 0.05) {
        return;
    }

    // Handle Dock icon list view
    if ([self isKindOfClass:%c(SBDockIconListView)]) {
        if (!dockGravity) {
            return; // Dock gravity is disabled by user in settings
        }
    } else {
        // Normal page list view: check if currently visible on screen (not an offscreen page)
        CGRect screenBounds = [UIScreen mainScreen].bounds;
        CGRect frameInWindow = [self convertRect:self.bounds toView:nil];
        if (frameInWindow.origin.x < -60 || frameInWindow.origin.x > screenBounds.size.width - 60) {
            return; // Offscreen page in horizontal scroll view
        }
    }

    if (self.bounds.size.width < 50 || self.bounds.size.height < 50) {
        return;
    }

    // Start gravity on this visible icon list
    [self startGravitySimulation];
}

// Handler for when an app is launched (automatically restore icons cleanly)
%new
- (void)gravitation_handleRestoreNotification {
    if (self.isGravitySimulating) {
        [self stopGravitySimulation];
    }
}

// Helper to disable parent page scroll view during gravity
%new
- (void)setPageScrollingEnabled:(BOOL)enabled {
    UIView *parent = self.superview;
    while (parent != nil) {
        if ([parent isKindOfClass:[UIScrollView class]]) {
            ((UIScrollView *)parent).scrollEnabled = enabled;
            break;
        }
        parent = parent.superview;
    }
}

// #pragma mark - Start Gravity Simulation (Smooth, Fluid Gliding Motion)

%new
- (void)startGravitySimulation {
    if (self.isGravitySimulating) return;

    self.isGravitySimulating = YES;
    isGlobalGravityActive = YES;

    // Freeze page scrolling so iOS doesn't virtualize/unload views mid-fall
    [self setPageScrollingEnabled:NO];

    NSMutableArray<UIView *> *fallingViews = [NSMutableArray array];
    NSMutableArray<UIView *> *obstacleViews = [NSMutableArray array];

    for (UIView *subview in self.subviews) {
        if (subview.hidden || subview.alpha < 0.05 || CGRectIsEmpty(subview.frame)) continue;

        BOOL isIconView = [subview isKindOfClass:%c(SBIconView)];
        BOOL isWidgetContainer = [subview isKindOfClass:%c(SBHWidgetContainerView)];
        if (!isIconView && !isWidgetContainer) continue;

        BOOL isWidget = isWidgetContainer;
        if (isIconView) {
            SBIcon *icon = [(SBIconView *)subview respondsToSelector:@selector(icon)] ? [(SBIconView *)subview icon] : nil;
            if (icon && [icon respondsToSelector:@selector(isWidgetIcon)] && [icon isWidgetIcon]) {
                isWidget = YES;
            }
        }

        // SAVE EXACT PRE-PHYSICS GEOMETRY (ZERO WRONG PLACEMENT BUGS ON RETURN)
        objc_setAssociatedObject(subview, kOriginalCenterKey, [NSValue valueWithCGPoint:subview.center], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(subview, kOriginalTransformKey, [NSValue valueWithCGAffineTransform:subview.transform], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(subview, kOriginalBoundsKey, [NSValue valueWithCGRect:subview.bounds], OBJC_ASSOCIATION_RETAIN_NONATOMIC);

        if (isWidget && !shouldWidgetsFall) {
            // Widget remains as solid obstacle boundary
            [obstacleViews addObject:subview];
        } else {
            // Falls with full gravity physics
            [fallingViews addObject:subview];

            // Only hide labels if user explicitly enabled it in settings
            if (shouldHideLabels) {
                setIconLabelsHidden(subview, YES, YES);
            }
        }
    }

    if (fallingViews.count == 0) {
        self.isGravitySimulating = NO;
        isGlobalGravityActive = NO;
        [self setPageScrollingEnabled:YES];
        return;
    }

    self.gravityFallingViews = fallingViews;

    // 1. UIDynamicAnimator
    UIDynamicAnimator *animator = [[UIDynamicAnimator alloc] initWithReferenceView:self];
    self.gravityAnimator = animator;

    // 2. Gravity Behavior (smooth, natural slide like original Gravitation)
    UIGravityBehavior *gravity = [[UIGravityBehavior alloc] initWithItems:fallingViews];
    gravity.magnitude = 1.0; // Natural 1.0g fall instead of abrupt drop
    [animator addBehavior:gravity];
    self.gravityBehavior = gravity;

    // 3. Collision Behavior
    UICollisionBehavior *collision = [[UICollisionBehavior alloc] initWithItems:fallingViews];
    collision.translatesReferenceBoundsIntoBoundary = YES;
    collision.collisionMode = UICollisionBehaviorModeEverything;

    CGFloat screenW = self.bounds.size.width;
    CGFloat screenH = self.bounds.size.height;
    CGRect screenBounds = [UIScreen mainScreen].bounds;

    // Only apply top status bar and dock barriers to regular home screen pages (not inside dock itself)
    if (![self isKindOfClass:%c(SBDockIconListView)]) {
        // DYNAMIC ISLAND HITBOX (iPhone 14 Pro / 14 Pro Max / 15 / 16)
        if (dynamicIslandCollision && screenBounds.size.width >= 375.0) {
            CGFloat diWidth = 126.0;
            CGFloat diHeight = 37.0;
            CGFloat diX = (screenBounds.size.width - diWidth) / 2.0;
            CGFloat diY = 11.0;

            CGPoint pTL = [self convertPoint:CGPointMake(diX, diY) fromView:nil];
            CGPoint pTR = [self convertPoint:CGPointMake(diX + diWidth, diY) fromView:nil];
            CGPoint pBL = [self convertPoint:CGPointMake(diX, diY + diHeight) fromView:nil];
            CGPoint pBR = [self convertPoint:CGPointMake(diX + diWidth, diY + diHeight) fromView:nil];

            // 4 solid boundary edges around Dynamic Island
            [collision addBoundaryWithIdentifier:@"DIBottom" fromPoint:pBL toPoint:pBR];
            [collision addBoundaryWithIdentifier:@"DITop" fromPoint:pTL toPoint:pTR];
            [collision addBoundaryWithIdentifier:@"DILeft" fromPoint:pTL toPoint:pBL];
            [collision addBoundaryWithIdentifier:@"DIRight" fromPoint:pTR toPoint:pBR];

            // Also add rounded capsule path
            CGRect diRect = CGRectMake(pTL.x, pTL.y, diWidth, diHeight);
            UIBezierPath *diPath = [UIBezierPath bezierPathWithRoundedRect:diRect cornerRadius:18.5];
            [collision addBoundaryWithIdentifier:@"DIPill" forPath:diPath];
        }

        // TOP STATUS BAR HITBOXES (Protects Clock on top-left and Battery on top-right)
        if (statusBarCollision) {
            CGFloat timeW = 115.0;
            CGFloat timeH = 54.0;
            CGPoint tTL = [self convertPoint:CGPointMake(0.0, 0.0) fromView:nil];
            CGPoint tTR = [self convertPoint:CGPointMake(timeW, 0.0) fromView:nil];
            CGPoint tBL = [self convertPoint:CGPointMake(-50.0, timeH) fromView:nil];
            CGPoint tBR = [self convertPoint:CGPointMake(timeW, timeH) fromView:nil];

            [collision addBoundaryWithIdentifier:@"TimeBottom" fromPoint:tBL toPoint:tBR];
            [collision addBoundaryWithIdentifier:@"TimeRight" fromPoint:tTR toPoint:tBR];

            CGFloat battW = 115.0;
            CGFloat battH = 54.0;
            CGPoint bTL = [self convertPoint:CGPointMake(screenBounds.size.width - battW, 0.0) fromView:nil];
            CGPoint bBL = [self convertPoint:CGPointMake(screenBounds.size.width - battW, battH) fromView:nil];
            CGPoint bBR = [self convertPoint:CGPointMake(screenBounds.size.width + 50.0, battH) fromView:nil];

            [collision addBoundaryWithIdentifier:@"BatteryBottom" fromPoint:bBL toPoint:bBR];
            [collision addBoundaryWithIdentifier:@"BatteryLeft" fromPoint:bTL toPoint:bBL];
        }

        // DOCK BARRIER (Floor barrier vs falling behind dock)
        CGFloat dockTopInView = screenH;
        SBIconController *ic = [%c(SBIconController) sharedInstance];
        UIView *dockView = nil;
        if (ic && [ic respondsToSelector:@selector(rootFolderController)]) {
            SBRootFolderController *rfc = [ic rootFolderController];
            if (rfc) {
                SBIconListView *dockList = nil;
                if ([rfc respondsToSelector:@selector(dockIconListView)]) {
                    dockList = [rfc dockIconListView];
                } else if ([rfc respondsToSelector:@selector(dockListView)]) {
                    dockList = [rfc dockListView];
                }
                if (dockList) dockView = dockList.superview ?: dockList;
            }
        }

        if (dockView && dockView.window) {
            CGRect dockFrameInWindow = [dockView convertRect:dockView.bounds toView:nil];
            CGRect dockFrameInList = [self convertRect:dockFrameInWindow fromView:nil];
            dockTopInView = dockFrameInList.origin.y;
        } else {
            CGPoint fallbackPt = [self convertPoint:CGPointMake(0, screenBounds.size.height - 120.0) fromView:nil];
            dockTopInView = fallbackPt.y;
        }

        if (dockBarrier) {
            // Solid floor: icons bounce on top of the dock and do NOT fall behind it
            [collision addBoundaryWithIdentifier:@"DockBarrierFloor"
                                       fromPoint:CGPointMake(-100.0, dockTopInView)
                                         toPoint:CGPointMake(screenW + 100.0, dockTopInView)];
        } else {
            // Allow icons to fall behind the dock to the bottom of the screen
            CGPoint screenBottomPt = [self convertPoint:CGPointMake(0, screenBounds.size.height) fromView:nil];
            CGFloat actualBottom = MAX(screenH, screenBottomPt.y);
            [collision addBoundaryWithIdentifier:@"ScreenBottomBehindDock"
                                       fromPoint:CGPointMake(-100.0, actualBottom)
                                         toPoint:CGPointMake(screenW + 100.0, actualBottom)];
        }
    }

    // Static widget obstacle boundaries (if widgets fall option is disabled)
    for (UIView *obs in obstacleViews) {
        UIBezierPath *obsPath = [UIBezierPath bezierPathWithRoundedRect:obs.frame cornerRadius:22.0];
        [collision addBoundaryWithIdentifier:[NSString stringWithFormat:@"Widget_%p", obs] forPath:obsPath];
    }

    [animator addBehavior:collision];
    self.gravityCollisionBehavior = collision;

    // 4. Dynamic Item Behavior (Smooth Sliding Physics)
    UIDynamicItemBehavior *itemProps = [[UIDynamicItemBehavior alloc] initWithItems:fallingViews];
    itemProps.elasticity = bounciness;    // Soft, pleasant bounce (0.35)
    itemProps.friction = 0.30;            // Gentle surface friction
    itemProps.resistance = 0.45;          // Fluid air resistance so icons glide smoothly
    itemProps.angularResistance = 0.50;   // Controlled, smooth rotation
    itemProps.allowsRotation = YES;
    [animator addBehavior:itemProps];
    self.gravityItemBehavior = itemProps;

    // 5. Accelerometer / Gyroscope (CoreMotion)
    CMMotionManager *mgr = [[CMMotionManager alloc] init];
    self.gravityMotionManager = mgr;
    if (mgr.isDeviceMotionAvailable) {
        mgr.deviceMotionUpdateInterval = 1.0 / 60.0;
        __weak typeof(self) weakSelf = self;
        [mgr startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue]
                                 withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
            if (error || !motion || !weakSelf || !weakSelf.gravityBehavior) return;
            // Smooth, natural physics vector
            CGFloat gx = motion.gravity.x * 1.2;
            CGFloat gy = -motion.gravity.y * 1.2;
            weakSelf.gravityBehavior.gravityDirection = CGVectorMake(gx, gy);
        }];
    }
}

// #pragma mark - Stop Gravity & Smooth Return

%new
- (void)stopGravitySimulation {
    if (!self.isGravitySimulating) return;

    // 1. Stop Motion Updates
    if (self.gravityMotionManager) {
        [self.gravityMotionManager stopDeviceMotionUpdates];
        self.gravityMotionManager = nil;
    }

    // 2. Remove all physics behaviors
    if (self.gravityAnimator) {
        [self.gravityAnimator removeAllBehaviors];
    }
    self.gravityBehavior = nil;
    self.gravityCollisionBehavior = nil;
    self.gravityItemBehavior = nil;
    self.gravityFingerBehavior = nil;

    NSArray<UIView *> *viewsToRestore = [self.gravityFallingViews copy];
    self.gravityFallingViews = nil;

    // 3. Smooth, natural spring return animation with pleasant bounce (no jerk at the end)
    [UIView animateWithDuration:0.85
                          delay:0.0
         usingSpringWithDamping:0.76
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
        for (UIView *view in viewsToRestore) {
            NSValue *centerVal = objc_getAssociatedObject(view, kOriginalCenterKey);
            NSValue *boundsVal = objc_getAssociatedObject(view, kOriginalBoundsKey);
            if (centerVal) {
                view.transform = CGAffineTransformIdentity;
                view.center = [centerVal CGPointValue];
            }
            if (boundsVal) {
                view.bounds = [boundsVal CGRectValue];
            }
            // Smoothly fade labels back in as icons return to original spots
            if (shouldHideLabels) {
                setIconLabelsHidden(view, NO, NO);
            }
        }
    } completion:^(BOOL finished) {
        // Clean up associated memory and guarantee 100% label alpha
        for (UIView *view in viewsToRestore) {
            objc_setAssociatedObject(view, kOriginalCenterKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            objc_setAssociatedObject(view, kOriginalTransformKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            objc_setAssociatedObject(view, kOriginalBoundsKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            if (shouldHideLabels) {
                setIconLabelsHidden(view, NO, NO);
            }
        }

        self.gravityAnimator = nil;
        self.isGravitySimulating = NO;
        isGlobalGravityActive = NO;

        // Restore page scrolling
        [self setPageScrollingEnabled:YES];

        // Mark layout as clean without forcing an un-animated snap
        [self setNeedsLayout];
    }];
}

// #pragma mark - Touch & Finger Gravity

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.isGravitySimulating && isFingerGravityEnabled) {
        UITouch *touch = [touches anyObject];
        CGPoint p = [touch locationInView:self];
        if (!self.gravityFingerBehavior) {
            UIFieldBehavior *field = [UIFieldBehavior radialGravityFieldWithPosition:p];
            field.strength = 35.0;
            field.minimumRadius = 80.0;
            field.falloff = 1.0;
            field.region = [UIRegion infiniteRegion];
            for (UIView *v in self.gravityFallingViews) {
                [field addItem:v];
            }
            [self.gravityAnimator addBehavior:field];
            self.gravityFingerBehavior = field;
        } else {
            self.gravityFingerBehavior.position = p;
        }
        return;
    }
    %orig;
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.isGravitySimulating && isFingerGravityEnabled) {
        UITouch *touch = [touches anyObject];
        CGPoint p = [touch locationInView:self];
        if (self.gravityFingerBehavior) {
            self.gravityFingerBehavior.position = p;
            if (touch.force > 0) {
                self.gravityFingerBehavior.strength = 35.0 * (1.0 + touch.force);
            }
        }
        return;
    }
    %orig;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.gravityFingerBehavior) {
        [self.gravityAnimator removeBehavior:self.gravityFingerBehavior];
        self.gravityFingerBehavior = nil;
    }
    if (!self.isGravitySimulating) {
        %orig;
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self touchesEnded:touches withEvent:event];
}

%end

// #pragma mark - Constructor

%ctor {
    loadPreferences();

    CFNotificationCenterAddObserver(
        CFNotificationCenterGetDarwinNotifyCenter(),
        NULL,
        (CFNotificationCallback)loadPreferences,
        (__bridge CFStringRef)kPrefsChangedNotification,
        NULL,
        CFNotificationSuspensionBehaviorDeliverImmediately
    );

    // Initialize the hardware shake detector
    startHardwareShakeDetector();

    NSLog(@"[Gravitation] Loaded successfully with PreferenceLoader support for iOS 16 (RootHide & Rootless)");
}
