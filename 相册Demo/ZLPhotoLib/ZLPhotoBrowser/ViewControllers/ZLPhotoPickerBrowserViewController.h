//
//  ZLPhotoPickerBrowserViewController.h
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 14-11-14.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZLPhotoPickerBrowserPhoto.h"
#import "ZLPhotoPickerCommon.h"
#import "ZLPhotoPickerCustomToolBarView.h"

@class ZLPhotoPickerBrowserViewController;


// ZLPhotoPickerBrowserViewControllerDataSource
@protocol ZLPhotoPickerBrowserViewControllerDataSource <NSObject>
/**
 *  有多少个图片
 */
- (NSInteger) numberOfPhotosInPickerBrowser:(ZLPhotoPickerBrowserViewController *) pickerBrowser;

/**
 *  每个图片展示什么内容
 */
- (ZLPhotoPickerBrowserPhoto *)photoBrowser:(ZLPhotoPickerBrowserViewController *)pickerBrowser photoAtIndex:(NSUInteger)index;

@end

// ZLPhotoPickerBrowserViewControllerDelegate
@protocol ZLPhotoPickerBrowserViewControllerDelegate <NSObject>
@optional

/**
 *  返回用户自定义的toolBarView(类似tableView FooterView)
 *
 *  @return 返回用户自定义的toolBarView
 */
- (ZLPhotoPickerCustomToolBarView *)photoBrowserShowToolBarViewWithphotoBrowser:(ZLPhotoPickerBrowserViewController *)photoBrowser;
/**
 *  准备删除那个图片
 *
 *  @param index        要删除的索引值
 */
- (BOOL)photoBrowser:(ZLPhotoPickerBrowserViewController *)photoBrowser willRemovePhotoAtIndex:(NSUInteger)index;
/**
 *  删除那个图片
 *
 *  @param index        要删除的索引值
 */
- (void)photoBrowser:(ZLPhotoPickerBrowserViewController *)photoBrowser removePhotoAtIndex:(NSUInteger)index;
/**
 *  滑动结束的页数
 *
 *  @param page         滑动的页数
 */
- (void)photoBrowser:(ZLPhotoPickerBrowserViewController *)photoBrowser didCurrentPage:(NSUInteger)page;
/**
 *  滑动开始的页数
 *
 *  @param page         滑动的页数
 */
- (void)photoBrowser:(ZLPhotoPickerBrowserViewController *)photoBrowser willCurrentPage:(NSUInteger)page;

@end

@interface ZLPhotoPickerBrowserViewController : UIViewController
// @require
// 数据源/代理
@property (nonatomic , weak) id<ZLPhotoPickerBrowserViewControllerDataSource> dataSource;
@property (nonatomic , weak) id<ZLPhotoPickerBrowserViewControllerDelegate> delegate;
// 点击的View
@property (nonatomic , strong) UIView *toView;
// 当前提供的分页数
@property (nonatomic , assign) NSInteger currentPage;

// @optional
// 是否可以编辑（删除照片）
@property (nonatomic , assign,getter=isEditing) BOOL editing;

// status
@property (assign,nonatomic) UIViewAnimationAnimationStatus status;
/**
 *  刷新表格
 */
- (void)reloadData;

/**
 *  展示控制器
 */
- (void)show;

@end
