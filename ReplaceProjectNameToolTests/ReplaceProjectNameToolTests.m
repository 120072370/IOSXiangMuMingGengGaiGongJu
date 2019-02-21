//
//  ReplaceProjectNameToolTests.m
//  ReplaceProjectNameToolTests
//
//  Created by shikeeapp_003 on 2018/4/2.
//  Copyright © 2018年 shikeeapp_003. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CoreService.h"

@interface ReplaceProjectNameToolTests : XCTestCase

@end

@implementation ReplaceProjectNameToolTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testAllFilesWithDir {
    CoreService *service=[CoreService sharedManager];
    NSArray *result=[service allFilesWithDir:@"/Users/shikeeapp_003/Desktop/work/测试示例/zhsappbeta"];
    [result enumerateObjectsUsingBlock:^(NSString*  _Nonnull filePath, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"%@",filePath);
    }];
}

- (void)testAllDirWithDir {
    CoreService *service=[CoreService sharedManager];
    NSArray *result=[service allDirWithDirPath:@"/Users/shikeeapp_003/Desktop/work/测试示例/SimpleProject_t"];
    [result enumerateObjectsUsingBlock:^(NSString*  _Nonnull dirPath, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"%@",dirPath);
        NSString *fileName=[dirPath lastPathComponent];//文件名
        NSString *rootPath=[dirPath substringToIndex:dirPath.length-fileName.length-1];
        NSLog(@"~");
    }];
}

- (void)testReplaceProjectName {
    CoreService *service=[CoreService sharedManager];
    [service replaceWithFilePath:@"/Users/shikeeapp_003/Desktop/work/测试示例/zhsappbeta" oldFileName:@"zhsappbeta" newFileName:@"zhschangetest" completeCallback:^(NSString *errorMsg) {
        if(errorMsg.length<1){
            NSLog(@"ok");
        }else{
            NSLog(@"%@",errorMsg);
        }
    }];

}


- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
