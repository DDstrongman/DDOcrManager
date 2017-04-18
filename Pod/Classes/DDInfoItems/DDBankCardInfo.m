//
//  DDBankCardInfo.m
//  DDRecBankCardAndID
//
//  Created by 李胜书 on 2017/4/17.
//  Copyright © 2017年 李胜书. All rights reserved.
//

#import "DDBankCardInfo.h"

@implementation DDBankCardInfo

- (BOOL)isReady {
    if (_number != nil && _bankName != nil) {
        if (_number.length > 0 && _bankName.length > 0) {
            return YES;
        }
    }
    return NO;
}

- (NSString *)sumString {
    return [NSString stringWithFormat:@"银行卡号:%@\n银行名:%@",
            _number, _bankName];
}

@end
