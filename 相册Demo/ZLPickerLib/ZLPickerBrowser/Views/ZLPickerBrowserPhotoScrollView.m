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

@interface ZLPickerBrowserPhotoScrollView () <UIScrollViewDelegate>

@property (nonatomic , weak) UIImageView *zoomImageView;

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
    // Zoom
    
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

- (void) disMissTap:(UITapGestureRecognizer *)tap{
    if ([self.photoScrollViewDelegate respondsToSelector:@selector(pickerPhotoScrollViewDidSingleClick:)]) {
        [self.photoScrollViewDelegate pickerPhotoScrollViewDidSingleClick:self];
    }
}

- (void)setPhoto:(ZLPickerBrowserPhoto *)photo{
    _photo = photo;
    
    
    [[self.subviews lastObject] removeFromSuperview];
    
    if ([photo.photoURL.absoluteString hasSuffix:@"gif"]) {
        ZLPickerBrowserPhotoGifView *gifView = [[ZLPickerBrowserPhotoGifView alloc] init];
        gifView.frame = self.bounds;
        [gifView playGifWithURLString:photo.photoURL.absoluteString];
        [self addSubview:gifView];
    }else{
        ZLPickerBrowserPhotoImageView *zoomImageView = [[ZLPickerBrowserPhotoImageView alloc] init];
        zoomImageView.photo = photo;
        zoomImageView.downLoadWebImageCallBlock = ^{
            [self setMaxMinZoomScalesForCurrentBounds];
        };
        self.zoomImageView = zoomImageView;
        [self addSubview:zoomImageView];
    }
    
    _zoomImageView.frame = (CGRect) {CGPointZero , _zoomImageView.image.size};
    
    [self setMaxMinZoomScalesForCurrentBounds];
    
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


#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _zoomImageView;
}


- (void)setMaxMinZoomScalesForCurrentBounds {
    
    // Bail
    if (_zoomImageView.image == nil) return;
    
    // Sizes
    CGSize boundsSize = self.bounds.size;
    CGSize imageSize = _zoomImageView.frame.size;
    
    // Calculate Min
    CGFloat xScale = boundsSize.width / imageSize.width;    // the scale needed to perfectly fit the image width-wise
    CGFloat yScale = boundsSize.height / imageSize.height;  // the scale needed to perfectly fit the image height-wise
    CGFloat minScale = MIN(xScale, yScale);                 // use minimum of these to allow the image to become fully visible
    
    // Calculate Max
    CGFloat maxScale = 2.0;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // Let them go a bit bigger on a bigger screen!
        maxScale = 3.0;
    }
    
    // Image is smaller than screen so no zooming!
    if (xScale >= 1 && yScale >= 1) {
        minScale = 1.0;
    }
    
    // Initial zoom
    CGFloat zoomScale = minScale;
    
    self.maximumZoomScale = maxScale;
    self.minimumZoomScale = minScale;
    self.zoomScale = zoomScale;
    
    // Reset position
    _zoomImageView.frame = CGRectMake(0, 0, _zoomImageView.frame.size.width, _zoomImageView.frame.size.height);
    // Initial zoom
    
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


- (void)layoutSubviews {
    
    // Super
    [super layoutSubviews];
    
    if (!( (NSInteger)_zoomImageView.width > self.width)) {
        self.contentSize = CGSizeMake(self.width, 0);
    }
    
//     Center the image as it becomes smaller than the size of the screen
    
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
    
    // Center
    if (!CGRectEqualToRect(_zoomImageView.frame, frameToCenter))
        _zoomImageView.frame = frameToCenter;
}


@end
