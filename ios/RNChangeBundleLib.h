
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

+ (NSURL *)bundleURL;
+ (NSMutableDictionary *)loadRegistry;
+ (void)storeRegistry:(NSDictionary *)dict;
+ (NSURL *)resolveBundleURL;
+ (void)setDefaultBundleURL:(NSURL *)URL;

- (void)reloadBundle;
- (void)registerBundle:(NSString *)bundleId atRelativePath:(NSString *)path;
- (void)unregisterBundle:(NSString *)bundleId;
- (void)setActiveBundle:(NSString *)bundleId;
- (NSDictionary *)getBundles;
- (bool)resetAllBundlesBetweenVersion;
- (NSString *)getActiveBundle;

@end
