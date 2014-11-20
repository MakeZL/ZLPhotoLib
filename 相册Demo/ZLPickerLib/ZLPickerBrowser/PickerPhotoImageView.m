//
//  PickerImageView.m
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 14-11-15.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import "PickerPhotoImageView.h"
#import "PickerPhoto.h"
#import "PickerDatas.h"
#import "UIImageView+WebCache.h"
#import "PickerProgressView.h"
#import "UIView+Extension.h"
#import "PickerCommon.h"

@interface PickerPhotoImageView ()

@property (assign, nonatomic) CGFloat progress;
@property (weak, nonatomic) CAShapeLayer *progressLayer;
@property (weak, nonatomic) CAShapeLayer *backgroundLayer;

// 进度ProgressView
@property (nonatomic , weak) PickerProgressView *progressView;


@end

@implementation PickerPhotoImageView



#pragma mark -ProgressView
- (PickerProgressView *)progressView{
    if (!_progressView) {
        PickerProgressView *progressView = [[PickerProgressView alloc] init];
        CGFloat progressW = ZLPickerProgressViewW;
        CGFloat progressX = (self.width - progressW) / 2.0;
        CGFloat progressH = ZLPickerProgressViewH;
        CGFloat progressY = (self.height - progressH) / 2.0;
        
        progressView.frame = CGRectMake(progressX, progressY, progressW, progressH);
        progressView.progressTintColor = [UIColor grayColor];
        progressView.borderTintColor = [UIColor lightGrayColor];
        [self addSubview:progressView];
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

#pragma mark -初始化
- (void) setupProperty{
    self.contentMode = UIViewContentModeScaleAspectFit;
    self.clipsToBounds = YES;
}

- (void)setPhoto:(PickerPhoto *)photo{
    _photo = photo;
    [self loadingPhoto];
}

- (void) loadingPhoto{
    
    PickerPhoto *photo = self.photo;
    if (photo.photoURL.absoluteString.length) {
        // 本地相册
        NSRange photoRange = [photo.photoURL.absoluteString rangeOfString:@"assets-library"];
        if (photoRange.location != NSNotFound){
            [[PickerDatas defaultPicker] getAssetsPhotoWithURLs:photo.photoURL callBack:^(UIImage *obj) {
                self.image = obj;
            }];
        }else{
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
                [self.progressView removeFromSuperview];
                self.progressView = nil;
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
