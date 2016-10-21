//
//  NSString+DFExtension.m
//  点范
//
//  Created by Masteryi on 16/9/14.
//  Copyright © 2016年 Masteryi. All rights reserved.
//

#import "NSString+DFExtension.h"
#import<CommonCrypto/CommonDigest.h>


@implementation NSString (DFExtension)
/**
 *  MD5 加密
 *
 */
- (NSString *)MD5{
    const char *cStr = [self UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;

}

/**
 判断字符串是否为纯数字

 */
+ (BOOL)isPureInt:(NSString *)string{
    
    NSScanner* scan = [NSScanner scannerWithString:string];
    
    int val;
    
    return [scan scanInt:&val] && [scan isAtEnd];
    
}

- (NSString *)SubToIndex{
   
    NSString *outPut = [NSString string];
    outPut = [self substringToIndex:(self.length - 3)];
    return outPut;
}


@end
