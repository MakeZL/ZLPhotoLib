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
@property (nonatomic , strong) UIImageView *imageView;

@end

@implementation BaseAnimationImageView

- (NSMutableArray *)photos{
    if (!_photos) {
        _photos = [NSMutableArray array];
    }
    return _photos;
}

//static UIImageView *_imageView;

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
    PickerPhoto *photo = self.photos[indexPath.row];//[self photoWithAtIndex:indexPath.row];
    
    UIButton *cView = self.options[UIViewAnimationToView];
    UIImage *image = nil;
    if (photo.photoImage) {
        image = photo.photoImage;
    }else if (photo.thumbImage){
        image = photo.thumbImage;
    }else if (cView.imageView.image){
        image = cView.imageView.image;
    }
    
    self.imageView.image = image;
    ops[UIViewAnimationSelfView] = self.imageView;
    
    return [super initViewWithOptions:ops completion:completion];
}

#pragma mark -重写清空，赋值
- (instancetype)viewformIdentity:(void (^)(BaseAnimationView *))completion{
    
    UIButton *cView = self.options[UIViewAnimationToView];
    PickerPhoto *photo = self.photos[self.currentPage];//[self photoWithAtIndex:self.currentPage];
    if (photo.photoImage) {
        [_imageView setImage:photo.photoImage];
    }else if (photo.thumbImage){
        [_imageView setImage:photo.thumbImage];
    }else if (cView.imageView.image){
        [_imageView setImage:cView.imageView.image];
    }else if (photo.photoURL){
        [_imageView sd_setImageWithURL:photo.photoURL placeholderImage:nil];
    }
    
    CGRect imageFrame = CGRectZero;
    // 通过分页数来确定类型，计算最终的Frame值
    if ([cView isKindOfClass:[UITableViewCell class]]) {
        // 如果是tableViewCell的情况下
        UITableViewCell *cell = (UITableViewCell *)cView;
        CGRect cellF = CGRectMake(cell.imageView.x, cell.imageView.height * self.currentPage, cell.imageView.width, cell.imageView.height);
        
        imageFrame = [cell.superview convertRect:cellF toView: self.options[UIViewAnimationFromView]];
    }else{
        // 如果是ScrollView的情况下
        CGFloat margin = CGRectGetMaxX(cView.frame) - (cView.tag + 1) * cView.width;
        CGFloat imageX = cView.frame.size.width * self.currentPage;
        imageFrame = [cView.superview convertRect:CGRectMake(imageX + margin, cView.bounds.origin.y, cView.frame.size.width, cView.bounds.size.height) toView: self.options[UIViewAnimationFromView]];
    }
    
    _endFrame = [NSValue valueWithCGRect:imageFrame];
    return [super viewformIdentity:completion];
}

@end

