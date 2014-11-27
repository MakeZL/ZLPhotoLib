//
//  PickerImageView.h
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 14-11-15.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

typedef void(^downLoadWebImageCallBlock)();
#import <UIKit/UIKit.h>

@protocol ZLPickerBrowserPhotoImageViewDelegate <NSObject>

@optional
/**
 *  告诉代理下载的进度
 *
 *  @param progess 进度
 */
- (void) pickerBrowserPhotoImageViewDownloadProgress:(CGFloat)progress;

@end


@class ZLPickerBrowserPhoto;

@interface ZLPickerBrowserPhotoImageView : UIImageView

@property (nonatomic , strong) ZLPickerBrowserPhoto *photo;
// 下载完回调
@property (nonatomic , copy) downLoadWebImageCallBlock downLoadWebImageCallBlock;
@property (nonatomic , strong) UIScrollView *scrollView;
@property (nonatomic , weak) id <ZLPickerBrowserPhotoImageViewDelegate> delegate;

// 设置进度值
- (void) setProgress:(CGFloat) progress;

@end
