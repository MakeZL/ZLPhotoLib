//
//  PickerPhotoScrollView.h
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 14-11-14.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZLPickerBrowserPhoto,ZLPickerBrowserPhotoScrollView;

@protocol PickerPhotoScrollViewDelegate <NSObject>
@optional
// 单击调用
- (void) pickerPhotoScrollViewDidSingleClick:(ZLPickerBrowserPhotoScrollView *)photoScrollView;

@end

@interface ZLPickerBrowserPhotoScrollView : UIScrollView

// 传入模型来赋值
@property (nonatomic , strong) ZLPickerBrowserPhoto *photo;
// delegate
@property (nonatomic , weak) id <PickerPhotoScrollViewDelegate> photoScrollViewDelegate;

@end
