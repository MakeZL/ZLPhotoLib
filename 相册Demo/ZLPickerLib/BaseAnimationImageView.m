//
//  BaseAnimationImageView.m
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 14-11-18.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import "BaseAnimationImageView.h"
#import "PickerPhoto.h"
#import "UIView+Extension.h"
#import "UIImageView+WebCache.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface BaseAnimationImageView ()

@property (nonatomic , strong) NSMutableArray *photos;
@property (nonatomic , strong) NSDictionary *options;

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
    return [super animationViewWithOptions:options completion:completion];
}

- (instancetype)initViewWithOptions:(NSDictionary *)options completion:(void (^)(BaseAnimationView *))completion{
    
    NSAssert([options[UIViewAnimationImages] isKindOfClass:[NSArray class]], @"只能传图片数组!");
    _photos = options[UIViewAnimationImages];
    
    self.options = options;
    NSMutableDictionary *ops = [NSMutableDictionary dictionaryWithDictionary:options];
    // 根据索引值来赋值
    NSIndexPath *indexPath = options[UIViewAnimationTypeViewWithIndexPath];
    PickerPhoto *photo = [self photoWithAtIndex:indexPath.row];
    UIButton *cView = self.options[UIViewAnimationTypeView];
    if (photo.photoImage) {
        [[self imageView] setImage:photo.photoImage];
    }else if (photo.thumbImage){
        [[self imageView] setImage:photo.thumbImage];
    }else if (cView.imageView.image){
        [[self imageView] setImage:cView.imageView.image];
    }else if (photo.photoURL){
        [[self imageView] sd_setImageWithURL:photo.photoURL placeholderImage:nil];
    }
    
    ops[UIViewAnimationSelfView] = self.imageView;
    
    return [super initViewWithOptions:ops completion:completion];
}

#pragma mark -重写清空，赋值
- (instancetype)viewformIdentity:(void (^)(BaseAnimationView *))completion{
    
    UIButton *cView = self.options[UIViewAnimationTypeView];
    PickerPhoto *photo = [self photoWithAtIndex:self.currentPage];
    if (photo.photoImage) {
        [[self imageView] setImage:photo.photoImage];
    }else if (photo.thumbImage){
        [[self imageView] setImage:photo.thumbImage];
    }else if (cView.imageView.image){
        [[self imageView] setImage:cView.imageView.image];
    }else if (photo.photoURL){
        [[self imageView] sd_setImageWithURL:photo.photoURL placeholderImage:nil];
    }
    
    CGRect imageFrame = CGRectZero;
    
    if ([cView isKindOfClass:[UITableViewCell class]]) {
        // 如果是tableViewCell的情况下
        UITableViewCell *cell = (UITableViewCell *)cView;
        CGRect cellF = CGRectMake(cell.imageView.x, cell.imageView.height * self.currentPage, cell.imageView.width, cell.imageView.height);
        
        imageFrame = [cell.superview convertRect:cellF toView: self.options[UIViewAnimationInView]];
    }else{
        // 如果是ScrollView的情况下
        CGFloat margin = CGRectGetMaxX(cView.frame) - (cView.tag + 1) * cView.width;
        CGFloat imageX = cView.frame.size.width * self.currentPage;
        imageFrame = [cView.superview convertRect:CGRectMake(imageX + margin, cView.bounds.origin.y, cView.frame.size.width, cView.bounds.size.height) toView: self.options[UIViewAnimationInView]];
    }
    
    _endFrame = [NSValue valueWithCGRect:imageFrame];
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

