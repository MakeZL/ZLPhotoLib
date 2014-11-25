//
//  PickerPhoto.m
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 14-11-15.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import "ZLPickerBrowserPhoto.h"

@implementation ZLPickerBrowserPhoto

- (void)setPhotoObj:(id)photoObj{
    _photoObj = photoObj;
    
    if ([photoObj isKindOfClass:[ALAsset class]]) {
        ALAsset *asset = (ALAsset *)photoObj;
        self.asset = asset;
    }else if ([photoObj isKindOfClass:[NSURL class]]){
        self.photoURL = photoObj;
    }else if ([photoObj isKindOfClass:[UIImage class]]){
        self.photoImage = photoObj;
    }else if ([photoObj isKindOfClass:[NSString class]]){
        self.photoURL = [NSURL URLWithString:photoObj];
    }else{
        NSAssert(true == true, @"您传入的类型有问题");
    }
}

- (void)setAsset:(ALAsset *)asset{
    _asset = asset;
    
    // 自己去设置了封面图及详情图
    self.thumbImage = [UIImage imageWithCGImage:[asset thumbnail]];
    self.photoImage = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
}

@end
