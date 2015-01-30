//
//  PickerPhotoScrollView.m
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 14-11-14.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import "ZLPhotoPickerBrowserPhotoScrollView.h"
#import "UIView+Extension.h"
#import "ZLPhotoPickerBrowserPhotoImageView.h"
#import "ZLPhotoPickerBrowserPhoto.h"
#import "ZLPhotoPickerCommon.h"

@interface ZLPhotoPickerBrowserPhotoScrollView () <UIScrollViewDelegate,ZLPickerBrowserPhotoImageViewDelegate>

@property (nonatomic , weak) ZLPhotoPickerBrowserPhotoImageView *zoomImageView;
@property (nonatomic , assign) CGFloat progress;
@property (nonatomic , strong) UITapGestureRecognizer *scaleTap;
@property (nonatomic , strong) UITapGestureRecognizer *signleTap;
@property (assign,nonatomic) CGRect firstFrame;
@property (assign,nonatomic) BOOL firstLayout;
@property (assign,nonatomic) UIDeviceOrientation orientation;

@end

@implementation ZLPhotoPickerBrowserPhotoScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setProperty];
    }
    return self;
}


- (void)setProperty
{
    self.backgroundColor = [UIColor blackColor];
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.decelerationRate = UIScrollViewDecelerationRateFast;
    self.delegate = self;
    self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    // 设置最大伸缩比例
    self.maximumZoomScale = ZLPickerScrollViewMaxZoomScale;
    // 设置最小伸缩比例
    self.minimumZoomScale = ZLPickerScrollViewMinZoomScale;
    
    // 监听手势
    [self addGesture];
    
}

- (void)setCancleSingleClick:(BOOL)cancleSingleClick{
    _cancleSingleClick = cancleSingleClick;
    
    if (cancleSingleClick) {
        [self removeGestureRecognizer:self.signleTap];
    }else{
        [self addGestureRecognizer:self.signleTap];
    }
}

#pragma mark -监听手势
- (void) addGesture{
    
    // 双击放大
    UITapGestureRecognizer *scaleBigTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scaleBigTap:)];
    scaleBigTap.numberOfTapsRequired = 2;
    scaleBigTap.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:scaleBigTap];
    self.scaleTap = scaleBigTap;
    
    // 单击缩小
    UITapGestureRecognizer *disMissTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(disMissTap:)];
    disMissTap.numberOfTapsRequired = 1;
    disMissTap.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:disMissTap];
    self.signleTap = disMissTap;
    // 只能有一个手势存在
    [disMissTap requireGestureRecognizerToFail:scaleBigTap];
}

#pragma mark - disMissTap
- (void) disMissTap:(UITapGestureRecognizer *)tap{
    if ([self.photoScrollViewDelegate respondsToSelector:@selector(pickerPhotoScrollViewDidSingleClick:)]) {
        [self.photoScrollViewDelegate pickerPhotoScrollViewDidSingleClick:self];
    }
}

#pragma mark - setPhoto
- (void)setPhoto:(ZLPhotoPickerBrowserPhoto *)photo{
    _photo = photo;
    
    // 避免cell重复创建控件，删除再添加
    [[self.subviews lastObject] removeFromSuperview];
    
    ZLPhotoPickerBrowserPhotoImageView *zoomImageView = [[ZLPhotoPickerBrowserPhotoImageView alloc] initWithFrame:self.frame];
    [self addSubview:zoomImageView];
    
    zoomImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.zoomImageView = zoomImageView;
    
    UITapGestureRecognizer *scaleBigTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scaleBigTap:)];
    scaleBigTap.numberOfTapsRequired = 2;
    scaleBigTap.numberOfTouchesRequired = 1;
    _zoomImageView.userInteractionEnabled = YES;
    [_zoomImageView addGestureRecognizer:scaleBigTap];
    self.scaleTap = scaleBigTap;
    
    
    __weak typeof(self) weakSelf = self;
    
    zoomImageView.downLoadWebImageCallBlock = ^{
        // 下载完毕后重新计算下Frame
        [weakSelf setMaxMinZoomScalesForCurrentBounds];
    };
    
    zoomImageView.delegate = self;
    zoomImageView.scrollView = self;
    zoomImageView.photo = photo;
    [zoomImageView setProgress:self.progress];
    
    if (!photo.photoURL.absoluteString.length) {
        [self setMaxMinZoomScalesForCurrentBounds];
    }
    
}


