//
//  CoreService.m
//  ReplaceProjectNameTool
//
//  Created by shikeeapp_003 on 2018/4/2.
//  Copyright © 2018年 shikeeapp_003. All rights reserved.
//

#import "CoreService.h"
#import "NSString+Helper.h"

//typedef NS_OPTIONS(NSInteger, HistoryKey){
//    HistoryKeyVersion=0,//版本
//    HistoryKeyOperation,//操作
//    HistoryKeyOld,//旧的项目名|后缀
//    HistoryKeyNew,//新的项目名|后缀
//    HistoryKeyResult,//操作结果
//    HistoryKeyDate,//操作时间
//};
@interface CoreService()

@end

@implementation CoreService
+ (instancetype)sharedManager
{
    static id manager=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

-(NSString*)oldProjectNameWithRootPath:(NSString *)path
{
    NSString *oldPrjName=@"";
    NSFileManager *fileManger = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL isExist = [fileManger fileExistsAtPath:path isDirectory:&isDir];
    if (isExist) {
        if (isDir) {
            NSArray * dirArray = [fileManger contentsOfDirectoryAtPath:path error:nil];
            NSString * subPath = nil;
            for (NSString * str in dirArray) {
                subPath  = [path stringByAppendingPathComponent:str];
                NSString *fileName=[subPath lastPathComponent];
                NSString*extension=[subPath pathExtension];
                if([extension isEqualToString:@"xcodeproj"]){
                    oldPrjName=[fileName stringByDeletingPathExtension];
                    break;
                }
            }
        }
    }
    return oldPrjName;
}

-(void)replaceWithFilePath:(NSString *)path prjRootPath:(NSString*)prjRootPath oldFileName:(NSString *)oldFileName newFileName:(NSString *)newFileName completeCallback:(void (^)(NSString*errorMsg,NSInteger count,NSArray<NSString*> *changePath))completeCallback
{
    __block NSInteger count=0;
    __block NSMutableArray<NSString*>* changePath=[NSMutableArray new];
    if(newFileName.length<1||[newFileName isEqualToString:oldFileName]){
        if(completeCallback){
            completeCallback(@"没有任何更改",0,nil);
        }
        return;
    }
    __block NSString * errorMsg=nil;
    NSArray *filesArray=[self allFilesWithDir:path];//获取所有文件列表
    NSArray *dirArray=[self allDirWithDirPath:path];//获取所有目录列表
    [filesArray enumerateObjectsUsingBlock:^(NSString*  _Nonnull filePath, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *fileName=[filePath lastPathComponent];//文件名
        NSString *content=[[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        
        if((content.length>0&&[content isContainStr:oldFileName])){//文件内容修改 比如import "xxx.h" implement xxx
            content=[content stringByReplacingOccurrencesOfString:oldFileName withString:newFileName];
            [content writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        }
        
        if([fileName isContainStr:oldFileName]){//文件名修改
            NSString *rootPath=[filePath substringToIndex:filePath.length-fileName.length-1];
            NSString *writeFileName=[fileName stringByReplacingOccurrencesOfString:oldFileName withString:newFileName];
            NSString *moveToPath=[rootPath stringByAppendingString:[NSString stringWithFormat:@"/%@",writeFileName]];
            NSFileManager *fileManger = [NSFileManager defaultManager];
            NSError *error;
            BOOL isSuccess = [fileManger moveItemAtPath:filePath toPath:moveToPath error:&error];
            NSLog(@"==========%@",isSuccess==YES?@"ture":@"false");
            if(!isSuccess){
                if(error.code==513){
                    errorMsg=@"没有写入权限";
                }else{
                    errorMsg=[error description];
                }
            }else{
                count++;
                [changePath addObject:filePath];
            }
        }
    }];
    
    [dirArray enumerateObjectsUsingBlock:^(NSString*  _Nonnull dirPath, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *fileName=[dirPath lastPathComponent];//文件夹名更改
        if([fileName isContainStr:oldFileName]){
            NSString *rootPath=[dirPath substringToIndex:dirPath.length-fileName.length-1];
            NSString *writeFileName=[fileName stringByReplacingOccurrencesOfString:oldFileName withString:newFileName];
            NSString *moveToPath=[rootPath stringByAppendingString:[NSString stringWithFormat:@"/%@",writeFileName]];
            if(![prjRootPath isEqualToString:dirPath]){
                NSError *error;
                NSFileManager *fileManger = [NSFileManager defaultManager];
                BOOL isSuccess = [fileManger moveItemAtPath:dirPath toPath:moveToPath error:&error];
                NSLog(@"==========%@",isSuccess==YES?@"ture":@"false");
                if(!isSuccess){
                    if(error.code==513){
                        errorMsg=@"没有写入权限";
                    }else{
                        errorMsg=[error description];
                    }
                }else{
                    count++;
                    [changePath addObject:dirPath];
                }
            }
        }
        if(idx==dirArray.count-1){//最后一个
            if(completeCallback){
                completeCallback(errorMsg,count,changePath);
            }
        }
    }];
    
}

-(void)replacePrefixWithFilePath:(NSString *)path oldPrefix:(NSString *)oldPrefix newPrefix:(NSString *)newPrefix completeCallback:(void (^)(NSString* errorMsg,NSInteger successCount,NSInteger failCount,NSArray<NSString*>*successChangePath,NSArray<NSString*>*failChangePath))completeCallback
{
    if(oldPrefix.length<1){
        if(completeCallback){
            completeCallback(@"旧前缀必须输入",0,999,nil,nil);
        }
        return;
    }
    
    __block NSInteger successCount=0;
    __block NSInteger failCount=0;
    __block NSMutableArray<NSString*>* changePath=[NSMutableArray new];
    __block NSMutableArray<NSString*>* failChangePath=[NSMutableArray new];
    __block NSString* errorMsg=nil;
    
    NSArray<NSString *>* fileArray=[self allFilesWithDir:path];
    [fileArray enumerateObjectsUsingBlock:^(NSString * _Nonnull filePath, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *fileName=[filePath lastPathComponent];//文件名带后缀
        NSString *fileNameDeletingPathExtension=[fileName stringByDeletingPathExtension];//文件名不带后缀
        if([fileNameDeletingPathExtension hasPrefix:oldPrefix]&&![filePath isContainStr:@"Pod"]&&![filePath isContainStr:@"pod"]){
            NSRange prefixRange=NSMakeRange(0, oldPrefix.length);
            //旧前缀文件名修改成新前缀后的文件名
            NSString *newFileName=[fileName stringByReplacingCharactersInRange:prefixRange withString:newPrefix];
            NSString *newFileNameDPE=[fileNameDeletingPathExtension stringByReplacingCharactersInRange:prefixRange withString:newPrefix];//不带后缀
            NSArray *newFileArray=[self allFilesWithDir:path];
            //逐个遍历所有文件，先修改文件内容
            [newFileArray enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *content=[[NSString alloc] initWithContentsOfFile:obj encoding:NSUTF8StringEncoding error:nil];
                if(content.length&&[content isContainStr:fileNameDeletingPathExtension]){
                    if([content isContainStr:@"SKImageM"]){
                        BOOL s=[content isContainStr:@"SKImageM"];
                        NSLog(@"");
                    }
                    
                    content=[content stringByReplacingOccurrencesOfString:fileNameDeletingPathExtension withString:newFileNameDPE	];
                    NSError *error=nil;
                    BOOL isSuccess=[content writeToFile:obj atomically:YES encoding:NSUTF8StringEncoding error:&error];
                    if(isSuccess){
                        successCount++;
                        [changePath addObject:obj];
                    }else{
                        failCount++;
                        [failChangePath addObject:obj];
                        errorMsg=[error description];
                    }
                }
            }];
            
            //再逐个修改文件名
            NSString *rootPath=[filePath substringToIndex:filePath.length-fileName.length-1];
            NSString *writeFileName=[fileName stringByReplacingOccurrencesOfString:fileName withString:newFileName];
            NSString *moveToPath=[rootPath stringByAppendingString:[NSString stringWithFormat:@"/%@",writeFileName]];
            NSFileManager *fileManger = [NSFileManager defaultManager];
            NSError *error;
            BOOL isSuccess = [fileManger moveItemAtPath:filePath toPath:moveToPath error:&error];
            NSLog(@"==========%@",isSuccess==YES?@"ture":@"false");
            if(!isSuccess){
                failCount++;
                [failChangePath addObject:filePath];
                if(error.code==513){
                    errorMsg=@"没有写入权限";
                }else{
                    errorMsg=[error description];
                }
            }else{
                successCount++;
                [changePath addObject:filePath];
            }
        }
        if(idx==fileArray.count-1){//stop
            if(completeCallback){
                completeCallback(errorMsg,successCount,failCount,changePath,failChangePath);
            }
        }
    }];
}

-(void)replaceHeaderPrefixWithFilePath:(NSString *)path oldPrefix:(NSString *)oldPrefix newPrefix:(NSString *)newPrefix completeCallback:(void (^)(BOOL))completeCallback
{
    
}

-(void)replaceImplementPrefixWithFilePath:(NSString *)path oldPrefix:(NSString *)oldPrefix newPrefix:(NSString *)newPrefix completeCallback:(void (^)(BOOL))completeCallback
{
    
}

#pragma mark- private method
-(NSArray *)allFilesWithDir:(NSString *)path
{
	NSMutableArray* filePathArray=[NSMutableArray new];
    NSFileManager *fileManger = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL isExist = [fileManger fileExistsAtPath:path isDirectory:&isDir];
    if (isExist) {
        //判断是不是目录
        if (isDir) {
            NSError *error;
            NSArray * dirArray = [fileManger contentsOfDirectoryAtPath:path error:&error];
            NSString * subPath = nil;
            for (NSString * str in dirArray) {
                subPath  = [path stringByAppendingPathComponent:str];
                NSArray *subArray=[self allFilesWithDir:subPath];//递归
                if(subArray.count){
                    [filePathArray addObjectsFromArray:subArray];
                }
            }
        }else{
            [filePathArray addObject:path];
        }
    }else{
        NSLog(@"目录不存在");
    }
    return filePathArray;
}

-(NSArray*)allDirWithDirPath:(NSString*)dirPath
{
    NSMutableArray* filePathArray=[NSMutableArray new];
    NSFileManager *fileManger = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL isExist = [fileManger fileExistsAtPath:dirPath isDirectory:&isDir];
    if (isExist) {
        //判断是不是目录
        if (isDir) {
            NSError *error;
            NSArray * dirArray = [fileManger contentsOfDirectoryAtPath:dirPath error:&error];
            NSString * subPath = nil;
            for (NSString * str in dirArray) {
                subPath  = [dirPath stringByAppendingPathComponent:str];
                NSArray *subArray=[self allDirWithDirPath:subPath];//递归
                if(subArray.count){
                    [filePathArray addObjectsFromArray:subArray];
                }
            }
            [filePathArray addObject:dirPath];
        }
    }else{
        NSLog(@"目录不存在");
    }
    return filePathArray;
}






@end
