//
//  DDVideoInfoView.m
//  DDRecBankCardAndID
//
//  Created by 李胜书 on 2017/4/17.
//  Copyright © 2017年 李胜书. All rights reserved.
//

#import "DDVideoInfoMaster.h"

#import "DDIDCardInfo.h"
#import "DDBankCardInfo.h"
#import "UIImage+DDExtension.h"
#import "DDRectManager.h"
#import "DDBankCardSearch.h"

#import "exbankcard.h"

@interface DDVideoInfoMaster ()

{
    BOOL _isInProcessing;
    BOOL _isHasResult;
}

@end

@implementation DDVideoInfoMaster

- (void)startSession {
    if (![self.captureSession isRunning]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.captureSession startRunning];
        });
    }
}

- (void)stopSession {
    if ([self.captureSession isRunning]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.captureSession stopRunning];
        });
    }
}

- (BOOL)setupSession {
    
    self.captureSession.sessionPreset = self.sessionPreset;
    
    self.verify = YES;
    
    if (![self addVideoInput:AVCaptureDevicePositionBack]) {
        return NO;
    }
    if (![self addVideoOutput]) {
        return NO;
    }
    
    [self addConnection];
    
    [self configureDevice];
    
    [self.captureSession commitConfiguration];
    
    return YES;
}

- (BOOL)addVideoInput:(AVCaptureDevicePosition)devicePosition {
    AVCaptureDevice *videoDevice=nil;
    
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    if (devicePosition == AVCaptureDevicePositionBack) {
        for (AVCaptureDevice *device in devices) {
            if ([device position] == AVCaptureDevicePositionBack) {
                if ([device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
                    NSError *error = nil;
                    if ([device lockForConfiguration:&error]) {
                        device.focusMode = AVCaptureFocusModeContinuousAutoFocus;
                        [device unlockForConfiguration];
                    }
                }
                videoDevice = device;
            }
        }
    }
    else if (devicePosition == AVCaptureDevicePositionFront) {
        for (AVCaptureDevice *device in devices){
            if ([device position] == AVCaptureDevicePositionFront) {
                if ([device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
                    NSError *error = nil;
                    if ([device lockForConfiguration:&error]) {
                        device.focusMode = AVCaptureFocusModeContinuousAutoFocus;
                        [device unlockForConfiguration];
                    }
                }
                videoDevice = device;
            }
        }
    }
    
    if (videoDevice)
    {
        NSError *error;
        
        AVCaptureDeviceInput *videoIn = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
        
        if (!error) {
            if ([[self captureSession] canAddInput:videoIn]) {
                [[self captureSession] addInput:videoIn];
                return YES;
            }
            else {
                NSLog(@"不能添加输入设备");
                return NO;
            }
        }
        else {
            NSLog(@"创建输入设备失败");
            return NO;
        }
    }
    else {
        NSLog(@"不能添加输入设备");
        return NO;
    }
    return NO;
}



- (BOOL)addVideoOutput
{
    // Create a VideoDataOutput and add it to the session
    self.videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    
    // Specify the pixel format
    self.videoDataOutput.videoSettings = [NSDictionary dictionaryWithObject:_outPutSetting forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    
    self.videoDataOutput.alwaysDiscardsLateVideoFrames = YES;
    
    // Configure your output.
    dispatch_queue_t queue = dispatch_queue_create("myQueue", NULL);
    
    [self.videoDataOutput setSampleBufferDelegate:self queue:queue];
    
    if ([self.captureSession canAddOutput:self.videoDataOutput]) {
        [self.captureSession addOutput:self.videoDataOutput];
        return YES;
    } else {
        NSLog(@"不能添加输出设备");
        return NO;
    }
    return NO;
}

- (void)addConnection {
    AVCaptureConnection *videoConnection;
    for (AVCaptureConnection *connection in[self.videoDataOutput connections]) {
        for (AVCaptureInputPort *port in[connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
                videoConnection = connection;
            }
        }
    }
    if ([videoConnection isVideoStabilizationSupported]) {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
            videoConnection.enablesVideoStabilizationWhenAvailable = YES;
        }
        else {
            videoConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
        }
    }
}

- (void)configureDevice {
    AVCaptureDevice *device = [self activeCamera];
    // Use Smooth focus
    if( YES == [device lockForConfiguration:NULL] )
    {
        if([device respondsToSelector:@selector(setSmoothAutoFocusEnabled:)] && [device isSmoothAutoFocusSupported] )
        {
            [device setSmoothAutoFocusEnabled:YES];
        }
        AVCaptureFocusMode currentMode = [device focusMode];
        if( currentMode == AVCaptureFocusModeLocked )
        {
            currentMode = AVCaptureFocusModeAutoFocus;
        }
        if( [device isFocusModeSupported:currentMode] )
        {
            [device setFocusMode:currentMode];
        }
        [device unlockForConfiguration];
    }
}

- (AVCaptureSession *)captureSession {
    if (!_captureSession) {
        _captureSession = [[AVCaptureSession alloc] init];
        [self.captureSession beginConfiguration];
    }
    return _captureSession;
}

- (AVCaptureVideoPreviewLayer *)previewLayer {
    if (!_previewLayer) {
        _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self. captureSession];
        _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    return _previewLayer;
}

- (NSString *)sessionPreset {
    if (!_sessionPreset) {
        _sessionPreset = AVCaptureSessionPreset1280x720;
    }
    return _sessionPreset;
}

- (NSNumber *)outPutSetting {
    if (!_outPutSetting) {
        //kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange
        //kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
        //kCVPixelFormatType_32BGRA
        _outPutSetting = [NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange];
    }
    return _outPutSetting;
}

- (AVCaptureDevice *)activeCamera {
    return self.activeVideoInput.device;
}


#pragma mark - AVCaptureFileOutputRecordingDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    if ([_outPutSetting isEqualToNumber:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange]] ||
        [_outPutSetting isEqualToNumber:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange]]) {
        CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        if ([captureOutput isEqual:self.videoDataOutput]) {
            if (self.videoType == 0) {
                [self idCardRecognit:imageBuffer];
            }else if (self.videoType == 1) {
                [self doRecBankCard:imageBuffer];
            }
        }
    }
    else {
        NSLog(@"输出格式不支持");
    }
}

