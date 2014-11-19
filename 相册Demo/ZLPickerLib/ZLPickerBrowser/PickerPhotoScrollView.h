//
//  PickerPhotoScrollView.h
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 14-11-14.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PickerPhoto,PickerPhotoScrollView;

@protocol PickerPhotoScrollViewDelegate <NSObject>

@optional
// 单击调用
- (void) pickerPhotoScrollViewDidSingleClick:(PickerPhotoScrollView *)photoScrollView;

@end

@interface PickerPhotoScrollView : UIScrollView

@property (nonatomic , strong) PickerPhoto *photo;

@property (nonatomic , weak) id <PickerPhotoScrollViewDelegate> photoScrollViewDelegate;
@end
