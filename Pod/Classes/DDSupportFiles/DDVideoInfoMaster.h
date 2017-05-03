//
//  DDVideoInfoMaster.h
//  DDRecBankCardAndID
//
//  Created by 李胜书 on 2017/4/17.
//  Copyright © 2017年 李胜书. All rights reserved.
//



typedef enum {
    VideoIDCardType = 0,
    VideoBankCardType
}VideoType;

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#import "excards.h"

@protocol OcrInfoDelegate<NSObject>

@optional

/**
 调用失败

 @param error 失败原因
 */
- (void)deviceConfigurationFailedWithError:(NSError *)error;
/**
 识别成功后的返回

 @param infoItem 识别成功后的info类
 @param image 识别成功时的图片
 */
- (void)didEndRecInfo:(id)infoItem Image:(UIImage*)image;

@end

@interface DDVideoInfoMaster : NSObject

/**
 识别视频流的类型，0：识别身份证，1：识别银行卡。目前只支持此两种
 */
@property (nonatomic, assign) VideoType videoType;
@property (nonatomic, assign) id<OcrInfoDelegate> ocrDelegate;

///AVCaptureSession对象来执行输入设备和输出设备之间的数据传递
@property (nonatomic, strong) AVCaptureSession          *captureSession;
///AVCaptureDeviceInput对象是输入流
@property (nonatomic, strong) AVCaptureDeviceInput      *activeVideoInput;
///出流对象
@property (nonatomic, strong) AVCaptureVideoDataOutput  *videoDataOutput;
///创建预览层
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
///图片质量
@property (nonatomic, copy  ) NSString *sessionPreset;
///输出格式
@property (strong,nonatomic ) NSNumber *outPutSetting;

@property (nonatomic, assign) BOOL verify;

- (BOOL)setupSession;
- (void)startSession;
- (void)stopSession;

@end
