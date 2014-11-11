//
//  PickerDatas.h
//  相册Demo
//
//  Created by 张磊 on 14-11-11.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import <UIKit/UIKit.h>

// 回调
typedef void(^callBackBlock)(id obj);

@interface PickerDatas : NSObject

/**
 *  快速初始化对象
 */
+ (instancetype) defaultPicker;

/**
 * 获取所有的图片
 */
- (void) getAllPhotos : (callBackBlock ) callBack;

/**
 * 获取所有的图片的URL
 */
- (void) getAllPhotosURLs : (callBackBlock ) callBack;

/**
 * 获取所有组对应的图片
 */
- (void) getAllGroupWithPhotos : (callBackBlock ) callBack;


@end
