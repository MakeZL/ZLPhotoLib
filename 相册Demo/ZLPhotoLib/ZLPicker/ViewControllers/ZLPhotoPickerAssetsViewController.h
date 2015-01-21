//
//  ZLPhotoPickerAssetsViewController.h
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 14-11-12.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//


// 回调
typedef void(^callBackBlock)(id obj);

#import <UIKit/UIKit.h>
#import "ZLPhotoPickerCommon.h"

@class ZLPhotoPickerGroup;

@interface ZLPhotoPickerAssetsViewController : UIViewController

@property (nonatomic , strong) ZLPhotoPickerGroup *assetsGroup;
@property (nonatomic , assign) NSInteger minCount;


@end
