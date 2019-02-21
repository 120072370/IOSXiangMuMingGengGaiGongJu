//
//  LogModel.h
//  ReplaceProjectNameTool
//
//  Created by shikeeapp_003 on 2018/4/3.
//  Copyright © 2018年 shikeeapp_003. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LogModel : NSObject
@property(nonatomic,strong) NSArray<NSString*>* pathArray;
@property(nonatomic,assign) NSInteger count;
@property(nonatomic,strong) NSArray<NSString*>* failPathArray;
@end
