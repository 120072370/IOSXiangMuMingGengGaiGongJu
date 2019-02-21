//
//  NSString+Helper.h
//  Json2ObjFile
//
//  Created by shikee_app03 on 16/6/15.
//  Copyright © 2016年 lanqiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Helper)
-(BOOL)isContainStr:(NSString *)str;
-(BOOL)isEqualToStrs:(NSArray *)array;
/**
 删除整个xml标签
 
 @param xmlStr
 @param tagName 标签名，如果要删除<test>xxxx</test> 则传入test即可,不支持带有标签属性的标签删除，比如
 <test pp='123'>xxxx</test>
 @return 删除后的xmlstr
 */
-(NSString*)xmlRemoveTag:(NSString*)tagName;


/**
 只删除标签里面的内容
 
 @param xmlStr
 @param tagName 标签名，如果要删除<test>xxxx</test> 则传入test即可,不支持带有标签属性的标签删除，比如
 <test pp='123'>xxxx</test>
 @return 删除后的xmlstr
 */
-(NSString*)xmlRemoveTagContent:(NSString*)tagName;

@end
