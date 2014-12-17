//
//  PickerBrowserViewController.h
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 14-11-14.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZLPickerBrowserPhoto.h"
#import "ZLPickerCommon.h"

@class ZLPickerBrowserViewController;


// ZLPickerBrowserViewControllerDataSource
@protocol ZLPickerBrowserViewControllerDataSource <NSObject>
/**
 *  有多少个图片
 */
- (NSInteger) numberOfPhotosInPickerBrowser:(ZLPickerBrowserViewController *) pickerBrowser;

/**
 *  每个图片展示什么内容
 */
- (ZLPickerBrowserPhoto *)photoBrowser:(ZLPickerBrowserViewController *)pickerBrowser photoAtIndex:(NSUInteger)index;

@end

// ZLPickerBrowserViewControllerDelegate
@protocol ZLPickerBrowserViewControllerDelegate <NSObject>
@optional

/**
 *  准备删除那个图片
 *
 *  @param index        要删除的索引值
 */
- (BOOL)photoBrowser:(ZLPickerBrowserViewController *)photoBrowser willRemovePhotoAtIndex:(NSUInteger)index;
/**
 *  删除那个图片
 *
 *  @param index        要删除的索引值
 */
- (void)photoBrowser:(ZLPickerBrowserViewController *)photoBrowser removePhotoAtIndex:(NSUInteger)index;
/**
 *  滑动结束的页数
 *
 *  @param page         滑动的页数
 */
- (void)photoBrowser:(ZLPickerBrowserViewController *)photoBrowser didCurrentPage:(NSUInteger)page;
/**
 *  滑动开始的页数
 *
 *  @param page         滑动的页数
 */
- (void)photoBrowser:(ZLPickerBrowserViewController *)photoBrowser willCurrentPage:(NSUInteger)page;

@end

@interface ZLPickerBrowserViewController : UIViewController
// @require
// 数据源/代理
@property (nonatomic , weak) id<ZLPickerBrowserViewControllerDataSource> dataSource;
@property (nonatomic , weak) id<ZLPickerBrowserViewControllerDelegate> delegate;
// 点击的View
@property (nonatomic , strong) UIView *toView;
// 当前提供的分页数
@property (nonatomic , assign) NSInteger currentPage;

// @optional
// 是否可以编辑（删除照片）
@property (nonatomic , assign,getter=isEditing) BOOL editing;

/**
 *  刷新表格
 */
- (void)reloadData;

/**
 *  展示控制器
 */
- (void)show;

@end
