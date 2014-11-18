//
//  BaseAnimationImageView.m
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 14-11-18.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import "BaseAnimationImageView.h"
#import "PickerPhoto.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface BaseAnimationImageView ()

@property (nonatomic , strong) NSMutableArray *photos;

@end

@implementation BaseAnimationImageView

- (NSMutableArray *)photos{
    if (!_photos) {
        _photos = [NSMutableArray array];
    }
    return _photos;
}

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
    _imageView.frame = [options[UIViewAnimationStartFrame] CGRectValue];
    return [super animationViewWithOptions:options completion:completion];
}

- (instancetype)initViewWithOptions:(NSDictionary *)options completion:(void (^)(BaseAnimationView *))completion{
    
    _photos = options[UIViewAnimationImages];
    NSAssert([_photos isKindOfClass:[NSArray class]], @"只能传图片数组!");
    
    NSIndexPath *indexPath = options[UIViewAnimationTypeViewWithIndexPath];
    PickerPhoto *photo = [self photoWithAtIndex:indexPath.row];
    [[self imageView] setImage:photo.photoImage];
    _imageView.frame = [options[UIViewAnimationStartFrame] CGRectValue];
    
    NSMutableDictionary *optionImgs = [NSMutableDictionary dictionaryWithDictionary:options];
    optionImgs[UIViewAnimationSelfView] = _imageView;
    
    return [super initViewWithOptions:optionImgs completion:completion];
}

#pragma mark -重写清空，赋值
- (instancetype)viewformIdentity:(void (^)(BaseAnimationView *))completion{
    PickerPhoto *photo = [self photoWithAtIndex:self.currentPage];
    [[self imageView] setImage:photo.photoImage];
    return [super viewformIdentity:completion];
}

// 取模型
- (PickerPhoto *) photoWithAtIndex:(NSInteger) index{
    id imageObj = [self.photos objectAtIndex:index];
    PickerPhoto *photo = [[PickerPhoto alloc] init];
    if ([imageObj isKindOfClass:[ALAsset class]]) {
        ALAsset *asset = (ALAsset *)imageObj;
        photo.thumbImage = [UIImage imageWithCGImage:[asset thumbnail]];
        photo.photoImage = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
    }else if ([imageObj isKindOfClass:[NSURL class]]){
        photo.photoURL = imageObj;
    }else if ([imageObj isKindOfClass:[UIImage class]]){
        photo.photoImage = imageObj;
    }
    
    return photo;
}
@end

