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

@interface ZLPickerBrowserPhotoImageView ()

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
        progressView.progressTintColor = [UIColor whiteColor];
        progressView.trackTintColor = [UIColor lightGrayColor];
        
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
                photo.thumbImage = obj;
            }];
        }else{
            
            if (self.progressView.progress < 0.01) {
                [self.progressView setProgress:0.01 animated:NO];
            }
            
            // 网络URL
            // 加蒙版层
            if (photo.thumbImage) {
                self.backgroundColor = [UIColor blackColor];
                self.alpha = 0.7;
            }
            
            [self sd_setImageWithURL:photo.photoURL placeholderImage:photo.thumbImage options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                self.progress = (double)receivedSize / expectedSize;
            } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                self.alpha = 1.0;
                self.image = image;
                photo.thumbImage = image;
                
                [self.progressView removeFromSuperview];
                self.progressView = nil;
                
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
    
    if (progress / 100.0 != 1.0) {
        [self.progressView setProgress:progress animated:YES];
    }
}
@end
