//
//  PickerPhotoScrollView.m
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 14-11-14.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import "ZLPickerBrowserPhotoScrollView.h"
#import "UIView+Extension.h"
#import "ZLPickerBrowserPhotoImageView.h"
#import "ZLPickerBrowserPhoto.h"
#import "ZLPickerBrowserPhotoGifView.h"
#import "ZLPickerCommon.h"

@interface ZLPickerBrowserPhotoScrollView () <UIScrollViewDelegate,ZLPickerBrowserPhotoImageViewDelegate>

@property (nonatomic , weak) ZLPickerBrowserPhotoImageView *zoomImageView;
@property (nonatomic , assign) CGFloat progress;
@property (nonatomic , strong) UITapGestureRecognizer *scaleTap;

@end

@implementation ZLPickerBrowserPhotoScrollView

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
    // 只能有一个手势存在
    [disMissTap requireGestureRecognizerToFail:scaleBigTap];
}

- (void) scaleBigTap:(UITapGestureRecognizer *)tap{
    // Zoom
    // 重置
    if (self.zoomScale == self.maximumZoomScale) {
        [self setZoomScale:self.minimumZoomScale animated:YES];
    }else{
        CGPoint touchPoint = [tap locationInView:tap.view];
        
        CGFloat scale = self.zoomImageView.image.size.width / self.width;
        CGFloat scaleH = self.zoomImageView.image.size.height / self.height;
        
        
        CGFloat x = touchPoint.x * scale; //(self.zoomImageView.image.size.width - touchPoint.x * scale);
        
        CGFloat y = touchPoint.y * scaleH ;//(self.zoomImageView.image.size.height - touchPoint.y) / 2;
        
        [self zoomToRect:CGRectMake(x, y, 0 , 0) animated:YES];
    }
}

#pragma mark - disMissTap
- (void) disMissTap:(UITapGestureRecognizer *)tap{
    if ([self.photoScrollViewDelegate respondsToSelector:@selector(pickerPhotoScrollViewDidSingleClick:)]) {
        [self.photoScrollViewDelegate pickerPhotoScrollViewDidSingleClick:self];
    }
}

#pragma mark - setPhoto
- (void)setPhoto:(ZLPickerBrowserPhoto *)photo{
    _photo = photo;
    
    // 避免cell重复创建控件，删除再添加
    [[self.subviews lastObject] removeFromSuperview];
    
    // 判断是否为gif图片，不是的话就正常来展示图片
    
    if ([photo.photoURL.absoluteString hasSuffix:@"gif"]) {
        ZLPickerBrowserPhotoGifView *gifView = [[ZLPickerBrowserPhotoGifView alloc] init];
        gifView.frame = self.bounds;
        [gifView playGifWithURLString:photo.photoURL.absoluteString];
        [self addSubview:gifView];
    }else{
        ZLPickerBrowserPhotoImageView *zoomImageView = [[ZLPickerBrowserPhotoImageView alloc] init];
        
        zoomImageView.frame = self.bounds;
        [self addSubview:zoomImageView];
        self.zoomImageView = zoomImageView;
        
        zoomImageView.downLoadWebImageCallBlock = ^{
            // 下载完毕后重新计算下Frame
            [self setMaxMinZoomScalesForCurrentBounds];
        };
        
        zoomImageView.delegate = self;
        zoomImageView.scrollView = self;
        zoomImageView.photo = photo;
        [zoomImageView setProgress:self.progress];
        
        if (!photo.photoURL.absoluteString.length) {
            [self setMaxMinZoomScalesForCurrentBounds];
        }
    }
    
    
}

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
    
    
    // Layout
    [self setNeedsLayout];
    
}


- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    // 避免不能滚动
    if (!( (NSInteger)_zoomImageView.width > self.width)) {
        self.contentSize = CGSizeMake(self.width, 0);
    }
    
    // Size
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = _zoomImageView.frame;
    
    // 计算水平方向居中
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
    
    // Center
    if (!CGRectEqualToRect(_zoomImageView.frame, frameToCenter))
        _zoomImageView.frame = frameToCenter;
}


@end
