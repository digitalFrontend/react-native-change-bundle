#import <React/RCTBridgeModule.h>
#import "RNChangeBundleLib.h"

static NSString * const nameBundleList = @"bundleList";
static NSString * const bundlesFolderName = @"bundles";
static NSString * const assetsFolderName = @"assets";
static NSString * const bundleFileName = @"main.jsbundle";
static NSString * const activeBundleName = @"activeBundle";
static NSString * const storeFileName = @"_RNChangeBundle.plist";


@interface RNChangeBundleFS () <RCTBridgeModule>
@end

static NSURL *_defaultBundleURL = nil;

@implementation RNChangeBundleFS {

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
    
    
    NSMutableDictionary *dict = [RNChangeBundleLib loadStore];
    
    if ([dict[activeBundleName] isEqualToString: @""]){
        return _defaultBundleURL;
    } else {
        return _defaultBundleURL;
    }
    
    
//    NSString *bundleRelativePath = dict[nameBundleList][activeBundles];
//    if (bundleRelativePath == nil) {
//        return _defaultBundleURL;
//    }
//    
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths firstObject];
//    NSString *path = [documentsDirectory stringByAppendingPathComponent:bundleRelativePath];
//   
//    return [NSURL fileURLWithPath:path];
}

+ (NSMutableDictionary *)loadStore
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:storeFileName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path]) {
        return [RNChangeBundleLib createEmptyStore];
    } else {
        return [NSMutableDictionary dictionaryWithContentsOfFile:path];
    }
}

+ (NSMutableDictionary *)createEmptyStore {

    NSMutableDictionary *defaults = [[NSMutableDictionary alloc] init];
    defaults[nameBundleList] = [NSMutableDictionary dictionary];
    defaults[activeBundleName] = @"";
    return [defaults mutableCopy];
}

//+ (NSString *) getBuildId {
//    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
//}

//+ (NSString *)getNameBundle {
//    NSString *buildId = [RNChangeBundleLib getBuildId];
//    NSString *name = [NSString stringWithFormat: @"%@%@", buildId, @"-activeBundles"];
//    return name;
//}

+ (void)setDefaultBundleURL:(NSURL *)URL
{
    _defaultBundleURL = URL;
}

- (bool)resetAllBundlesBetweenVersion {
    NSMutableDictionary *dict = [RNChangeBundleLib createEmptyStore];
    [RNChangeBundleLib saveStore:dict];
    return true;
}

+ (void)saveStore:(NSDictionary *)dict
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:storeFileName];
    
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

- (void)addBundle:(NSString *)bundleId pathForBundle:(NSString *)bundlePath pathForAssets:(NSString *)assetsPath withResolver: (RCTPromiseResolveBlock)resolve
     withRejecter: (RCTPromiseRejectBlock)reject
{
  
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    NSString *path = [[documentsDirectory stringByAppendingPathComponent:bundlesFolderName] stringByAppendingPathComponent:bundleId];
    NSLog(@"bundleTest 1");
    BOOL isDir = YES;
    BOOL isFolderExists = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];
    NSLog(@"bundleTest 2");
    NSError *error = nil;
    NSLog(@"bundleTest 3");
    if (isFolderExists == NO){
        NSLog(@"bundleTest 4");
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        NSLog(@"bundleTest 5");
        if (error != nil){
            NSLog(@"bundleTest 6");
            NSLog(@"error %@", error);
            reject(@"RNChangeBundleError",error.localizedDescription, error);
            return;
        }
    }
    
    NSLog(@"bundleTest 7");
    BOOL status = [[NSFileManager defaultManager] moveItemAtPath:bundlePath toPath:[path stringByAppendingPathComponent:bundleFileName] error:&error];
    NSLog(@"bundleTest 8");
    if (status == NO) {
        NSLog(@"bundleTest 9");
        reject(@"RNChangeBundleError",error.localizedDescription, error);
        return;
    }
    NSLog(@"bundleTest 10");
    status = [[NSFileManager defaultManager] moveItemAtPath:assetsPath toPath:[path stringByAppendingPathComponent:assetsFolderName] error:&error];
    NSLog(@"bundleTest 11");
    if (status == NO) {
        NSLog(@"bundleTest 12");
        reject(@"RNChangeBundleError",error.localizedDescription, error);
        return;
    }
    
    NSLog(@"bundleTest 13");
    NSMutableDictionary *dict = [RNChangeBundleLib loadStore];
    dict[bundleId] = path;
    [RNChangeBundleLib saveStore:dict];
    resolve(path);
}

- (void)registerBundle:(NSString *)bundleId atRelativePath:(NSString *)relativePath
{
    NSMutableDictionary *dict = [RNChangeBundleLib loadStore];
    dict[nameBundleList][bundleId] = relativePath;
    [RNChangeBundleLib saveStore:dict];
}

- (void)unregisterBundle:(NSString *)bundleId
{
    NSMutableDictionary *dict = [RNChangeBundleLib loadStore];
    NSMutableDictionary *bundlesDict = dict[nameBundleList];
    [bundlesDict removeObjectForKey:bundleId];
    [RNChangeBundleLib saveStore:dict];
}

- (void)setActiveBundle:(NSString *)bundleId
{
//    NSMutableDictionary *dict = [RNChangeBundleLib loadRegistry];
//    NSString *name = [RNChangeBundleLib getNameBundle];
//    //dict[name] = bundleId == nil ? @"" : bundleId;
//    [dict setValue:bundleId == nil ? @"" : bundleId forKey:name];
//    [RNChangeBundleLib storeRegistry:dict];
}

- (NSDictionary *)getBundles
{
    NSMutableDictionary *bundleList = [NSMutableDictionary dictionary];
    NSMutableDictionary *dict = [RNChangeBundleLib loadStore];
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
//    NSMutableDictionary *dict = [RNChangeBundleLib loadRegistry];
//    NSString *name = [RNChangeBundleLib getNameBundle];
//    NSString *activeBundles = dict[name]!=nil ? dict[name] : @"";
//    if ([activeBundles isEqualToString:@""]) {
//        return nil;
//    }
//    
//    return activeBundles;
    return @"";
}

RCT_REMAP_METHOD(addBundle, exportedAddBundle:(NSString *)bundleId pathForBundle:(NSString *)bundlePath  pathForAssets:(NSString *)assetsPath withResolver: (RCTPromiseResolveBlock)resolve
                 withRejecter: (RCTPromiseRejectBlock)reject)
{
    
    [self addBundle:bundleId pathForBundle:bundlePath pathForAssets:assetsPath withResolver:resolve withRejecter:reject];
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
