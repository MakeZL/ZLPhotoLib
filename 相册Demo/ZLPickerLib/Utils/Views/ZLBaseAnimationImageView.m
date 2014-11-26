//
//  BaseAnimationImageView.m
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 14-11-18.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import "ZLBaseAnimationImageView.h"
#import "ZLPickerBrowserPhoto.h"
#import "UIView+Extension.h"
#import "UIImageView+WebCache.h"
#import "ZLPickerCommon.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface ZLBaseAnimationImageView ()

@property (nonatomic , strong) NSMutableArray *photos;
@property (nonatomic , strong) NSDictionary *options;

@end

@implementation ZLBaseAnimationImageView

- (NSMutableArray *)photos{
    if (!_photos) {
        _photos = [NSMutableArray array];
    }
    return _photos;
}

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

- (instancetype)initViewWithOptions:(NSDictionary *)options completion:(void (^)(ZLBaseAnimationView *))completion{
    
    NSAssert([options[UIViewAnimationImages] isKindOfClass:[NSArray class]], @"只能传图片数组!");
    _photos = options[UIViewAnimationImages];
    
    self.options = options;
    NSMutableDictionary *ops = [NSMutableDictionary dictionaryWithDictionary:options];
    // 根据索引值来赋值
    NSIndexPath *indexPath = options[UIViewAnimationTypeViewWithIndexPath];
    // 设置图片
    [self setingPhotoImageAtIndex:indexPath.row];
    
    ops[UIViewAnimationSelfView] = self.imageView;
    
    return [super initViewWithOptions:ops completion:completion];
}

#pragma mark -重写清空，赋值
- (instancetype)viewformIdentity:(void (^)(ZLBaseAnimationView *))completion{
    
    // 设置图片
    [self setingPhotoImageAtIndex:self.currentPage];
    return [super viewformIdentity:completion];
}

#pragma make - 设置图片
- (void) setingPhotoImageAtIndex:(NSInteger)index{
    
    ZLPickerBrowserPhoto *photo = self.photos[index];//[self photoWithAtIndex:self.currentPage];
    UIButton *cView = self.options[UIViewAnimationToView];
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
    
    self.imageView.image = image;
}

@end

