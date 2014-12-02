//
//  PickerImageView.m
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 14-11-15.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import "ZLPickerBrowserPhotoImageView.h"
#import "ZLPickerBrowserPhoto.h"
#import "ZLPickerDatas.h"
#import "UIImageView+WebCache.h"
#import "DACircularProgressView.h"
#import "UIView+Extension.h"
#import "ZLPickerCommon.h"

@interface ZLPickerBrowserPhotoImageView () <UIActionSheetDelegate>

@property (assign, nonatomic) CGFloat progress;
@property (weak, nonatomic) CAShapeLayer *progressLayer;
@property (weak, nonatomic) CAShapeLayer *backgroundLayer;

// 进度ProgressView
@property (nonatomic , weak) DACircularProgressView *progressView;
@end

@implementation ZLPickerBrowserPhotoImageView



#pragma mark -ProgressView
- (DACircularProgressView *)progressView{
    if (!_progressView) {
        DACircularProgressView *progressView = [[DACircularProgressView alloc] init];
        
        progressView.frame = CGRectMake(0, 0, ZLPickerProgressViewW, ZLPickerProgressViewH);
        progressView.center = CGPointMake([UIScreen mainScreen].bounds.size.width * 0.5, [UIScreen mainScreen].bounds.size.height * 0.5);
        progressView.roundedCorners = YES;
        if (iOS7gt) {
            progressView.thicknessRatio = 0.1;
            progressView.roundedCorners = NO;
        } else {
            progressView.thicknessRatio = 0.2;
            progressView.roundedCorners = YES;
        }
        //        progressView.progressTintColor = [UIColor whiteColor];
        //        progressView.trackTintColor = [UIColor lightGrayColor];
        
        [self.scrollView addSubview:progressView];
        //        [[[[UIApplication sharedApplication] windows] lastObject] addSubview:progressView];
        self.progressView = progressView;
    }
    return _progressView;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setupProperty];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        [self setupProperty];
    }
    return self;
}

#pragma mark -初始化
- (void) setupProperty{
    self.contentMode = UIViewContentModeScaleAspectFit;
    self.clipsToBounds = YES;
    self.userInteractionEnabled = YES;
    
    // 长按保存图片
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressToDo:)];
    [self addGestureRecognizer:longPressGesture];
    
}


- (void) longPressToDo:(UILongPressGestureRecognizer *) longGesture{
    if (longGesture.state == UIGestureRecognizerStateBegan) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"保存", nil];
        
        [actionSheet showInView:self];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        UIImageWriteToSavedPhotosAlbum(self.image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error  contextInfo:(void *)contextInfo{
    if (error != NULL){
        //失败
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"保存到相册失败\n无法访问相册" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
        [alertView show];
    }
    else{
        //成功
    }
}


- (void)setPhoto:(ZLPickerBrowserPhoto *)photo{
    _photo = photo;
    [self loadingPhoto];
}

- (void) loadingPhoto{
    
    ZLPickerBrowserPhoto *photo = self.photo;
    if (photo.photoURL.absoluteString.length) {
        // 本地相册
        NSRange photoRange = [photo.photoURL.absoluteString rangeOfString:@"assets-library"];
        if (photoRange.location != NSNotFound){
            [[ZLPickerDatas defaultPicker] getAssetsPhotoWithURLs:photo.photoURL callBack:^(UIImage *obj) {
                self.image = obj;
            }];
        }else{
            
            // 网络URL
            [self sd_setImageWithURL:photo.photoURL placeholderImage:photo.thumbImage options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                self.progress = (double)receivedSize / expectedSize;
            } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                self.image = image;
                // 下载完回调
                if (self.downLoadWebImageCallBlock) {
                    self.downLoadWebImageCallBlock();
                }
            }];
            
        }
        
        
    }  else if (photo.photoImage){
        self.image = photo.photoImage;
    }
    
}

#pragma mark 设置进度条数
- (void)setProgress:(CGFloat)progress{
    _progress = progress;
    
    if (progress == 0) return ;
    
    if ([self.delegate respondsToSelector:@selector(pickerBrowserPhotoImageViewDownloadProgress:)]) {
        [self.delegate pickerBrowserPhotoImageViewDownloadProgress:progress];
    }
    
    if (progress / 1.0 != 1.0) {
        [self.progressView setProgress:progress animated:YES];
    }else{
        [self.progressView removeFromSuperview];
        self.progressView = nil;
    }
}
@end
