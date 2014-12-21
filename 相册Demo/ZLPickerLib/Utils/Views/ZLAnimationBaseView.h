//
//  ZLAnimationBaseView.h
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 14-11-27.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^complation)();

@class ZLAnimationBaseView;

// 开始坐标 default 0,0
static NSString *const UIViewAnimationStartFrame = @"UIViewAnimationStartFrame";
// 结束坐标 默认屏幕高宽度
static NSString *const UIViewAnimationEndFrame = @"UIViewAnimationEndFrame";
// 动画时间 default 0.5
static NSString *const UIViewAnimationDuration = @"UIViewAnimationDuration";

/** 系统参数配置 */
// 父View
static NSString *const UIViewAnimationInView = @"UIViewAnimationInView";
// 当前View（非外面传入, 用于继承）
static NSString *const UIViewAnimationSelfView = @"UIViewAnimationSelfView";
// 点击的View
static NSString *const UIViewAnimationToView = @"UIViewAnimationToView";
// 来自那个根视图点击的View
static NSString *const UIViewAnimationFromView = @"UIViewAnimationFromView";

/** 类型参数配置 */
// indexPath
static NSString *const UIViewAnimationTypeViewWithIndexPath = @"UIViewAnimationTypeViewWithIndexPath";
// 动画参数
static NSString *const UIViewAnimationAnimationStatusType = @"UIViewAnimationAnimationStatus";

static complation _completionBlock;

@interface ZLAnimationBaseView : UIView

+ (instancetype) sharedManager;

/**
 *  开始动画
 *
 *  @param animations 开始动画
 *  @param options    动画参数
 *  @param completion 结束动画
 */
+ (instancetype) animationViewWithOptions:(NSDictionary *)options animations:(void(^)())animations completion:(void (^)(ZLAnimationBaseView *baseView)) completion;

// 还原动画
+ (void) restoreAnimation:(void(^)()) completion;
+ (void) restoreWithOptions:(NSDictionary *)options animation:(void(^)()) completion;

// 遍历view的父节点是不是TableViewCell 或者 UICollectionCell
+ (UIView *)traversalViewWithCell:(UIView *)view;

// 当前是第几页
+ (void) setCurrentPage:(NSInteger)currentPage;
+ (NSInteger) currentPage;

// 准备开始动画前的操作
+ (void) willStartAnimationOperation;
// 准备结束动画
+ (void) willUnLoadAnimationOperation;
// 结束动画的操作
+ (void) unLoadStopAnimationOperation;

@end
