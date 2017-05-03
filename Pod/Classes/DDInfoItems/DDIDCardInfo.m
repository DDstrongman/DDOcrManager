//
//  DDIDCardInfo.m
//  DDRecBankCardAndID
//
//  Created by 李胜书 on 2017/4/17.
//  Copyright © 2017年 李胜书. All rights reserved.
//

#import "DDIDCardInfo.h"

@implementation DDIDCardInfo

- (BOOL)isEqual:(DDIDCardInfo *)idInfo {
    if (idInfo == nil) {
        return NO;
    }
    if (_type == 1) {
        if ((_type == idInfo.type) &&
            [_number isEqualToString:idInfo.number] &&
            [_name isEqualToString:idInfo.name] &&
            [_gender isEqualToString:idInfo.gender] &&
            [_gender isEqualToString:idInfo.gender] &&
            [_address isEqualToString:idInfo.address]) {
            return YES;
        }
    } else if (_type == 2) {
        if ([_issue isEqualToString:idInfo.issue] &&
            [_valid isEqualToString:idInfo.valid]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isReady {
    if (_number != nil && _name != nil && _gender != nil && _nation != nil && _address != nil) {
        if (_number.length > 0 && _name.length > 0 && _gender.length > 0 && _nation.length > 0 && _address.length > 0) {
            if ([self checkUserIdCard:_number]) {
                return YES;
            }
        }
    }
    else if (_issue != nil && _valid != nil) {
        if (_issue.length > 0 && _valid.length >0) {
            return YES;
        }
    }
    return NO;
}

- (NSString *)sumString {
    return [NSString stringWithFormat:@"身份证号:%@\n姓名:%@\n性别:%@\n民族:%@\n地址:%@\n签发机关:%@\n有效期:%@",
            _number, _name, _gender, _nation, _address, _issue, _valid];
}
#pragma mark 判断身份证号是否合法
- (BOOL)checkUserIdCard: (NSString *)identityString
{
    if (identityString.length != 18) return NO;
    // 正则表达式判断基本 身份证号是否满足格式
    NSString *regex = @"^[1-9]\\d{5}[1-9]\\d{3}((0\\d)|(1[0-2]))(([0|1|2]\\d)|3[0-1])\\d{3}([0-9]|X)$";
    //  NSString *regex = @"^(^[1-9]\\d{7}((0\\d)|(1[0-2]))(([0|1|2]\\d)|3[0-1])\\d{3}$)|(^[1-9]\\d{5}[1-9]\\d{3}((0\\d)|(1[0-2]))(([0|1|2]\\d)|3[0-1])((\\d{4})|\\d{3}[Xx])$)$";
    NSPredicate *identityStringPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    //如果通过该验证，说明身份证格式正确，但准确性还需计算
    if(![identityStringPredicate evaluateWithObject:identityString]) return NO;
    
    //** 开始进行校验 *//
    
    //将前17位加权因子保存在数组里
    NSArray *idCardWiArray = @[@"7", @"9", @"10", @"5", @"8", @"4", @"2", @"1", @"6", @"3", @"7", @"9", @"10", @"5", @"8", @"4", @"2"];
    
    //这是除以11后，可能产生的11位余数、验证码，也保存成数组
    NSArray *idCardYArray = @[@"1", @"0", @"10", @"9", @"8", @"7", @"6", @"5", @"4", @"3", @"2"];
    
    //用来保存前17位各自乖以加权因子后的总和
    NSInteger idCardWiSum = 0;
    for(int i = 0;i < 17;i++) {
        NSInteger subStrIndex = [[identityString substringWithRange:NSMakeRange(i, 1)] integerValue];
        NSInteger idCardWiIndex = [[idCardWiArray objectAtIndex:i] integerValue];
        idCardWiSum+= subStrIndex * idCardWiIndex;
    }
    
    //计算出校验码所在数组的位置
    NSInteger idCardMod=idCardWiSum%11;
    //得到最后一位身份证号码
    NSString *idCardLast= [identityString substringWithRange:NSMakeRange(17, 1)];
    //如果等于2，则说明校验码是10，身份证号码最后一位应该是X
    if(idCardMod==2) {
        if(![idCardLast isEqualToString:@"X"]||[idCardLast isEqualToString:@"x"]) {
            return NO;
        }
    }
    else{
        //用计算出的验证码与最后一位身份证号码匹配，如果一致，说明通过，否则是无效的身份证号码
        if(![idCardLast isEqualToString: [idCardYArray objectAtIndex:idCardMod]]) {
            return NO;
        }
    }
    return YES;
}


@end
