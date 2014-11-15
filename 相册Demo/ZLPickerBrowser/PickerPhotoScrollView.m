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

@interface PickerPhotoScrollView () <UIScrollViewDelegate>

@property (nonatomic , weak) PickerPhotoImageView *zoomImageView;

@end

@implementation PickerPhotoScrollView

#pragma mark -getter
- (PickerPhotoImageView *)zoomImageView{
    if (!_zoomImageView) {
        PickerPhotoImageView *zoomImageView = [[PickerPhotoImageView alloc] init];
        [self addSubview:zoomImageView];
        self.zoomImageView = zoomImageView;
    }
    return _zoomImageView;
}

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
    self.bouncesZoom = YES;
    self.decelerationRate = UIScrollViewDecelerationRateFast;
    self.delegate = self;
    self.clipsToBounds = YES;
    // 设置最大伸缩比例
    self.maximumZoomScale = 2.5;
    // 设置最小伸缩比例
    self.minimumZoomScale = 1.0;
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
        self.zoomImageView.frame = CGRectMake(10, 0, self.width - 20, self.height);
        self.zoomImageView.photo = photo;
    }
}


#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.zoomImageView;
}


@end
