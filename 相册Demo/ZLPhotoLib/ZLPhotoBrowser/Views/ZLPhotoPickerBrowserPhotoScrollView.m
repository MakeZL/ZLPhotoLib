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

- (void) scaleBigTap:(UITapGestureRecognizer *)tap{
    // Zoom
    // 重置
    CGPoint touchPoint = [tap locationInView:tap.view];
    CGFloat touchX = touchPoint.x;
    CGFloat touchY = touchPoint.y;
    
    if ([tap.view isEqual:self]) {
        touchX *= 1/self.zoomScale;
        touchY *= 1/self.zoomScale;
        touchX += self.contentOffset.x;
        touchY += self.contentOffset.y;
    }
    
    
    // Zoom
    if (self.zoomScale != self.minimumZoomScale && self.zoomScale != [self initialZoomScaleWithMinScale]) {
        
        [UIView animateWithDuration:.3 animations:^{
            _zoomImageView.y = self.firstFrame.origin.y;
            _zoomImageView.x = self.firstFrame.origin.x;
            [self setZoomScale:self.minimumZoomScale animated:NO];
        } completion:^(BOOL finished) {
        }];
        
    } else {
        
        // Zoom in to twice the size
        CGFloat newZoomScale = ((self.maximumZoomScale + self.minimumZoomScale) / 2);
        CGFloat xsize = self.bounds.size.width / newZoomScale;
        CGFloat ysize = self.bounds.size.height / newZoomScale;
        
        
        
        [UIView animateWithDuration:.25 animations:^{
            
            if (self.bounds.size.width > _zoomImageView.width) {
                _zoomImageView.y = _zoomImageView.height / ([UIScreen mainScreen].bounds.size.height / (_zoomImageView.height * self.zoomScale * self.maximumZoomScale)) + ZLPickerColletionViewPadding / 4. ;
                
                _zoomImageView.x = ZLPickerColletionViewPadding / 3.;
            }else{
                _zoomImageView.y = 0;
                _zoomImageView.x = 0;
            }
            
            [self zoomToRect:CGRectMake(touchX - xsize/2, touchY - ysize/2, xsize, ysize) animated:NO];
        }];
    }
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
    
    ZLPhotoPickerBrowserPhotoImageView *zoomImageView = [[ZLPhotoPickerBrowserPhotoImageView alloc] initWithFrame:CGRectZero];
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
        [weakSelf displayImage];
    };
    
    zoomImageView.delegate = self;
    zoomImageView.scrollView = self;
    zoomImageView.photo = photo;
    [zoomImageView setProgress:self.progress];
    
    if (zoomImageView.image) {
        [self displayImage];
    }else if (!photo.photoURL.absoluteString.length) {
        [self setMaxMinZoomScalesForCurrentBounds];
    }
    
}

- (void)displayImage {
//    if ( _zoomImageView.image == nil) {
    
        // Reset
        self.maximumZoomScale = 1;
        self.minimumZoomScale = 1;
        self.zoomScale = 1;
        self.contentSize = CGSizeMake(0, 0);
        
        // Get image from browser as it handles ordering of fetching
        if (_zoomImageView.image) {
            
            // Setup photo frame
            CGRect photoImageViewFrame;
            photoImageViewFrame.origin = CGPointZero;
            photoImageViewFrame.size = _zoomImageView.image.size;
            _zoomImageView.frame = photoImageViewFrame;
            self.contentSize = photoImageViewFrame.size;
            
            // Set zoom to minimum zoom
            [self setMaxMinZoomScalesForCurrentBounds];
            
        }
        
        [self setNeedsLayout];
//    }
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
    
    // Reset
    self.maximumZoomScale = 1;
    self.minimumZoomScale = 1;
    self.zoomScale = 1;
    
    // Bail if no image
    if (_zoomImageView.image == nil) return;
    
    // Reset position
    _zoomImageView.frame = CGRectMake(0, 0, _zoomImageView.frame.size.width, _zoomImageView.frame.size.height);
    
    // Sizes
    CGSize boundsSize = self.bounds.size;
    CGSize imageSize = _zoomImageView.image.size;
    
    // Calculate Min
    CGFloat xScale = boundsSize.width / imageSize.width;    // the scale needed to perfectly fit the image width-wise
    CGFloat yScale = boundsSize.height / imageSize.height;  // the scale needed to perfectly fit the image height-wise
    CGFloat minScale = MIN(xScale, yScale);                 // use minimum of these to allow the image to become fully visible
    
    // Calculate Max
    CGFloat maxScale = 3;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // Let them go a bit bigger on a bigger screen!
        maxScale = 4;
    }
    
    // Image is smaller than screen so no zooming!
    if (xScale >= 1 && yScale >= 1) {
        minScale = 1.0;
    }
    
    
    // Set min/max zoom
    self.maximumZoomScale = maxScale;
    self.minimumZoomScale = minScale;
    
    // Initial zoom
    self.zoomScale = [self initialZoomScaleWithMinScale];
    
    // If we're zooming to fill then centralise
    if (self.zoomScale != minScale) {
        // Centralise
        self.contentOffset = CGPointMake((imageSize.width * self.zoomScale - boundsSize.width) / 2.0,
                                         (imageSize.height * self.zoomScale - boundsSize.height) / 2.0);
        // Disable scrolling initially until the first pinch to fix issues with swiping on an initally zoomed in photo
        self.scrollEnabled = NO;
    }
    
    // Layout
    [self setNeedsLayout];
    
}

#pragma mark - Layout

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    // Center the image as it becomes smaller than the size of the screen
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = _zoomImageView.frame;
    
    // Horizontally
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = floorf((boundsSize.width - frameToCenter.size.width) / 2.0);
    } else {
        frameToCenter.origin.x = 0;
    }
    
    // Vertically
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

- (CGFloat)initialZoomScaleWithMinScale {
    CGFloat zoomScale = self.minimumZoomScale;
    if (_zoomImageView) {
        // Zoom image to fill if the aspect ratios are fairly similar
        CGSize boundsSize = self.bounds.size;
        CGSize imageSize = _zoomImageView.image.size;
        CGFloat boundsAR = boundsSize.width / boundsSize.height;
        CGFloat imageAR = imageSize.width / imageSize.height;
        CGFloat xScale = boundsSize.width / imageSize.width;    // the scale needed to perfectly fit the image width-wise
        CGFloat yScale = boundsSize.height / imageSize.height;  // the scale needed to perfectly fit the image height-wise
        // Zooms standard portrait images on a 3.5in screen but not on a 4in screen.
        if (ABS(boundsAR - imageAR) < 0.17) {
            zoomScale = MAX(xScale, yScale);
            // Ensure we don't zoom in or out too far, just in case
            zoomScale = MIN(MAX(self.minimumZoomScale, zoomScale), self.maximumZoomScale);
        }
    }
    return zoomScale;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
