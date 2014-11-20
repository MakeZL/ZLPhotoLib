//
//  PickerPhotoScrollView.m
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 14-11-14.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import "PickerPhotoScrollView.h"
#import "UIView+Extension.h"
#import "PickerPhotoImageView.h"
#import "PickerPhoto.h"
#import "PickerPhotoGifView.h"
#import "PickerCommon.h"

@interface PickerPhotoScrollView () <UIScrollViewDelegate>
{
    PickerPhotoImageView *_zoomImageView;
}

@end

@implementation PickerPhotoScrollView

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
    self.contentSize = CGSizeMake(self.width, self.height);
    self.backgroundColor = [UIColor blackColor];
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.bouncesZoom = YES;
    self.contentSize = CGSizeMake(400, 400);
    self.decelerationRate = UIScrollViewDecelerationRateFast;
    self.delegate = self;
    
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
    
    if (self.zoomScale == self.maximumZoomScale) {
        [UIView animateWithDuration:.25 animations:^{
            // 还原需要算下中间的y值
            _zoomImageView.y = (self.height - _zoomImageView.height / self.maximumZoomScale) * 0.5;
            [self setZoomScale:self.minimumZoomScale animated:NO];
        }];
    }else{
        CGPoint touchPoint = [tap locationInView:tap.view];
        CGFloat newZoomScale = self.maximumZoomScale;
        CGFloat xsize = self.width / newZoomScale;
        CGFloat ysize = self.height / newZoomScale;
        
        [UIView animateWithDuration:.25 animations:^{
            // 如果图片的宽度大于高度，就算下y值
            if (_zoomImageView.image.size.width > _zoomImageView.image.size.height) {
                _zoomImageView.y = (self.height - _zoomImageView.height * self.maximumZoomScale) * 0.5;
            }
            [self zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:NO];
        }];
    }
}

- (void) disMissTap:(UITapGestureRecognizer *)tap{
    if ([self.photoScrollViewDelegate respondsToSelector:@selector(pickerPhotoScrollViewDidSingleClick:)]) {
        [self.photoScrollViewDelegate pickerPhotoScrollViewDidSingleClick:self];
    }
}

- (void)setPhoto:(PickerPhoto *)photo{
    _photo = photo;
    
    // 如果是gif图片
    if ([photo.photoURL.absoluteString hasSuffix:@"gif"]) {
        PickerPhotoGifView *gifView = [[PickerPhotoGifView alloc] init];
        gifView.frame = self.bounds;
        [gifView playGifWithURLString:photo.photoURL.absoluteString];
        [self addSubview:gifView];
    }else{
        if (!_zoomImageView) {
            _zoomImageView = [[PickerPhotoImageView alloc] init];
            [self addSubview:_zoomImageView];
        }
        _zoomImageView.photo = photo;
    }
    
    _zoomImageView.frame = (CGRect) {CGPointZero , _zoomImageView.image.size};
    self.contentSize = _zoomImageView.image.size;
    
    [self setMaxMinZoomScalesForCurrentBounds];
    
}

- (void)setMaxMinZoomScalesForCurrentBounds {
    
    // 重置
    self.maximumZoomScale = 1;
    self.minimumZoomScale = 1;
    self.zoomScale = 1;
    
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
    CGFloat maxScale = 3;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // Let them go a bit bigger on a bigger screen!
        maxScale = 4;
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
    
    // If we're zooming to fill then centralise
    if (zoomScale != minScale) {
        // Centralise
        self.contentOffset = CGPointMake((imageSize.width * zoomScale - boundsSize.width) / 2.0,
                                         (imageSize.height * zoomScale - boundsSize.height) / 2.0);
        // Disable scrolling initially until the first pinch to fix issues with swiping on an initally zoomed in photo
        self.scrollEnabled = NO;
    }
    
    // Layout
    [self setNeedsLayout];
    
}

#pragma mark - Layout
- (void)layoutSubviews {
    
    // Super
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
    
    // Center
    if (!CGRectEqualToRect(_zoomImageView.frame, frameToCenter))
        _zoomImageView.frame = frameToCenter;
    
}


#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _zoomImageView;
}


@end
