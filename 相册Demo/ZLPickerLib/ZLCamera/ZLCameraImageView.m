//
//  BQImageView.m
//  BQCommunity
//
//  Created by TJQ on 14-8-5.
//  Copyright (c) 2014年 beiqing. All rights reserved.
//

#import "ZLCameraImageView.h"
#import "UIView+Extension.h"

@interface ZLCameraImageView ()

@property (assign, nonatomic) CGPoint point;

@property (strong, nonatomic) UIImageView *deleBjView;

@property (weak, nonatomic) UIView *mView;
/**
 *  记录所有的图片显示标记
 */
@property (strong, nonatomic) NSMutableArray *images;

@end

@implementation ZLCameraImageView


- (UIImageView *)deleBjView{
    if (!_deleBjView) {
        _deleBjView = [[UIImageView alloc] init];
        _deleBjView.image = [UIImage imageNamed:@"X"];
        _deleBjView.width = 25;
        _deleBjView.height = 25;
        _deleBjView.hidden = YES;
        _deleBjView.x = 50;
        _deleBjView.y = 0;
        _deleBjView.userInteractionEnabled = YES;
        [_deleBjView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleImage:)]];
        [self addSubview:_deleBjView];
    }
    return _deleBjView;
}

- (void)setEdit:(BOOL)edit{
    self.deleBjView.hidden = NO;
}

- (void)dealloc{
    [self.layer removeAllAnimations];
    
}


- (id)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = YES;
        [self addRecognizer];
    }
    return self;
}

- (void)addRecognizer
{
    UITapGestureRecognizer *gesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    self.contentMode = UIViewContentModeScaleAspectFit;
    [self addGestureRecognizer:gesture1];
}

#pragma mark 删除图片
- (void) deleImage : ( UITapGestureRecognizer *) tap{
    if ([self.delegatge respondsToSelector:@selector(deleteImageView:)]) {
        [self.delegatge deleteImageView:self];
    }
}

- (void)handleGesture:(UITapGestureRecognizer *)gesture
{
    // 防止多次点击
    self.userInteractionEnabled = NO;
    self.point = [gesture locationInView:self];
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.backgroundColor = [UIColor blackColor];
    if (self.originalImageView) {
        imageView.image = self.originalImageView;
    }
    else
    {
        imageView.image = self.image;
    }
    
    imageView.center = [self convertPoint:self.point fromView:self.superview];

    imageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *gesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture1:)];
    [imageView addGestureRecognizer:gesture1];
    [self.window addSubview:imageView];
    [UIView animateWithDuration:0.5 animations:^{
        imageView.frame = self.window.frame;
    } completion:^(BOOL finished) {
        self.userInteractionEnabled = YES;
    }];
}

- (void)handleGesture1:(UITapGestureRecognizer *)gesture
{
    UIView *view = gesture.view;
    [UIView animateWithDuration:0.5 animations:^{
        view.bounds = CGRectZero;
        CGPoint point = self.point;
        point.y = self.frame.origin.y + point.y;
        point.x = self.frame.origin.x + point.x;
        view.center = point;
        view.backgroundColor = [UIColor clearColor];
    } completion:^(BOOL finished) {
        [view removeFromSuperview];
    }];
}

- (void)drawRect:(CGRect)rect{
    
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)awakeFromNib {[self addRecognizer];}
@end
