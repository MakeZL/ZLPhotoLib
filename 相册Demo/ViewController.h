//
//  ViewController.h
//  相册Demo
//
//  Created by 张磊 on 14-11-11.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

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
 
 ZLPickerViewController:
 Note : (图片相册多选控制器)
 创建控制器
 ZLPickerViewController *pickerVc = [[ZLPickerViewController alloc] init];
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
 
 ZLPickerBrowserViewController:
 Note : (图片游览器)
 创建控制器
 ZLPickerBrowserViewController *pickerBrowser = [[ZLPickerBrowserViewController alloc] init];
 // 数据源/delegate
 pickerBrowser.delegate = self;
 pickerBrowser.dataSource = self;
 // 是否可以删除照片
 pickerBrowser.editing = YES;
 // 当前选中的值
 pickerBrowser.currentIndexPath = indexPath;
 pickerBrowser.currentPage = indexPath.row;
 // 展示控制器
 [pickerBrowser show];
 
 数据源 ----- <ZLPickerBrowserViewControllerDataSource>
    有多少组
    - (NSInteger) numberOfSectionInPhotosInPickerBrowser:(ZLPhotoPickerBrowserViewController *) pickerBrowser;
    每个组多少个图片
    - (NSInteger) photoBrowser:(ZLPhotoPickerBrowserViewController *)photoBrowser numberOfItemsInSection:(NSUInteger)section;
    每个对应的IndexPath展示什么内容
    - (ZLPhotoPickerBrowserPhoto *)photoBrowser:(ZLPhotoPickerBrowserViewController *)pickerBrowser photoAtIndexPath:(NSIndexPath *)indexPath;

 
 代理 ----- <ZLPickerBrowserViewControllerDelegate>
    返回用户自定义的toolBarView(类似tableView FooterView)
    - (ZLPhotoPickerCustomToolBarView *)photoBrowserShowToolBarViewWithphotoBrowser:(ZLPhotoPickerBrowserViewController *)photoBrowser;
    准备删除那个图片
    - (BOOL)photoBrowser:(ZLPhotoPickerBrowserViewController *)photoBrowser willRemovePhotoAtIndexPath:(NSIndexPath *)indexPath;
    删除indexPath对应索引的图片
    - (void)photoBrowser:(ZLPhotoPickerBrowserViewController *)photoBrowser removePhotoAtIndexPath:(NSIndexPath *)indexPath;
    滑动结束的页数
    - (void)photoBrowser:(ZLPhotoPickerBrowserViewController *)photoBrowser didCurrentPage:(NSUInteger)page;
    滑动开始的页数
    - (void)photoBrowser:(ZLPhotoPickerBrowserViewController *)photoBrowser willCurrentPage:(NSUInteger)page;
 
 */

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController


@end

