//
//  DDRecInfoViewController.m
//  DDRecBankCardAndID
//
//  Created by 李胜书 on 2017/5/3.
//  Copyright © 2017年 李胜书. All rights reserved.
//

#import "DDRecInfoViewController.h"

#import "IDOverLayerView.h"

@interface DDRecInfoViewController ()<OcrInfoDelegate>

@property (nonatomic, strong) IDOverLayerView *overlayView;
@property (nonatomic, strong) DDVideoInfoMaster *ocrMaster;

@end

@implementation DDRecInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initIDCart];
    
    [self.view insertSubview:self.overlayView atIndex:0];
    
    self.ocrMaster.ocrDelegate = self;
    self.ocrMaster.videoType = self.type;
    self.ocrMaster.verify = YES;
    
    self.ocrMaster.sessionPreset = AVCaptureSessionPresetHigh;
    
    self.ocrMaster.outPutSetting = [NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange];
    
    if ([self.ocrMaster setupSession]) {
        UIView *view = [[UIView alloc] initWithFrame:self.view.bounds];
        [self.view insertSubview:view atIndex:0];
        self.ocrMaster.previewLayer.frame = [UIScreen mainScreen].bounds;
        [view.layer addSublayer:self.ocrMaster.previewLayer];
        [self.ocrMaster startSession];
    }
    else {
        NSLog(@"打开相机失败");
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if([self.ocrMaster.captureSession isRunning]) {
        [self.ocrMaster.captureSession stopRunning];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if([self.ocrMaster.captureSession isRunning] == NO) {
        [self.ocrMaster.captureSession startRunning];
    }
}

static bool initFlag = NO;

- (void)initIDCart {
    if (!initFlag) {
        const char *thePath = [[[NSBundle mainBundle] resourcePath] UTF8String];
        int ret = EXCARDS_Init(thePath);
        if (ret != 0) {
            NSLog(@"初始化失败：ret=%d", ret);
        }
        initFlag = YES;
    }
}

- (DDVideoInfoMaster *)ocrMaster {
    if (!_ocrMaster) {
        _ocrMaster = [[DDVideoInfoMaster alloc] init];
    }
    return _ocrMaster;
}

- (IDOverLayerView *)overlayView {
    if(!_overlayView) {
        CGRect rect = [IDOverLayerView getOverlayFrame:[UIScreen mainScreen].bounds];
        _overlayView = [[IDOverLayerView alloc] initWithFrame:rect];
    }
    return _overlayView;
}

#pragma mark - CaptureDelegate
- (void)didEndRecInfo:(id)infoItem Image:(UIImage*)image {
    self.ocrResultBlock(infoItem, image);
    [self.ocrMaster stopSession];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
