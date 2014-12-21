//
//  PickerCommon.h
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 14-11-19.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#ifndef ZLAssetsPickerDemo_PickerCommon_h
#define ZLAssetsPickerDemo_PickerCommon_h

// 点击销毁的block
typedef void(^ZLPickerBrowserViewControllerTapDisMissBlock)(NSInteger);

typedef NS_ENUM(NSUInteger, UIViewAnimationAnimationStatus) {
    UIViewAnimationAnimationStatusZoom = 0,
    UIViewAnimationAnimationStatusFade ,
    UIViewAnimationAnimationStatusRotate
};

#define iOS7gt ([[UIDevice currentDevice].systemVersion doubleValue] >= 7.0)

// ScrollView 滑动的间距
static CGFloat const ZLPickerColletionViewPadding = 20;

// ScrollView拉伸的比例
static CGFloat const ZLPickerScrollViewMaxZoomScale = 3.0;
static CGFloat const ZLPickerScrollViewMinZoomScale = 1.0;

// 进度条的宽度/高度
static NSInteger const ZLPickerProgressViewW = 50;
static NSInteger const ZLPickerProgressViewH = 50;

// 分页控制器的高度
static NSInteger const ZLPickerPageCtrlH = 25;

#endif