- (void) scaleBigTap:(UITapGestureRecognizer *)tap{
    // Zoom
    // 重置
    if (self.zoomScale == self.maximumZoomScale) {
        [UIView animateWithDuration:.3 animations:^{
            if (_zoomImageView.height < _zoomImageView.width * 2) {
                _zoomImageView.y = self.firstFrame.origin.y;
            }else{
                _zoomImageView.x = (self.width - ((_zoomImageView.width / self.maximumZoomScale * self.minimumZoomScale))) / 2.;
            }
            [self setZoomScale:self.minimumZoomScale animated:NO];
        } completion:^(BOOL finished) {
        }];
        
    }else{
        
        CGPoint touchPoint = [tap locationInView:tap.view];
        CGFloat touchX = touchPoint.x;
        CGFloat touchY = touchPoint.y;
        
        if ([tap.view isEqual:self]) {
            touchX *= 1/self.zoomScale;
            touchY *= 1/self.zoomScale;
            touchX += self.contentOffset.x;
            touchY += self.contentOffset.y;
        }
        
        
        if (self.zoomImageView.image.size.width < self.width && self.zoomImageView.image.size.height < self.height && self.zoomImageView.image.size.width >= self.zoomImageView.image.size.height) {
            
            self.zoomImageView.y  -= ((self.height - _zoomImageView.height / self.zoomScale * self.maximumZoomScale) / 2);
        }
        
        [UIView animateWithDuration:.30 animations:^{
            [self zoomToRect:CGRectMake(touchX, touchY, 0, 0 ) animated:NO];
            self.zoomImageView.x = 0;
            self.zoomImageView.y = 0;
        }];
        
    }
}

#pragma mark - disMissTap

- (void)pickerBrowserPhotoImageViewDownloadProgress:(CGFloat)progress{
    self.progress = progress;
    
    if (progress / 1.0 == 1.0) {
        [self addGestureRecognizer:self.scaleTap];
    }else {
        [self removeGestureRecognizer:self.scaleTap];
    }
    
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _zoomImageView;
}

#pragma mark - setMaxMinZoomScalesForCurrentBounds
- (void)setMaxMinZoomScalesForCurrentBounds {
    
    if (_zoomImageView.image == nil) return;
    
    _zoomImageView.frame = (CGRect) {CGPointZero , _zoomImageView.image.size};
    
    // Sizes
    CGSize boundsSize = self.bounds.size;
    CGSize imageSize = _zoomImageView.image.size;
    
    // 获取最小比例
    CGFloat xScale = boundsSize.width / imageSize.width;
    CGFloat yScale = boundsSize.height / imageSize.height;
    CGFloat minScale = MIN(xScale, yScale);
    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.maximumZoomScale = self.maximumZoomScale + 1.0;
    }
    // 最大的比例不能超过1.0，最小比例按屏幕来拉伸
    if (xScale > 1 && yScale > 1) {
        minScale = MIN(xScale, yScale);
    }
    
    // 初始化拉伸比例
    self.minimumZoomScale = minScale;
    self.zoomScale = minScale;
    
    // 重置
    //    _zoomImageView.frame = CGRectMake(0, 0, self.zoomImageView.width, self.zoomImageView.height);
    
    // 避免不能滚动
    if (((NSInteger)_zoomImageView.width > self.width)) {
        return;
    }
    self.contentSize = CGSizeMake(self.width, 0);
    
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = _zoomImageView.frame;
    
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = floorf((boundsSize.width - frameToCenter.size.width) / 2.0);
    } else {
        frameToCenter.origin.x = 0;
    }
    
    // 计算垂直方向居中
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = floorf((boundsSize.height - frameToCenter.size.height) / 2.0);
    } else {
        frameToCenter.origin.y = 0;
    }
    
    if (CGRectIsEmpty(self.firstFrame) && frameToCenter.origin.y > 0) {
        self.firstFrame = frameToCenter;
    }
    
    // Center
    if (!CGRectEqualToRect(_zoomImageView.frame, frameToCenter))
        _zoomImageView.frame = frameToCenter;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