- (void)idCardRecognit:(CVImageBufferRef)imageBuffer {
    @synchronized(self) {
        CVBufferRetain(imageBuffer);
        DDIDCardInfo *idInfo = nil;
        // Lock the image buffer
        if (CVPixelBufferLockBaseAddress(imageBuffer, 0) == kCVReturnSuccess) {
            size_t width= CVPixelBufferGetWidth(imageBuffer);
            size_t height = CVPixelBufferGetHeight(imageBuffer);
            
            CVPlanarPixelBufferInfo_YCbCrBiPlanar *planar = CVPixelBufferGetBaseAddress(imageBuffer);
            size_t offset = NSSwapBigIntToHost(planar->componentInfoY.offset);
            size_t rowBytes = NSSwapBigIntToHost(planar->componentInfoY.rowBytes);
            unsigned char* baseAddress = (unsigned char *)CVPixelBufferGetBaseAddress(imageBuffer);
            unsigned char* pixelAddress = baseAddress + offset;
            
            static unsigned char *buffer = NULL;
            if (buffer == NULL) {
                buffer = (unsigned char*)malloc(sizeof(unsigned char) * width * height);
            }
            
            memcpy(buffer, pixelAddress, sizeof(unsigned char) * width * height);
            
            unsigned char pResult[1024];
            int ret = EXCARDS_RecoIDCardData(buffer, (int)width, (int)height, (int)rowBytes, (int)8, (char*)pResult, sizeof(pResult));
            if (ret <= 0) {
                NSLog(@"ret=[%d]", ret);
            }
            else {
                NSLog(@"ret=[%d]", ret);
                char ctype;
                char content[256];
                int xlen;
                int i = 0;
                
                idInfo = [[DDIDCardInfo alloc] init];
                ctype = pResult[i++];
                idInfo.type = ctype;
                while(i < ret){
                    ctype = pResult[i++];
                    for(xlen = 0; i < ret; ++i){
                        if(pResult[i] == ' ') { ++i; break; }
                        content[xlen++] = pResult[i];
                    }
                    content[xlen] = 0;
                    if(xlen) {
                        NSStringEncoding gbkEncoding =CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
                        if(ctype == 0x21)
                            idInfo.number = [NSString stringWithCString:(char *)content encoding:gbkEncoding];
                        else if(ctype == 0x22)
                            idInfo.name = [NSString stringWithCString:(char *)content encoding:gbkEncoding];
                        else if(ctype == 0x23)
                            idInfo.gender = [NSString stringWithCString:(char *)content encoding:gbkEncoding];
                        else if(ctype == 0x24)
                            idInfo.nation = [NSString stringWithCString:(char *)content encoding:gbkEncoding];
                        else if(ctype == 0x25)
                            idInfo.address = [NSString stringWithCString:(char *)content encoding:gbkEncoding];
                        else if(ctype == 0x26)
                            idInfo.issue = [NSString stringWithCString:(char *)content encoding:gbkEncoding];
                        else if(ctype == 0x27)
                            idInfo.valid = [NSString stringWithCString:(char *)content encoding:gbkEncoding];
                    }
                }
                
                static DDIDCardInfo *lastIdInfo = nil;
                if (self.verify) {
                    if (lastIdInfo == nil) {
                        lastIdInfo = idInfo;
                        idInfo = nil;
                    }
                    else {
                        if (![lastIdInfo isEqual:idInfo]){
                            lastIdInfo = idInfo;
                            idInfo = nil;
                        }
                    }
                }
                if (lastIdInfo.isReady) {
                    NSLog(@"%@", [lastIdInfo sumString]);
                } else {
                    idInfo = nil;
                }
            }
            if (idInfo != nil) {
                CGSize size = CGSizeMake(width, height);
                CGRect effectRect = [DDRectManager getEffectImageRect:size];
                CGRect rect = [DDRectManager getGuideFrame:effectRect];
                UIImage *image = [UIImage getImageStream:imageBuffer];
                __block UIImage *subImg = [UIImage getSubImage:rect inImage:image];
                dispatch_async(dispatch_get_main_queue(), ^{
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                    if([self.ocrDelegate respondsToSelector:@selector(didEndRecInfo:Image:)]) {
                        [self.ocrDelegate didEndRecInfo:idInfo Image:subImg];
                    }
                });
            }
            CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
        }
        CVBufferRelease(imageBuffer);
    }
}

