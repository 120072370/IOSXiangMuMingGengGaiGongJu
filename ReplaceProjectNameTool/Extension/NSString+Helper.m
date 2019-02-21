//
//  NSString+Helper.m
//  Json2ObjFile
//
//  Created by shikee_app03 on 16/6/15.
//  Copyright © 2016年 lanqiang. All rights reserved.
//

#import "NSString+Helper.h"

@implementation NSString (Helper)
-(BOOL)isContainStr:(NSString *)str
{
    NSRange range=[self rangeOfString:str];
    if(range.location!=NSNotFound){
        return true;
    }else{
        return false;
    }
}

-(BOOL)isEqualToStrs:(NSArray *)array
{
    __block BOOL result=NO;
    __weak NSString *selfStr=self;
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if([obj isEqualToString:selfStr]){
            result=YES;
        }
    }];
    return result;
}

/**
 删除整个xml标签
 
 @param xmlStr
 @param tagName 标签名，如果要删除<test>xxxx</test> 则传入test即可,不支持带有标签属性的标签删除，比如
 <test pp='123'>xxxx</test>
 @return 删除后的xmlstr
 */
-(NSString*)xmlRemoveTag:(NSString*)tagName
{
    //<id/>
    NSRange endTagRange=[self rangeOfString:[NSString stringWithFormat:@"<%@/>",tagName]];
    if(endTagRange.location!=NSNotFound){
        return [self stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"<%@/>",tagName] withString:@""];
    }
    
    NSRange beginRange=[self rangeOfString:[NSString stringWithFormat:@"<%@>",tagName]];
    if(beginRange.location==NSNotFound){
        return self;
    }
    NSRange endRange=[self rangeOfString:[NSString stringWithFormat:@"</%@>",tagName]];
    if(endRange.location==NSNotFound){
        return self;
    }
    NSRange deleteRange=NSMakeRange(beginRange.location, endRange.location+endRange.length-beginRange.location);
    return [self stringByReplacingCharactersInRange:deleteRange withString:@""];
}


/**
 只删除标签里面的内容
 
 @param xmlStr
 @param tagName 标签名，如果要删除<test>xxxx</test> 则传入test即可,不支持带有标签属性的标签删除，比如
 <test pp='123'>xxxx</test>
 @return 删除后的xmlstr
 */
-(NSString*)xmlRemoveTagContent:(NSString*)tagName
{
    NSRange endTagRange=[self rangeOfString:[NSString stringWithFormat:@"<%@/>",tagName]];
    if(endTagRange.location!=NSNotFound){
        NSString *debug=[self substringWithRange:endTagRange];
        return [self stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"<%@/>",tagName] withString:@""];
    }
    
    NSRange beginRange=[self rangeOfString:[NSString stringWithFormat:@"<%@>",tagName]];
    if(beginRange.location==NSNotFound){
        return self;
    }
    NSRange endRange=[self rangeOfString:[NSString stringWithFormat:@"</%@>",tagName]];
    if(endRange.location==NSNotFound){
        return self;
    }
    NSRange deleteRange=NSMakeRange(beginRange.location+beginRange.length, endRange.location-beginRange.location-beginRange.length);
    NSString *debug=[self substringWithRange:deleteRange];
    return [self stringByReplacingCharactersInRange:deleteRange withString:@""];
}


@end
