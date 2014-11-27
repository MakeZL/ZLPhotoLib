//
//  BaseAnimationImageView.h
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 14-11-18.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//  图片动画

#import "ZLBaseAnimationView.h"

// 传图片数组
static NSString *const UIViewAnimationImages = @"UIViewAnimationImages";
// 图片的缩小时候的模式
static NSString *const UIViewAnimationZoomMinScaleImageViewContentModel = @"UIViewAnimationZoomMinScaleImageViewContentModel";

@interface ZLBaseAnimationImageView : ZLBaseAnimationView
@property (nonatomic , strong) UIImageView *imageView;
@end
