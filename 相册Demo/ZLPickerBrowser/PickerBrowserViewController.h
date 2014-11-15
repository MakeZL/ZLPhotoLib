//
//  PickerBrowserViewController.h
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 14-11-14.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PickerPhoto.h"

@class PickerBrowserViewController;

@protocol PickerBrowserViewControllerDataSource <NSObject>

/**
 *  有多少个图片
 */
- (NSInteger) numberOfPhotosInPickerBrowser:(PickerBrowserViewController *) pickerBrowser;

- (PickerPhoto *)photoBrowser:(PickerBrowserViewController *)pickerBrowser photoAtIndex:(NSUInteger)index;

@end

@protocol PickerBrowserViewControllerDelegate <NSObject>

@optional
- (void)photoBrowser:(PickerBrowserViewController *)photoBrowser removePhotoAtIndex:(NSUInteger)index;

@end

@interface PickerBrowserViewController : UIViewController

@property (nonatomic , weak) id<PickerBrowserViewControllerDataSource> dataSource;

@property (nonatomic , weak) id<PickerBrowserViewControllerDelegate> delegate;

/**
 *  是否可以编辑（删除照片）
 */
@property (nonatomic , assign,getter=isEditing) BOOL editing;
/**
 *  当前提供的分页数
 */
@property (nonatomic , assign) NSInteger currentPage;

- (void) reloadData;

@end
