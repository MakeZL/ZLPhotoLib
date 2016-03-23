//
//  ZLAssets.m
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 15-1-3.
//  Copyright (c) 2015年 com.zixue101.www. All rights reserved.
//

#import "ZLPhotoAssets.h"

@interface ZLPhotoAssets ()
@property (nonatomic, assign) BOOL isUIImage;
@end

@implementation ZLPhotoAssets

+ (instancetype)assetWithImage:(UIImage *)image{
    ZLPhotoAssets *asset = [[ZLPhotoAssets alloc] init];
    asset.isUIImage = YES;
    asset.thumbImage = image;
    asset.originImage = image;
    asset.aspectRatioImage = image;
    return asset;
}

- (UIImage *)aspectRatioImage{
    return self.isUIImage ? _aspectRatioImage : [UIImage imageWithCGImage:[self.asset aspectRatioThumbnail]];
}

- (UIImage *)thumbImage{
    return self.isUIImage ? _thumbImage : [UIImage imageWithCGImage:[self.asset thumbnail]];
}

- (UIImage *)originImage{
    return self.isUIImage ? _originImage : [UIImage imageWithCGImage:[[self.asset defaultRepresentation] fullScreenImage]];
}

- (BOOL)isVideoType{
    NSString *type = [self.asset valueForProperty:ALAssetPropertyType];
    //媒体类型是视频
    return [type isEqualToString:ALAssetTypeVideo];
}

- (NSURL *)assetURL{
    return [[self.asset defaultRepresentation] url];
}

@end
