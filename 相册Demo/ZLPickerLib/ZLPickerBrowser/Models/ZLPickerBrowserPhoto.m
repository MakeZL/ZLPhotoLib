//
//  PickerPhoto.m
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 14-11-15.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import "ZLPickerBrowserPhoto.h"

@implementation ZLPickerBrowserPhoto

- (void)setAsset:(ALAsset *)asset{
    _asset = asset;
    
    // 自己去设置了封面图及详情图
    self.thumbImage = [UIImage imageWithCGImage:[asset thumbnail]];
    self.photoImage = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
}

@end
