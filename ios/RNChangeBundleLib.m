#import <React/RCTBridgeModule.h>
#import "RNChangeBundleLib.h"
#import "RNChangeBundleFS.h"

static NSString * const activeBundleName = @"activeBundle";
static NSString * const nameBundleList = @"bundleList";
static NSString * const nameWaitingReactStart = @"waitReactStart";
static NSString * const nameNativeBuildVersion = @"nativeBuildVersion";
static NSString * const nameShouldDropActiveVersion = @"shouldDropActiveVersion";


@interface RNChangeBundleLib () <RCTBridgeModule>
@end

static NSURL *_defaultBundleURL = nil;

@implementation RNChangeBundleLib {

}

+ (void)initialize
{
    [super initialize];
}

+ (NSURL *)bundleURL
{
    NSMutableDictionary *dict = [RNChangeBundleFS loadStore];
    
    // Если стоит дефолтный запуск
    if ([dict[activeBundleName] isEqualToString: @""]){
        return _defaultBundleURL;
    } else {
        
        //Если прошло нативное обновление или не указано
        if ([dict[nameNativeBuildVersion] isEqualToString: @""] || [dict[nameNativeBuildVersion] isEqualToString: [RNChangeBundleLib getBuildId]]){
            // Если нативного обновления не было
            // Если стоит запуск кастомного бандла
            NSString *path = [RNChangeBundleFS getBundleFileNameForBundleId:dict[activeBundleName]];
            
            // Проверка на прошлый запуск реакта
            if ([dict[nameWaitingReactStart] boolValue]){
                // Если прошлый раз реакт не стартанул
                dict[nameWaitingReactStart] = @NO;
                dict[nameShouldDropActiveVersion] = @YES;
                [RNChangeBundleFS saveStore:dict];
                return _defaultBundleURL;
            } else {
                // Если прошлый раз реакт стартанул
                BOOL isFileExists = [RNChangeBundleFS exists:path];
                // Проверка на наличие этого кастомного файла
                if (isFileExists){
                    // Если файл существует, то запускаем проверку на успешный старт реакта
                    dict[nameWaitingReactStart] = @YES;
                    [RNChangeBundleFS saveStore:dict];
                    return [NSURL fileURLWithPath:path];
                } else {
                    // Если файла нет, то и кастомного реакта нет
                    dict[nameShouldDropActiveVersion] = @YES;
                    [RNChangeBundleFS saveStore:dict];
                    return _defaultBundleURL;
                }
            }
        } else {
            // Если было нативное обновление
            dict[nameShouldDropActiveVersion] = @YES;
            [RNChangeBundleFS saveStore:dict];
            return _defaultBundleURL;
        }
    }
}




+ (void)setDefaultBundleURL:(NSURL *)URL
{
    _defaultBundleURL = URL;
}


+ (NSError *)addBundle:(NSString *)bundleId pathForBundle:(NSString *)bundlePath pathForAssets:(NSString *)assetsPath
{
    NSError *error = nil;
    
    NSString *path = [RNChangeBundleFS getFolderForBundleId:bundleId];

    BOOL isFolderExists = [RNChangeBundleFS exists:path];
    
    if (!isFolderExists){
        error = [RNChangeBundleFS createFolder:path];

        if (error != nil){
            NSLog(@"error %@", error);
            return error;
        }
    }
    
    error = [RNChangeBundleFS moveWithOverride:bundlePath to:[RNChangeBundleFS getBundleFileNameForBundleId:bundleId]];
    
    if (error != nil){
        NSLog(@"error %@", error);
        return error;
    }
    
    error = [RNChangeBundleFS moveWithOverride:assetsPath to:[RNChangeBundleFS getAssetsFolderNameForBundleId:bundleId]];
    
    if (error != nil){
        NSLog(@"error %@", error);
        return error;
    }
    
    NSMutableDictionary *dict = [RNChangeBundleFS loadStore];
    dict[nameBundleList][bundleId] = bundleId;
    [RNChangeBundleFS saveStore:dict];
    return error;
}

- (void)addBundlePromise:(NSString *)bundleId pathForBundle:(NSString *)bundlePath pathForAssets:(NSString *)assetsPath withResolver: (RCTPromiseResolveBlock)resolve
                  withRejecter: (RCTPromiseRejectBlock)reject
{
    NSError *error = nil;
    error = [RNChangeBundleLib addBundle:bundleId pathForBundle:bundlePath pathForAssets:assetsPath];
    
    if (error == nil){
        resolve(@"Added");
    } else {
        reject(@"RNChangeBundle", error.localizedDescription, error);
    }
}

+ (NSError *)deleteBundle:(NSString *)bundleId
{
    NSError *error = nil;
    
    NSString *path = [RNChangeBundleFS getFolderForBundleId:bundleId];

    BOOL isFolderExists = [RNChangeBundleFS exists:path];
    
    if (isFolderExists){
        error = [RNChangeBundleFS remove:path];

        if (error != nil){
            NSLog(@"error %@", error);
            return error;
        }
    }
    
    
    NSMutableDictionary *dict = [RNChangeBundleFS loadStore];
    [dict[nameBundleList] removeObjectForKey:bundleId];
    [RNChangeBundleFS saveStore:dict];
    return error;
}

- (void)deleteBundlePromise:(NSString *)bundleId withResolver: (RCTPromiseResolveBlock)resolve
                  withRejecter: (RCTPromiseRejectBlock)reject
{
    NSError *error = nil;
    
    error = [RNChangeBundleLib deleteBundle:bundleId];
    
    if (error == nil){
        resolve(@"Deleted");
    } else {
        reject(@"RNChangeBundle", error.localizedDescription, error);
    }
}

