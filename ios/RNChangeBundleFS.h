
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


@class RNChangeBundleFS;
@interface RNChangeBundleLib : NSObject <RCTBridgeModule>

+ (NSURL *)bundleURL;
+ (NSMutableDictionary *)loadStore;
+ (void)saveStore:(NSDictionary *)dict;
+ (void)setDefaultBundleURL:(NSURL *)URL;
+ (void)addBundle:(NSString *)bundleId pathForBundle:(NSString *)bundlePath pathForAssets:(NSString *)assetsPath withResolver: (RCTPromiseResolveBlock)resolve
     withRejecter: (RCTPromiseRejectBlock)reject;

- (void)reloadBundle;
- (void)registerBundle:(NSString *)bundleId atRelativePath:(NSString *)path;
- (void)unregisterBundle:(NSString *)bundleId;
- (void)setActiveBundle:(NSString *)bundleId;
- (NSDictionary *)getBundles;
- (bool)resetAllBundlesBetweenVersion;
- (NSString *)getActiveBundle;

@end
