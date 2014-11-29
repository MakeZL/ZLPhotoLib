//
//  ZLAnimationImageView.m
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 14-11-27.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import "ZLAnimationImageView.h"
#import "ZLPickerBrowserPhoto.h"
#import "UIView+Extension.h"
#import "UIImageView+WebCache.h"
#import "ZLPickerCommon.h"
#import <AssetsLibrary/AssetsLibrary.h>


@interface ZLAnimationImageView ()

//@property (nonatomic , strong) NSMutableArray *photos;
//@property (nonatomic , strong) NSDictionary *options;

@end

static NSArray *_photos;
static UIImageView *_imageView;
static NSDictionary *_options;

@implementation ZLAnimationImageView

+ (NSArray *)photos{
    if (!_photos) {
        _photos = [NSArray array];
    }
    return _photos;
}

+ (UIImageView *)imageView{
    if (!_imageView) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.clipsToBounds = YES;
        ZLAnimationBaseView *baseView = [ZLAnimationBaseView sharedManager];
        [baseView addSubview:imageView];
        _imageView = imageView;
    }
    return _imageView;
}

+ (instancetype)animationViewWithOptions:(NSDictionary *)options animations:(void (^)())animations completion:(void (^)(ZLAnimationBaseView *))completion{
    
    NSAssert([options[UIViewAnimationImages] isKindOfClass:[NSArray class]], @"只能传图片数组!");
    
    _photos = options[UIViewAnimationImages];
    if ([options[UIViewAnimationToView] width] == [options[UIViewAnimationToView] height]) {
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    }else{
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    NSMutableDictionary *ops = [NSMutableDictionary dictionaryWithDictionary:options];
    // 根据索引值来赋值
    NSIndexPath *indexPath = options[UIViewAnimationTypeViewWithIndexPath];
    // 设置图片
    [self setingPhotoImageAtIndex:indexPath.row];
    
    ops[UIViewAnimationSelfView] = [self imageView];
    _options = ops;
    return [super animationViewWithOptions:ops animations:animations completion:completion];
}

+ (void)restoreWithOptions:(NSDictionary *)options animation:(void (^)())completion{
    
    [self setingPhotoImageAtIndex:self.currentPage];

    [super restoreWithOptions:options animation:completion];
}

#pragma make - 设置图片
+ (void) setingPhotoImageAtIndex:(NSInteger)index{
    
    if (!_photos.count) {
        return ;
    }
    
    ZLPickerBrowserPhoto *photo = _photos[index];//[self photoWithAtIndex:self.currentPage];
    UIButton *cView = _options[UIViewAnimationToView];
    UIImage *image = nil;
    
    if (photo.photoImage) {
        image = photo.photoImage;
    }else if (photo.thumbImage){
        image = photo.thumbImage;
    }
    
    if (!image) {
        if ([cView isKindOfClass:[UIButton class]]) {
            image = cView.imageView.image;
        }else if ([cView isKindOfClass:[UIImageView class]]){
            UIImageView *ig = (UIImageView *)cView;
            image = ig.image;
        }
    }
    
    [[self imageView] setImage:image];
    
    
}


@end