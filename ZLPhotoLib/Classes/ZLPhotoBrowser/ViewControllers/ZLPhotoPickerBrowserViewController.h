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
#import "ZLPhotoPickerBrowserPhotoScrollView.h"

@class ZLPhotoPickerBrowserViewController;
@protocol ZLPhotoPickerBrowserViewControllerDataSource <NSObject>

@optional
/**
 *  有多少组
 */
- (NSInteger) numberOfSectionInPhotosInPickerBrowser:(ZLPhotoPickerBrowserViewController *) pickerBrowser;

@required
/**
 *  每个组多少个图片
 */
- (NSInteger) photoBrowser:(ZLPhotoPickerBrowserViewController *)photoBrowser numberOfItemsInSection:(NSUInteger)section;
/**
 *  每个对应的IndexPath展示什么内容
 */
- (ZLPhotoPickerBrowserPhoto *)photoBrowser:(ZLPhotoPickerBrowserViewController *)pickerBrowser photoAtIndexPath:(NSIndexPath *)indexPath;


@end

@protocol ZLPhotoPickerBrowserViewControllerDelegate <NSObject>
@optional

/**
 *  点击每个Item时候调用
 */
- (void)photoBrowser:(ZLPhotoPickerBrowserViewController *)pickerBrowser photoDidSelectView:(UIView *)scrollBoxView atIndexPath:(NSIndexPath *)indexPath;

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
- (BOOL)photoBrowser:(ZLPhotoPickerBrowserViewController *)photoBrowser willRemovePhotoAtIndexPath:(NSIndexPath *)indexPath;
/**
 *  删除indexPath对应索引的图片
 *
 *  @param indexPath        要删除的索引值
 */
- (void)photoBrowser:(ZLPhotoPickerBrowserViewController *)photoBrowser removePhotoAtIndexPath:(NSIndexPath *)indexPath;
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

// 展示的图片数组<ZLPhotoPickerBrowserPhoto> == [self.dataSource photoBrowser:photoAtIndexPath:]
@property (strong,nonatomic) NSArray *photos;
// 当前提供的组
@property (strong,nonatomic) NSIndexPath *currentIndexPath;

// @optional
// 是否可以编辑（删除照片）
@property (nonatomic , assign,getter=isEditing) BOOL editing;
// 动画status (放大缩小/淡入淡出/旋转)
@property (assign,nonatomic) UIViewAnimationAnimationStatus status;
// 长按保存图片会调用sheet
@property (strong,nonatomic) UIActionSheet *sheet;

// 放大缩小一张图片的情况下（查看头像）
- (void)showHeadPortrait:(UIImageView *)toImageView;
// 放大缩小一张图片的情况下（查看头像）/ 缩略图是toImageView.image 原图URL
- (void)showHeadPortrait:(UIImageView *)toImageView originUrl:(NSString *)originUrl;

// @function
// 展示控制器
- (void)showPickerVc:(UIViewController *)vc;
- (void)showPushPickerVc:(UIViewController *)vc;
// 刷新数据
- (void)reloadData;

// Category Functions.
- (UIView *)getParsentView:(UIView *)view;
- (id)getParsentViewController:(UIView *)view;

@end
