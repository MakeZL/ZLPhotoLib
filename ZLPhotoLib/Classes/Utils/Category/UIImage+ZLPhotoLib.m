//
//  UIImage+ZLPhotoLib.m
//  MLCamera
//
//  Created by 张磊 on 15/4/25.
//  Copyright (c) 2015年 www.weibo.com/makezl All rights reserved.
//

#import "UIImage+ZLPhotoLib.h"

@implementation UIImage (ZLPhotoLib)
+ (instancetype)ml_imageFromBundleNamed:(NSString *)name{
    return [UIImage imageNamed:[@"ZLPhotoLib.bundle" stringByAppendingPathComponent:name]];
}
@end
