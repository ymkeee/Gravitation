#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreMotion/CoreMotion.h>
#import <AudioToolbox/AudioToolbox.h>
#import <objc/runtime.h>

#if __has_include(<roothide.h>)
#include <roothide.h>
#elif __has_include(<rootless.h>)
#include <rootless.h>
#else
#define jbroot(path) (path)
#endif

@class SBIcon, SBIconView, SBIconListModel, SBFolderController, SBRootFolderController;

@interface SBIcon : NSObject
- (BOOL)isWidgetIcon;
- (BOOL)isApplicationIcon;
- (BOOL)isFolderIcon;
- (NSString *)displayName;
@end

@interface SBIconView : UIView
@property (nonatomic, strong) SBIcon *icon;
- (BOOL)isWidgetIcon;
@end

@interface SBHWidgetContainerView : UIView
@end

@interface SBIconListView : UIView <UICollisionBehaviorDelegate>
@property (nonatomic, copy, readonly) NSArray *icons;
@property (nonatomic, strong, readonly) SBIconListModel *model;
- (void)layoutIconsNow;
- (void)setPageScrollingEnabled:(BOOL)enabled;

// Gravitation Properties
@property (nonatomic, assign) BOOL isGravitySimulating;
@property (nonatomic, strong) UIDynamicAnimator *gravityAnimator;
@property (nonatomic, strong) UIGravityBehavior *gravityBehavior;
@property (nonatomic, strong) UICollisionBehavior *gravityCollisionBehavior;
@property (nonatomic, strong) UIDynamicItemBehavior *gravityItemBehavior;
@property (nonatomic, strong) UIFieldBehavior *gravityFingerBehavior;
@property (nonatomic, strong) CMMotionManager *gravityMotionManager;
@property (nonatomic, strong) NSMutableArray<UIView *> *gravityFallingViews;

- (void)startGravitySimulation;
- (void)stopGravitySimulation;
- (void)gravitation_handleToggleNotification;
- (void)gravitation_handleRestoreNotification;
@end

@interface SBFolderController : NSObject
@property (nonatomic, readonly) SBIconListView *currentIconListView;
@property (nonatomic, readonly) SBIconListView *dockListView;
@property (nonatomic, readonly) SBIconListView *dockIconListView;
@end

@interface SBRootFolderController : SBFolderController
@end

@interface SBIconController : NSObject
+ (instancetype)sharedInstance;
@property (nonatomic, readonly) SBRootFolderController *rootFolderController;
@property (nonatomic, readonly) SBFolderController *openedFolderController;
- (BOOL)isEditing;
- (BOOL)isHomeScreenVisible;
@end

@interface SBCoverSheetPresentationManager : NSObject
+ (instancetype)sharedInstance;
- (BOOL)isVisible;
- (BOOL)hasContentUnderCoverSheet;
@end

@interface SBLockScreenManager : NSObject
+ (instancetype)sharedInstance;
- (BOOL)isLockScreenVisible;
- (BOOL)isUILocked;
- (BOOL)isScreenOn;
@end

@interface SpringBoard : UIApplication
+ (instancetype)sharedApplication;
- (id)_accessibilityFrontMostApplication;
@end

@interface SBHomeScreenWindow : UIWindow
@end
