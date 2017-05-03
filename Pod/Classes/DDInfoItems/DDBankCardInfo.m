//
//  DDBankCardInfo.m
//  DDRecBankCardAndID
//
//  Created by 李胜书 on 2017/4/17.
//  Copyright © 2017年 李胜书. All rights reserved.
//

#import "DDBankCardInfo.h"

@implementation DDBankCardInfo

- (BOOL)isEqual:(DDBankCardInfo *)idInfo {
    if (idInfo == nil) {
        return NO;
    }
    if ([_number isEqualToString:idInfo.number] &&
        [_bankName isEqualToString:idInfo.bankName]) {
        return YES;
    }
    return NO;
}


- (BOOL)isReady {
    if (_number != nil && _bankName != nil) {
        if (_number.length > 0 && _bankName.length > 0) {
            if ([self isBankCard:_number]) {
                return YES;
            }
        }
    }
    return NO;
}

- (NSString *)sumString {
    return [NSString stringWithFormat:@"银行卡号:%@\n银行名:%@",
            _number, _bankName];
}

#pragma mark 判断银行卡号是否合法
- (BOOL)isBankCard:(NSString *)cardNumber {
    if(cardNumber.length == 0){
        return NO;
    }
    cardNumber = [cardNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *digitsOnly = @"";
    char c;
    for (int i = 0; i < cardNumber.length; i++){
        c = [cardNumber characterAtIndex:i];
        if (isdigit(c)){
            digitsOnly =[digitsOnly stringByAppendingFormat:@"%c",c];
        }
    }
    int sum = 0;
    int digit = 0;
    int addend = 0;
    BOOL timesTwo = false;
    for (NSInteger i = digitsOnly.length - 1; i >= 0; i--){
        digit = [digitsOnly characterAtIndex:i] - '0';
        if (timesTwo){
            addend = digit * 2;
            if (addend > 9) {
                addend -= 9;
            }
        }
        else {
            addend = digit;
        }
        sum += addend;
        timesTwo = !timesTwo;
    }
    int modulus = sum % 10;
    return modulus == 0;
}

@end
