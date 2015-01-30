//
//  ZoomingScrollView.h
//  MWPhotoBrowser
//
//  Created by Michael Waterfall on 14/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ZLPhotoPickerBrowserPhotoImageView.h"
#import "ZLPhotoPickerBrowserPhotoView.h"
#import "ZLPhotoPickerBrowserPhoto.h"

@class ZLPhotoPickerBrowserPhotoScrollView;

@protocol ZLPhotoPickerPhotoScrollViewDelegate <NSObject>
@optional
// 单击调用
- (void) pickerPhotoScrollViewDidSingleClick:(ZLPhotoPickerBrowserPhotoScrollView *)photoScrollView;

@end

@interface ZLPhotoPickerBrowserPhotoScrollView : UIScrollView <UIScrollViewDelegate, ZLPhotoPickerBrowserPhotoImageViewDelegate,ZLPhotoPickerBrowserPhotoViewDelegate> {

}

@property () NSUInteger index;
@property (nonatomic) ZLPhotoPickerBrowserPhoto *photo;

@property (nonatomic , weak) id <ZLPhotoPickerPhotoScrollViewDelegate> photoScrollViewDelegate;

- (void)displayImage;
- (void)setMaxMinZoomScalesForCurrentBounds;

@end
