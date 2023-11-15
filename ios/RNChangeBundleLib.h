
#if __has_include("RCTBridgeModule.h")
#import "RCTBridgeModule.h"
#else
#import <React/RCTBridgeModule.h>
#endif

#if __has_include("RCTReloadCommand.h")
#import "RCTReloadCommand.h"
#else
#import <React/RCTReloadCommand.h>
#endif


@class RNChangeBundleLib;
@interface RNChangeBundleLib : NSObject <RCTBridgeModule>

+ (NSURL *_Nonnull)bundleURL;

+ (void)setDefaultBundleURL:(NSURL *_Nonnull)URL;

+ (NSError *_Nullable)addBundle:(NSString *_Nonnull)bundleId pathForBundle:(NSString *_Nonnull)bundlePath pathForAssets:(NSString *_Nonnull)assetsPath;
- (void)addBundlePromise:(NSString *_Nonnull)bundleId pathForBundle:(NSString *_Nonnull)bundlePath pathForAssets:(NSString *_Nonnull)assetsPath withResolver: (RCTPromiseResolveBlock _Nonnull )resolve withRejecter: (RCTPromiseRejectBlock _Nonnull )reject;

+ (NSError *_Nullable)deleteBundle:(NSString *_Nonnull)bundleId;
- (void)deleteBundlePromise:(NSString *_Nonnull)bundleId withResolver: (RCTPromiseResolveBlock _Nonnull )resolve withRejecter: (RCTPromiseRejectBlock _Nonnull )reject;

+ (NSDictionary *_Nonnull)getBundles;
- (void)getBundlesPromise:(RCTPromiseResolveBlock _Nonnull )resolve withRejecter: (RCTPromiseRejectBlock _Nonnull )reject;

+ (NSString *_Nonnull)getActiveBundle;
- (void)getActiveBundlePromise:(RCTPromiseResolveBlock _Nonnull )resolve withRejecter: (RCTPromiseRejectBlock _Nonnull )reject;

+ (void)activateBundle:(NSString *_Nonnull)bundleId;
- (void)activateBundlePromise:(NSString *_Nonnull)bundleId withResolver: (RCTPromiseResolveBlock _Nonnull )resolve withRejecter: (RCTPromiseRejectBlock _Nonnull )reject;

+ (void)notifyIfUpdateApplies;
- (void)notifyIfUpdateAppliesPromise:(RCTPromiseResolveBlock _Nonnull )resolve withRejecter: (RCTPromiseRejectBlock _Nonnull )reject;

+ (void)reload;
- (void)reloadPromise:(RCTPromiseResolveBlock _Nonnull )resolve withRejecter: (RCTPromiseRejectBlock _Nonnull )reject;

@end
