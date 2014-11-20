//
//  PickerBrowserViewController.h
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 14-11-14.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZLPickerBrowserPhoto.h"

typedef void(^tapDisMissBlock)(NSInteger);

@class ZLPickerBrowserViewController;

@protocol ZLPickerBrowserViewControllerDataSource <NSObject>

/**
 *  有多少个图片
 */
- (NSInteger) numberOfPhotosInPickerBrowser:(ZLPickerBrowserViewController *) pickerBrowser;

- (ZLPickerBrowserPhoto *)photoBrowser:(ZLPickerBrowserViewController *)pickerBrowser photoAtIndex:(NSUInteger)index;

@end

@protocol ZLPickerBrowserViewControllerDelegate <NSObject>

@optional
- (void)photoBrowser:(ZLPickerBrowserViewController *)photoBrowser removePhotoAtIndex:(NSUInteger)index;

@end

@interface ZLPickerBrowserViewController : UIViewController

@property (nonatomic , weak) id<ZLPickerBrowserViewControllerDataSource> dataSource;

@property (nonatomic , weak) id<ZLPickerBrowserViewControllerDelegate> delegate;

@property (nonatomic , strong) UIView *toView;
@property (nonatomic , weak) UIView *fromView;

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
