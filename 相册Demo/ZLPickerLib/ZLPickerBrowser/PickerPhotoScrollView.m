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
    self.maximumZoomScale = maxZoomScale;
    // 设置最小伸缩比例
    self.minimumZoomScale = minZoomScale;
    
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
    
}
#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _zoomImageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView{

        // 如果图片的宽度大于高度，就算下y值
        if (_zoomImageView.image.size.width > _zoomImageView.image.size.height) {
            _zoomImageView.y = (self.height - _zoomImageView.height) * 0.5;
        }

}


@end
