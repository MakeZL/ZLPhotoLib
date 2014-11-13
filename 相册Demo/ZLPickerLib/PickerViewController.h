//
//  PickerViewController.h
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 14-11-11.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import <UIKit/UIKit.h>
// 回调
typedef void(^callBackBlock)(id obj);

typedef enum {
    PickerViewShowStatusGroup = 0, // default groups .
    PickerViewShowStatusSavePhotos
} PickerViewShowStatus;

@protocol PickerViewControllerDelegate <NSObject>

/**
 *  返回所有的图片对象
 */
- (void) pickerViewControllerDonePictures : (NSArray *) images;

@end

@interface PickerViewController : UIViewController

@property (nonatomic , weak) id<PickerViewControllerDelegate> delegate;
// 决定你是否需要push到内容控制器, 默认显示组
@property (nonatomic , assign) PickerViewShowStatus status;
// 可以用代理来返回值或者用block来返回值
@property (nonatomic , copy) callBackBlock callBack;
// 每次选择图片的最大数, 默认是9
@property (nonatomic , assign) NSInteger maxCount;

@end
