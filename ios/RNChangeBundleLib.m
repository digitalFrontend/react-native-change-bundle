#import <React/RCTBridgeModule.h>
#import "RNChangeBundleLib.h"

static NSString * const nameBundleList = @"bundleList";

static NSString * const kBundleRegistryStoreFilename = @"_RNDynamicBundleRestores.plist";


@interface RNChangeBundleLib () <RCTBridgeModule>
@end

static NSURL *_defaultBundleURL = nil;

@implementation RNChangeBundleLib {

}

static NSBundle *bundleResourceBundle = nil;
static NSString *bundleResourceExtension = @"jsbundle";
static NSString *bundleResourceName = @"main";
static NSString *bundleResourceSubdirectory = nil;

+ (void)initialize
{
    [super initialize];
    if (self == [RNChangeBundleLib class]) {
        // Use the mainBundle by default.
        bundleResourceBundle = [NSBundle mainBundle];
    }
}

+ (NSURL *)bundleURL
{
    return [self bundleURLForResource:bundleResourceName
                        withExtension:bundleResourceExtension
                         subdirectory:bundleResourceSubdirectory
                               bundle:bundleResourceBundle];
}

+ (NSURL *)bundleURLForResource:(NSString *)resourceName
                  withExtension:(NSString *)resourceExtension
                   subdirectory:(NSString *)resourceSubdirectory
                         bundle:(NSBundle *)resourceBundle
{
    NSMutableDictionary *dict = [RNChangeBundleLib loadRegistry];
    NSString *name = [RNChangeBundleLib getNameBundle];
    NSString *activeBundles = dict[name]==nil ? @"" : dict[name];
    
    if ([activeBundles isEqualToString:@""]) {
        return _defaultBundleURL;
    }
    
    NSString *bundleRelativePath = dict[nameBundleList][activeBundles];
    if (bundleRelativePath == nil) {
        return _defaultBundleURL;
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:bundleRelativePath];
   
    return [NSURL fileURLWithPath:path];
}

+ (NSMutableDictionary *)loadRegistry
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:kBundleRegistryStoreFilename];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path]) {
        return [RNChangeBundleLib createEmptyRegistry];
    } else {
        return [NSMutableDictionary dictionaryWithContentsOfFile:path];
    }
}

+ (NSMutableDictionary *)createEmptyRegistry {

    NSString *name = [RNChangeBundleLib getNameBundle];
//        NSDictionary *defaults = @{
//            @"bundleList": [NSMutableDictionary dictionary]
//        };
    NSMutableDictionary *defaults = [[NSMutableDictionary alloc] init];
    defaults[nameBundleList] = [NSMutableDictionary dictionary];
    defaults[name] = @"";
    //[defaults setValue:@"" forUndefinedKey:name];
    return [defaults mutableCopy];
}

+ (NSString *) getBuildId {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

+ (NSString *)getNameBundle {
    NSString *buildId = [RNChangeBundleLib getBuildId];
    NSString *name = [NSString stringWithFormat: @"%@%@", buildId, @"-activeBundles"];
    return name;
}

+ (void)setDefaultBundleURL:(NSURL *)URL
{
    _defaultBundleURL = URL;
}

- (bool)resetAllBundlesBetweenVersion {
    NSMutableDictionary *dict = [RNChangeBundleLib createEmptyRegistry];
    [RNChangeBundleLib storeRegistry:dict];
    return true;
}

+ (void)storeRegistry:(NSDictionary *)dict
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:kBundleRegistryStoreFilename];
    
    [dict writeToFile:path atomically:YES];
}

- (void)reloadBundle
{
    if ([NSThread isMainThread]) {
        RCTTriggerReloadCommandListeners(@"react-native-restart: Restart");
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            RCTTriggerReloadCommandListeners(@"react-native-restart: Restart");
        });
    }
    return;
}

- (void)registerBundle:(NSString *)bundleId atRelativePath:(NSString *)relativePath
{
    NSMutableDictionary *dict = [RNChangeBundleLib loadRegistry];
    dict[nameBundleList][bundleId] = relativePath;
    [RNChangeBundleLib storeRegistry:dict];
}

- (void)unregisterBundle:(NSString *)bundleId
{
    NSMutableDictionary *dict = [RNChangeBundleLib loadRegistry];
    NSMutableDictionary *bundlesDict = dict[nameBundleList];
    [bundlesDict removeObjectForKey:bundleId];
    [RNChangeBundleLib storeRegistry:dict];
}

- (void)setActiveBundle:(NSString *)bundleId
{
    NSMutableDictionary *dict = [RNChangeBundleLib loadRegistry];
    NSString *name = [RNChangeBundleLib getNameBundle];
    //dict[name] = bundleId == nil ? @"" : bundleId;
    [dict setValue:bundleId == nil ? @"" : bundleId forKey:name];
    [RNChangeBundleLib storeRegistry:dict];
}

- (NSDictionary *)getBundles
{
    NSMutableDictionary *bundleList = [NSMutableDictionary dictionary];
    NSMutableDictionary *dict = [RNChangeBundleLib loadRegistry];
    for (NSString *bundleId in dict[nameBundleList]) {
        NSString *relativePath = dict[bundleId];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths firstObject];
        NSString *path = [documentsDirectory stringByAppendingPathComponent:relativePath];
        NSURL *URL = [NSURL fileURLWithPath:path];
        
        bundleList[bundleId] = [URL absoluteString];
    }
    
    return bundleList;
}

- (NSString *)getActiveBundle
{
    NSMutableDictionary *dict = [RNChangeBundleLib loadRegistry];
    NSString *name = [RNChangeBundleLib getNameBundle];
    NSString *activeBundles = dict[name]!=nil ? dict[name] : @"";
    if ([activeBundles isEqualToString:@""]) {
        return nil;
    }
    
    return activeBundles;
}

RCT_REMAP_METHOD(reloadBundle, exportedReloadBundle)
{
    [self reloadBundle];
}

RCT_REMAP_METHOD(registerBundle, exportedRegisterBundle:(NSString *)bundleId atRelativePath:(NSString *)path)
{
    [self registerBundle:bundleId atRelativePath:path];
}

RCT_REMAP_METHOD(unregisterBundle, exportedUnregisterBundle:(NSString *)bundleId)
{
    [self unregisterBundle:bundleId];
}

RCT_REMAP_METHOD(setActiveBundle, exportedSetActiveBundle:(NSString *)bundleId)
{
    [self setActiveBundle:bundleId];
}

RCT_REMAP_METHOD(resetAllBundlesBetweenVersion,
                 exportedresetAllBundlesBetweenVersionWithResolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    bool completed = [self resetAllBundlesBetweenVersion];
    resolve(@(completed));
}

RCT_REMAP_METHOD(getBundles,
                 exportedGetBundlesWithResolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    resolve([self getBundles]);
}

RCT_REMAP_METHOD(getActiveBundle,
                 exportedGetActiveBundleWithResolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    NSString *activeBundles = [self getActiveBundle];
    if (activeBundles == nil) {
        resolve([NSNull null]);
    } else {
        resolve(activeBundles);
    }
}

RCT_EXPORT_MODULE()


@end
