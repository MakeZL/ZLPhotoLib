//
//  BaseAnimationImageView.m
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 14-11-18.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import "BaseAnimationImageView.h"

@interface BaseAnimationImageView ()

//@property (nonatomic , weak) UIImageView *imageView;

@end

@implementation BaseAnimationImageView

static UIImageView *_imageView;

- (UIImageView *)imageView{
    if (!_imageView) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.clipsToBounds = YES;
        [self addSubview:imageView];
        _imageView = imageView;
    }
    return _imageView;
}

+ (instancetype) animationViewWithOptions:(NSDictionary *) options completion:(void (^)(BaseAnimationView *baseView)) completion{
    
    _imageView.image = options[UIViewAnimationImage];
    _imageView.frame = [options[UIViewAnimationStartFrame] CGRectValue];
    return [super animationViewWithOptions:options completion:completion];
}

- (instancetype)initViewWithOptions:(NSDictionary *)options completion:(void (^)(BaseAnimationView *))completion{
    [[self imageView] setImage:options[UIViewAnimationImage]];
    _imageView.frame = [options[UIViewAnimationStartFrame] CGRectValue];
    
    NSMutableDictionary *optionImgs = [NSMutableDictionary dictionaryWithDictionary:options];
    optionImgs[UIViewAnimationSelfView] = _imageView;
    
    return [super initViewWithOptions:optionImgs completion:completion];
}
@end
