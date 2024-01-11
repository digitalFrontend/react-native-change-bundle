
#import "RNChangeBundleFS.h"
#import <Foundation/Foundation.h>

#if __has_include(<React/RCTAssert.h>)
#import <React/RCTBridgeModule.h>
#else
#import "RCTBridgeModule.h"
#endif


@interface RNChangeBundleFS : NSObject  {

}

+ (NSString *_Nonnull) getDocumentDir;
+ (NSString *_Nonnull) getStoreFilePath;
+ (NSString *_Nonnull) getFolderForBundleId:(NSString *_Nonnull) bundleId;
+ (NSString *_Nonnull) getBundleFileNameForBundleId:(NSString *_Nonnull) bundleId;
+ (NSString *_Nonnull) getAssetsFolderNameForBundleId:(NSString *_Nonnull) bundleId;

+ (NSMutableDictionary *_Nonnull)loadStore;
+ (NSMutableDictionary *_Nonnull)createEmptyStore;
+ (void)saveStore:(NSDictionary *_Nonnull)dict;

+ (BOOL) exists:(NSString *_Nonnull) path;
+ (NSError *_Nullable) createFolder:(NSString *_Nonnull) path;
+ (NSError *_Nullable) remove:(NSString *_Nonnull) path;
+ (NSError *_Nullable) moveWithOverride:(NSString *_Nonnull) from to:(NSString *_Nonnull)to;

+ (void) saveFileInfo:(NSString *_Nonnull)path;
+ (BOOL) verifyFileInfo:(NSString *_Nonnull)path;



@end