+ (NSDictionary *)getBundles
{
    NSMutableDictionary *dict = [RNChangeBundleFS loadStore];
    return dict[nameBundleList];
}

- (void)getBundlesPromise:(RCTPromiseResolveBlock)resolve
                  withRejecter: (RCTPromiseRejectBlock)reject
{
    resolve([RNChangeBundleLib getBundles]);
}

+ (NSString *)getActiveBundle
{
    NSMutableDictionary *dict = [RNChangeBundleFS loadStore];
    return dict[activeBundleName];
}

- (void)getActiveBundlePromise:(RCTPromiseResolveBlock)resolve
                  withRejecter: (RCTPromiseRejectBlock)reject
{
    resolve([RNChangeBundleLib getActiveBundle]);
}

+ (void)activateBundle:(NSString *)bundleId
{
    NSMutableDictionary *dict = [RNChangeBundleFS loadStore];
    dict[activeBundleName] = bundleId;
    dict[nameNativeBuildVersion] = [RNChangeBundleLib getBuildId];
    [RNChangeBundleFS saveStore:dict];
}

- (void)activateBundlePromise:(NSString *)bundleId withResolver: (RCTPromiseResolveBlock)resolve
                  withRejecter: (RCTPromiseRejectBlock)reject
{
    [RNChangeBundleLib activateBundle:bundleId];
    
    resolve(@"Activated");
}

+ (void)notifyIfUpdateApplies
{
    NSMutableDictionary *dict = [RNChangeBundleFS loadStore];
    dict[nameWaitingReactStart] = @NO;
    [RNChangeBundleFS saveStore:dict];
    if ([dict[nameShouldDropActiveVersion] boolValue]){
        [RNChangeBundleLib deleteBundle:dict[activeBundleName]];
        [RNChangeBundleLib activateBundle:@""];
        NSMutableDictionary *dict = [RNChangeBundleFS loadStore];
        dict[nameShouldDropActiveVersion] = @NO;
        dict[nameNativeBuildVersion] = @"";
        [RNChangeBundleFS saveStore:dict];
    }
}

- (void)notifyIfUpdateAppliesPromise:(RCTPromiseResolveBlock)resolve
                  withRejecter: (RCTPromiseRejectBlock)reject
{
    [RNChangeBundleLib notifyIfUpdateApplies];
    resolve(@"Notified");
}

+ (void)reload
{
    if ([NSThread isMainThread]) {
        RCTTriggerReloadCommandListeners(@"react-native-restart: Restart");
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            RCTTriggerReloadCommandListeners(@"react-native-restart: Restart");
        });
    }
}

- (void)reloadPromise:(RCTPromiseResolveBlock)resolve
        withRejecter: (RCTPromiseRejectBlock)reject
{
    [RNChangeBundleLib reload];
    resolve(@"Reloaded");
}

+ (NSString *) getBuildId {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

- (void) getBuildIdPromise:(RCTPromiseResolveBlock)resolve
              withRejecter: (RCTPromiseRejectBlock)reject {
    resolve([RNChangeBundleLib getBuildId]);
}


RCT_REMAP_METHOD(addBundle, exportedAddBundle:(NSString *)bundleId pathForBundle:(NSString *)bundlePath  pathForAssets:(NSString *)assetsPath withResolver: (RCTPromiseResolveBlock)resolve
                 withRejecter: (RCTPromiseRejectBlock)reject)
{
    [self addBundlePromise:bundleId pathForBundle:bundlePath pathForAssets:assetsPath withResolver:resolve withRejecter:reject];
}

RCT_REMAP_METHOD(deleteBundle, exportedDeleteBundle:(NSString *)bundleId withResolver: (RCTPromiseResolveBlock)resolve withRejecter: (RCTPromiseRejectBlock)reject)
{
    [self deleteBundlePromise:bundleId withResolver:resolve withRejecter:reject];
}

RCT_REMAP_METHOD(getBundles, exportedGetBundles:(RCTPromiseResolveBlock)resolve withRejecter: (RCTPromiseRejectBlock)reject)
{
    [self getBundlesPromise:resolve withRejecter:reject];
}

RCT_REMAP_METHOD(getActiveBundle, exportedGetActiveBundle:(RCTPromiseResolveBlock)resolve withRejecter: (RCTPromiseRejectBlock)reject)
{
    [self getActiveBundlePromise:resolve withRejecter:reject];
}

RCT_REMAP_METHOD(activateBundle, exportedActivateBundle:(NSString *)bundleId withResolver: (RCTPromiseResolveBlock)resolve withRejecter: (RCTPromiseRejectBlock)reject)
{
    [self activateBundlePromise:bundleId withResolver:resolve withRejecter:reject];
}


RCT_REMAP_METHOD(notifyIfUpdateApplies, exportedNotifyIfUpdateApplies:(RCTPromiseResolveBlock)resolve withRejecter: (RCTPromiseRejectBlock)reject)
{
    [self notifyIfUpdateAppliesPromise:resolve withRejecter:reject];
}

RCT_REMAP_METHOD(reload, exportedReload:(RCTPromiseResolveBlock)resolve withRejecter: (RCTPromiseRejectBlock)reject)
{
    [self reloadPromise:resolve withRejecter:reject];
}

RCT_REMAP_METHOD(getBuildId, exportedGetBuildId:(RCTPromiseResolveBlock)resolve withRejecter: (RCTPromiseRejectBlock)reject)
{
    [self getBuildIdPromise:resolve withRejecter:reject];
}



RCT_EXPORT_MODULE()


@end
