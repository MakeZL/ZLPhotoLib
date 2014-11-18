//
//  BaseImageView.h
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 14-11-18.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import <UIKit/UIKit.h>

/** 动画参数配置 */
// 开始坐标
static NSString *const UIViewAnimationStartFrame = @"UIViewAnimationStartFrame";
// 结束坐标
static NSString *const UIViewAnimationEndFrame = @"UIViewAnimationEndFrame";
// 动画时间
static NSString *const UIViewAnimationDuration = @"UIViewAnimationDuration";

/** 系统参数配置 */
// 父View
static NSString *const UIViewAnimationInView = @"UIViewAnimationInView";
// 当前View（非外面传入）
static NSString *const UIViewAnimationSelfView = @"UIViewAnimationSelfView";
// 导航栏
static NSString *const UIViewAnimationNavigation = @"UIViewAnimationNavigation";
// 背景颜色
static NSString *const UIViewAnimationBackGroundColor = @"UIViewAnimationBackGroundColor";

/** 类型参数配置 */
// 类型的View(TableView、CollectionView、scrollView)
static NSString *const UIViewAnimationTypeView = @"UIViewAnimationTypeView";
// indexPath
static NSString *const UIViewAnimationTypeViewWithIndexPath = @"UIViewAnimationTypeViewWithIndexPath";
// 类型的宽度与高度
static NSString *const UIViewAnimationTypeViewWithWidth = @"UIViewAnimationTypeViewWithWidth";
static NSString *const UIViewAnimationTypeViewWithHeight = @"UIViewAnimationTypeViewWithHeight";




typedef void(^completion)();

@interface BaseAnimationView : UIView

/**
 *  初始化动画
 *
 *  @param options    参数
 *  @param completion 完成回调
 */
+ (instancetype) animationViewWithOptions:(NSDictionary *) options completion:(void (^)(BaseAnimationView *baseView)) completion;

- (instancetype) initViewWithOptions:(NSDictionary *) options completion:(void (^)(BaseAnimationView *baseView)) completion;

/**
 *  还原动画
 *
 *  @param completion 结束回调
 */
- (instancetype) viewformIdentity:(void(^)(BaseAnimationView *baseView)) completion;

@property (nonatomic , assign) NSInteger currentPage;

@end
