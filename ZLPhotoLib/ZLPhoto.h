//
//  ZLPicker.h
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 14-12-17.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#ifndef ZLAssetsPickerDemo_ZLPicker_h
#define ZLAssetsPickerDemo_ZLPicker_h

#import "ZLCameraViewController.h"
#import "ZLPhotoPickerBrowserViewController.h"
#import "ZLPhotoPickerAssetsViewController.h"
#import "ZLPhotoPickerViewController.h"
#import "ZLPhotoPickerDatas.h"
#import "ZLPhotoPickerCommon.h"
#import "UIImageView+WebCache.h"
#import "UIButton+WebCache.h"
#import "UIView+Extension.h"

/**
 *
 使用方法：
 有什么不懂的也可以联系QQ：120886865 (*^__^*) 嘻嘻……
 
 ZLCameraViewController:
 Note : (自定义相机多拍 + 图片相册多选)
 ZLCameraViewController *cameraVc = [[ZLCameraViewController alloc] init];
 // 打开相机 回调是ZLComplate block回调对象. 返回数组
 - (void)startCameraOrPhotoFileWithViewController:(UIViewController*)viewController complate : (ZLComplate ) complate;
 // 需要一个强引用的属性，引用它.
 self.cameraVc = cameraVc.
 
 ZLPhotoPickerViewController:
 Note : (图片相册多选控制器)
 创建控制器
 ZLPhotoPickerViewController *pickerVc = [[ZLPhotoPickerViewController alloc] init];
 // 默认显示相册里面的内容SavePhotos
 pickerVc.status = PickerViewShowStatusCameraRoll;
 // 选择图片的最小数，默认是9张图片
 pickerVc.minCount = 4;
 // 设置代理回调
 pickerVc.delegate = self;
 // 展示控制器
 [pickerVc show];
 
 第一种回调方法：- (void)pickerViewControllerDoneAsstes:(NSArray *)assets
 第二种回调方法pickerVc.callBack = ^(NSArray *assets){
 // TODO 回调结果，可以不用实现代理
 };
 
 ZLPhotoBrowserViewController:
 Note : (图片游览器)
 创建控制器
 ZLPhotoBrowserViewController *pickerBrowser = [[ZLPhotoBrowserViewController alloc] init];
 // 数据源/delegate
 pickerBrowser.delegate = self;
 pickerBrowser.dataSource = self;
 // 是否可以删除照片
 pickerBrowser.editing = YES;
 // 当前选中的值
 pickerBrowser.currentPage = indexPath.row;
 // 展示控制器
 [pickerBrowser show];
 
 数据源 ----- <ZLPhotoBrowserViewControllerDataSource>
 // 有多少个图片
 - (NSInteger) numberOfPhotosInPickerBrowser:(ZLPhotoBrowserViewController *) pickerBrowser;
 
 // 每个图片展示什么内容
 - (ZLPickerBrowserPhoto *)photoBrowser:(ZLPhotoBrowserViewController *)pickerBrowser photoAtIndex:(NSUInteger)index;
 
 
 代理 ----- <ZLPhotoBrowserViewControllerDelegate>
 
 // 准备删除那个图片的索引值
 - (BOOL)photoBrowser:(ZLPhotoBrowserViewController *)photoBrowser willRemovePhotoAtIndex:(NSUInteger)index;
 // 删除图片的索引值
 - (void)photoBrowser:(ZLPhotoBrowserViewController *)photoBrowser removePhotoAtIndex:(NSUInteger)index;
 // 滑动结束的页数
 - (void)photoBrowser:(ZLPhotoBrowserViewController *)photoBrowser didCurrentPage:(NSUInteger)page;
 //滑动开始的页数
 - (void)photoBrowser:(ZLPhotoBrowserViewController *)photoBrowser willCurrentPage:(NSUInteger)page;
 
 */

#endif
