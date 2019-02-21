//
//  CoreService.h
//  ReplaceProjectNameTool
//
//  Created by shikeeapp_003 on 2018/4/2.
//  Copyright © 2018年 shikeeapp_003. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoreService : NSObject
+ (instancetype)sharedManager;
#pragma mark- tool

/**
 根据目录路径，获取该目录下所有的文件列表,不包含子目录返回

 @param path 目录路径（文件路径也可以）
 @return 返回一个NSString类型的路径数组---> @[@"/User/Project/xxx.xxx"]
 */
-(NSArray *)allFilesWithDir:(NSString *)path;

/**
 根据目录路径，获取该目录下所有的子目录列表，包括根目录也返回
 @param dirPath 目录路径
 @return 返回一个NSString类型的路径数组---> @[@"/User/Project/xxxx"]  （只会返回目录，顺序是最底层的目录在索引0，以此类推，根目录的索引一定是array.lastObj）
 */
-(NSArray*)allDirWithDirPath:(NSString*)dirPath;


/**
 根据路径获取IOS项目名

 @param path 项目根目录
 @return 当前项目名
 */
-(NSString*)oldProjectNameWithRootPath:(NSString *)path;
#pragma mark- project

/**
 替换项目的文件名
 @param path 替换的文件夹根目录（不和下面的冗余，这里可以是项目的根目录，在分段替换时，也可以是其他目录）
 @param prjRootPath 项目的根目录
 @param oldFileName 老的项目（文件）名
 @param newFileName 新的项目（文件）名
 @param completeCallback 操作成功的回调，返回errorMsg，如果errorMsg不为空的话，说明替换时候有错误 count，被更改的文件数量，被更改的文件路径
 */
-(void)replaceWithFilePath:(NSString*)path prjRootPath:(NSString*)prjRootPath oldFileName:(NSString*)oldFileName newFileName:(NSString*)newFileName completeCallback:(void(^)(NSString *errorMsg,NSInteger count,NSArray<NSString*>* changePath))completeCallback;

#pragma mark- prefix
-(void)replacePrefixWithFilePath:(NSString*)path oldPrefix:(NSString*)oldPrefix newPrefix:(NSString*)newPrefix completeCallback:(void(^)(NSString* errorMsg,NSInteger successCount,NSInteger failCount,NSArray<NSString*>*successChangePath,NSArray<NSString*>*failChangePath))completeCallback;
@end
