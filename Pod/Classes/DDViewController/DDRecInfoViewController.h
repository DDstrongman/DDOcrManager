//
//  DDRecInfoViewController.h
//  DDRecBankCardAndID
//
//  Created by 李胜书 on 2017/5/3.
//  Copyright © 2017年 李胜书. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DDVideoInfoMaster.h"
#import "DDBankCardInfo.h"
#import "DDIDCardInfo.h"

@interface DDRecInfoViewController : UIViewController

/**
 识别身份证还是识别银行卡
 */
@property (nonatomic, assign) VideoType type;

@end
