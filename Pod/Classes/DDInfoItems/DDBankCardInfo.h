//
//  DDBankCardInfo.h
//  DDRecBankCardAndID
//
//  Created by 李胜书 on 2017/4/17.
//  Copyright © 2017年 李胜书. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DDBankCardInfo : NSObject

/**
 银行卡号
 */
@property (nonatomic, strong) NSString *number;
/**
 银行名称
 */
@property (nonatomic, strong) NSString *bankName;

/**
 银行卡的信息是否正确
 */
@property (nonatomic, assign) BOOL isReady;

/**
 所有银行卡信息整理成字符串
 
 @return 返回整理后的字符串
 */
- (NSString *)sumString;

@end
