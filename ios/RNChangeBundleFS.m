
//  RNFetchBlobFS.m
//  RNFetchBlob
//
//  Created by Ben Hsieh on 2016/6/6.
//  Copyright © 2016年 suzuri04x2. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RNChangeBundleFS.h"


#if __has_include(<React/RCTAssert.h>)
#import <React/RCTBridge.h>
#import <React/RCTEventDispatcher.h>
#else
#import "RCTBridge.h"
#import "RCTEventDispatcher.h"
#endif


static NSString * const bundlesFolderName = @"bundles";
static NSString * const assetsFolderName = @"assets";
static NSString * const bundleFileName = @"main.jsbundle";
static NSString * const storeFileName = @"_RNChangeBundle.plist";
static NSString * const nameBundleList = @"bundleList";
static NSString * const activeBundleName = @"activeBundle";
static NSString * const nameWaitingReactStart = @"waitReactStart";
static NSString * const nameNativeBuildVersion = @"nativeBuildVersion";
static NSString * const nameShouldDropActiveVersion = @"shouldDropActiveVersion";

@implementation RNChangeBundleFS : NSObject {

}


+ (NSString *) getDocumentDir {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    return documentsDirectory;
}

+ (NSString *) getStoreFilePath {
    NSString *path = [[RNChangeBundleFS getDocumentDir] stringByAppendingPathComponent:storeFileName];
    return path;
}

+ (NSString *) getFolderForBundleId:(NSString *) bundleId
{
    NSString *path = [[[RNChangeBundleFS getDocumentDir] stringByAppendingPathComponent:bundlesFolderName] stringByAppendingPathComponent:bundleId];

    return path;
}

+ (NSString *) getBundleFileNameForBundleId:(NSString *) bundleId
{
    NSString *path = [[[[RNChangeBundleFS getDocumentDir] stringByAppendingPathComponent:bundlesFolderName] stringByAppendingPathComponent:bundleId] stringByAppendingPathComponent:bundleFileName];

    return path;
}

+ (NSString *) getAssetsFolderNameForBundleId:(NSString *) bundleId
{
    NSString *path = [[[RNChangeBundleFS getDocumentDir] stringByAppendingPathComponent:bundlesFolderName] stringByAppendingPathComponent:bundleId];
    
    return path;
}

+ (void)saveStore:(NSDictionary *)dict
{
   
    NSString *path = [RNChangeBundleFS getStoreFilePath];
    
    [dict writeToFile:path atomically:YES];
}

+ (NSMutableDictionary *)loadStore
{
   
    NSString *path = [RNChangeBundleFS getStoreFilePath];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path]) {
        return [RNChangeBundleFS createEmptyStore];
    } else {
        return [NSMutableDictionary dictionaryWithContentsOfFile:path];
    }
}

+ (NSMutableDictionary *)createEmptyStore {

    NSMutableDictionary *defaults = [[NSMutableDictionary alloc] init];
    defaults[nameBundleList] = [NSMutableDictionary dictionary];
    defaults[activeBundleName] = @"";
    defaults[nameWaitingReactStart] = @NO;
    defaults[nameNativeBuildVersion] = @"";
    defaults[nameShouldDropActiveVersion] = @NO;
    return [defaults mutableCopy];
}

+ (BOOL) exists:(NSString *) path
{
    BOOL isDir = YES;
    BOOL isFolderExists = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];
 
    return isFolderExists;
}

+ (NSError *) createFolder:(NSString *)path
{
    NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
    return error;
}

+ (NSError *) remove:(NSString *)path
{
    NSError *error = nil;
    
    [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
    
    return error;
}

+ (NSError *) moveWithOverride:(NSString *)from to:(NSString *)to
{
    NSError *error = nil;
    
    BOOL isToExists = [RNChangeBundleFS exists:to];
    
    if (isToExists){
        error = [RNChangeBundleFS remove:to];
        
        if (error != nil){
            return error;
        }
    }
    
    [[NSFileManager defaultManager] moveItemAtPath:from toPath:to error:&error];
    
    return error;
}

+ (void) saveFileInfo:(NSString *)path
{
    unsigned long long _fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil] fileSize];
    NSString *fileSize = [NSString stringWithFormat:@"%llu", _fileSize];
    NSDate *modificationDate = [[[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil] fileModificationDate];
    NSDate *creationDate = [[[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil] fileCreationDate];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:fileSize forKey:@"fileSize"];
    [defaults setObject:creationDate forKey:@"creationDate"];
    [defaults setObject:modificationDate forKey:@"modificationDate"];
}


+ (BOOL) verifyFileInfo:(NSString *)path
{
    unsigned long long _fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil] fileSize];
    NSString *fileSize = [NSString stringWithFormat:@"%llu", _fileSize];
    NSDate *modificationDate = [[[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil] fileModificationDate];
    NSDate *creationDate = [[[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil] fileCreationDate];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *storedFileSize = [defaults objectForKey:@"fileSize"];
    NSDate *storedCreationDate = [defaults objectForKey:@"creationDate"];
    NSDate *storedModificationDate = [defaults objectForKey:@"modificationDate"];
    
    BOOL isCreationDateEquals = [storedCreationDate isEqualToDate:creationDate];
    BOOL isModificationDateEquals = [storedModificationDate isEqualToDate:modificationDate];
    BOOL isFileSizeEquals = [storedFileSize isEqualToString:fileSize];
    
    return isCreationDateEquals && isModificationDateEquals && isFileSizeEquals;
}




@end
