//
//  DDIDCardInfo.h
//  DDRecBankCardAndID
//
//  Created by 李胜书 on 2017/4/17.
//  Copyright © 2017年 李胜书. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DDIDCardInfo : NSObject

/**
 身份证正反面：1:正面  2:反面
 */
@property (nonatomic, assign) int type;

//正面信息
/**
 身份证号
 */
@property (nonatomic, strong) NSString *number;
/**
 姓名
 */
@property (nonatomic, strong) NSString *name;
/**
 性别
 */
@property (nonatomic, strong) NSString *gender;
/**
 民族
 */
@property (nonatomic, strong) NSString *nation;
/**
 地址
 */
@property (nonatomic, strong) NSString *address;

//反面信息
/**
 签发机关
 */
@property (nonatomic, strong) NSString *issue;
/**
 有效期
 */
@property (nonatomic, strong) NSString *valid;

/**
 正面或者反面的信息是否正确
 */
@property (nonatomic, assign) BOOL isReady;

/**
 所有身份证信息整理成字符串

 @return 返回整理后的字符串
 */
- (NSString *)sumString;


@end