- (void)doRecBankCard:(CVImageBufferRef)imageBuffer {
    @synchronized(self) {
        _isInProcessing = YES;
        CVBufferRetain(imageBuffer);
        if(_isHasResult == YES) {
            return;
        }
        if(CVPixelBufferLockBaseAddress(imageBuffer, 0) == kCVReturnSuccess) {
            size_t width_t= CVPixelBufferGetWidth(imageBuffer);
            size_t height_t = CVPixelBufferGetHeight(imageBuffer);
            CVPlanarPixelBufferInfo_YCbCrBiPlanar *planar = CVPixelBufferGetBaseAddress(imageBuffer);
            size_t offset = NSSwapBigIntToHost(planar->componentInfoY.offset);
            
            unsigned char* baseAddress = (unsigned char *)CVPixelBufferGetBaseAddress(imageBuffer);
            unsigned char* pixelAddress = baseAddress + offset;
            
            size_t cbCrOffset = NSSwapBigIntToHost(planar->componentInfoCbCr.offset);
            uint8_t *cbCrBuffer = baseAddress + cbCrOffset;
            
            CGSize size = CGSizeMake(width_t, height_t);
            CGRect effectRect = [DDRectManager getEffectImageRect:size];
            CGRect rect = [DDRectManager getGuideFrame:effectRect];
            
            int width = ceilf(width_t);
            int height = ceilf(height_t);
            
            unsigned char result [512];
            int resultLen = BankCardNV12(result, 512, pixelAddress, cbCrBuffer, width, height, rect.origin.x, rect.origin.y, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
            
            if(resultLen > 0)
            {
                int charCount = [DDRectManager docode:result len:resultLen];
                if(charCount > 0) {
                    CGRect subRect = [DDRectManager getCorpCardRect:width height:height guideRect:rect charCount:charCount];
                    UIImage *image = [UIImage getImageStream:imageBuffer];
                    __block UIImage *subImg = [UIImage getSubImage:subRect inImage:image];
                    
                    char *numbers = [DDRectManager getNumbers];
                    
                    __block NSString *numberStr = [NSString stringWithCString:numbers encoding:NSASCIIStringEncoding];
                    __block NSString *bank = [DDBankCardSearch getBankNameByBin:numbers count:charCount];
                    
                    DDBankCardInfo *bankCardInfo = [[DDBankCardInfo alloc]init];
                    bankCardInfo.number = numberStr;
                    bankCardInfo.bankName = bank;
                    
                    static DDBankCardInfo *lastBankCardInfo = nil;
                    if (self.verify) {
                        if (lastBankCardInfo == nil) {
                            lastBankCardInfo = bankCardInfo;
                            bankCardInfo = nil;
                        }
                        else {
                            if (![lastBankCardInfo isEqual:bankCardInfo]){
                                lastBankCardInfo = bankCardInfo;
                                bankCardInfo = nil;
                            }
                        }
                    }
                    if (lastBankCardInfo.isReady) {
                        NSLog(@"%@", [lastBankCardInfo sumString]);
                    } else {
                        bankCardInfo = nil;
                    }
                    
                    if (bankCardInfo != nil) {
                        _isHasResult = YES;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                            if ([self.ocrDelegate respondsToSelector:@selector(didEndRecInfo:Image:)]) {
                                [self.ocrDelegate didEndRecInfo:bankCardInfo Image:subImg];
                            }
                        });
                    }
                }
            }
            CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
            _isInProcessing = NO;
        }
        CVBufferRelease(imageBuffer);
    }
}



@end
