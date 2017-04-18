//
//  DDIDCardInfo.m
//  DDRecBankCardAndID
//
//  Created by 李胜书 on 2017/4/17.
//  Copyright © 2017年 李胜书. All rights reserved.
//

#import "DDIDCardInfo.h"

@implementation DDIDCardInfo

- (BOOL)isReady {
    if (_number != nil && _name != nil && _gender != nil && _nation != nil && _address != nil) {
        if (_number.length > 0 && _name.length > 0 && _gender.length > 0 && _nation.length > 0 && _address.length > 0) {
            return YES;
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

@end
