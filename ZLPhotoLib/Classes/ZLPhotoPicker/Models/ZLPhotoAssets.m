//
//  ZLAssets.m
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 15-1-3.
//  Copyright (c) 2015年 com.zixue101.www. All rights reserved.
//

#import "ZLPhotoAssets.h"

static CGFloat saveOriginImageRadio = 0.0001;

@implementation ZLPhotoAssets

- (UIImage *)thumbImage{
    return [UIImage imageWithCGImage:[self.asset thumbnail]];
}

- (UIImage *)compressionImage{
    UIImage *fullScreenImage = [UIImage imageWithCGImage:[[self.asset defaultRepresentation] fullScreenImage]];
    NSData *data2 = UIImageJPEGRepresentation(fullScreenImage, 0.1);
    UIImage *image = [UIImage imageWithData:data2];
    fullScreenImage = nil;
    data2 = nil;
    return image;
}

- (UIImage *)originImage{
    return [UIImage imageWithCGImage:[[self.asset defaultRepresentation] fullScreenImage]];
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
