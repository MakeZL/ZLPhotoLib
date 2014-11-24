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
 *  删除那个图片
 *
 *  @param index        要删除的索引值
 */
- (void)photoBrowser:(ZLPickerBrowserViewController *)photoBrowser removePhotoAtIndex:(NSUInteger)index;

@end

@interface ZLPickerBrowserViewController : UIViewController

// 数据源/代理
@property (nonatomic , weak) id<ZLPickerBrowserViewControllerDataSource> dataSource;
@property (nonatomic , weak) id<ZLPickerBrowserViewControllerDelegate> delegate;

// 点击的View
@property (nonatomic , strong) UIView *toView;
// 点击的View的根试图View(传self.view，坐位点击View的参照View)
@property (nonatomic , weak) UIView *fromView;

// 九宫格的间距
@property (nonatomic , assign) CGFloat sudokuMarginX;
@property (nonatomic , assign) CGFloat sudokuMarginY;
// 九宫格一行展示几个cell
@property (nonatomic , assign) NSInteger sudokuDisplayCellNumber;

// 决定你点击的View动画是从水平还是垂直，用于计算
@property (nonatomic , assign) ZLPickerBrowserScrollDirection scrollDirection;
// 是否可以编辑（删除照片）
@property (nonatomic , assign,getter=isEditing) BOOL editing;
// 当前提供的分页数
@property (nonatomic , assign) NSInteger currentPage;

/**
 *  刷新表格
 */
- (void) reloadData;

@end
