//
//  PickerPhotoScrollView.h
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 14-11-14.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZLPhotoPickerBrowserPhoto,ZLPhotoPickerBrowserPhotoScrollView;

@protocol ZLPhotoPickerPhotoScrollViewDelegate <NSObject>
@optional
// 单击调用
- (void) pickerPhotoScrollViewDidSingleClick:(ZLPhotoPickerBrowserPhotoScrollView *)photoScrollView;

@end

@interface ZLPhotoPickerBrowserPhotoScrollView : UIScrollView

// 传入模型来赋值
@property (nonatomic , strong) ZLPhotoPickerBrowserPhoto *photo;
// delegate
@property (nonatomic , weak) id <ZLPhotoPickerPhotoScrollViewDelegate> photoScrollViewDelegate;

// 取消单击事件
@property (assign,nonatomic) BOOL cancleSingleClick;

- (void)setMaxMinZoomScalesForCurrentBounds;

@end
