//
//  PickerAssetsViewController.h
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 14-11-12.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//


#define iOS7 ([[UIDevice currentDevice].systemVersion doubleValue] >= 7.0)

// 回调
typedef void(^callBackBlock)(id obj);

#import <UIKit/UIKit.h>

@class ZLPickerGroup;

@interface ZLPickerAssetsViewController : UIViewController

@property (nonatomic , strong) ZLPickerGroup *assetsGroup;
@property (nonatomic , assign) NSInteger maxCount;


@end
