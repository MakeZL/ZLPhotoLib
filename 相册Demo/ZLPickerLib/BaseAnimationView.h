//
//  BaseImageView.h
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 14-11-18.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//  基本动画

#import <UIKit/UIKit.h>

/**  
 *   动画参数配置
     UIViewAnimationStartFrame 开始位置，默认 {0,0,0,0}
     UIViewAnimationEndFrame 结束位置
     UIViewAnimationDuration 默认 0.5
     UIViewAnimationBackGroundColor 默认default
 
     UIViewAnimationInView 参照View
     UIViewAnimationSelfView 动画里面的View，用于继承它的View
 
     UIViewAnimationNavigation 隐藏导航栏
     UIViewAnimationNavigationView
 
     UIViewAnimationBackGroundColor 当前View的背景色
     UIViewAnimationMakeViewBackGroundColor 蒙版的背景色，默认白色
 
     UIViewAnimationTypeView 动画的View(什么View需要动画就传那个)
     UIViewAnimationTypeViewWithIndexPath 记录值
 
     还没开始记录
     UIViewAnimationTypeViewWithWidth | UIViewAnimationTypeViewWithHeight
 */
// 开始坐标 default 0,0
static NSString *const UIViewAnimationStartFrame = @"UIViewAnimationStartFrame";
// 结束坐标
static NSString *const UIViewAnimationEndFrame = @"UIViewAnimationEndFrame";
// 动画时间 default 0.5
static NSString *const UIViewAnimationDuration = @"UIViewAnimationDuration";

/** 系统参数配置 */
// 父View
static NSString *const UIViewAnimationInView = @"UIViewAnimationInView";
// 当前View（非外面传入）
static NSString *const UIViewAnimationSelfView = @"UIViewAnimationSelfView";
// 导航栏
static NSString *const UIViewAnimationNavigation = @"UIViewAnimationNavigation";
// 自定义导航View
static NSString *const UIViewAnimationNavigationView = @"UIViewAnimationNavigationView";
// 背景颜色
static NSString *const UIViewAnimationBackGroundColor = @"UIViewAnimationBackGroundColor";
// 蒙版层颜色
static NSString *const UIViewAnimationMakeViewBackGroundColor = @"UIViewAnimationMakeViewBackGroundColor";

/** 类型参数配置 */
// 类型的View(TableView、CollectionView、scrollView)
static NSString *const UIViewAnimationTypeView = @"UIViewAnimationTypeView";
// indexPath
static NSString *const UIViewAnimationTypeViewWithIndexPath = @"UIViewAnimationTypeViewWithIndexPath";
// 类型的宽度与高度
static NSString *const UIViewAnimationTypeViewWithWidth = @"UIViewAnimationTypeViewWithWidth";
static NSString *const UIViewAnimationTypeViewWithHeight = @"UIViewAnimationTypeViewWithHeight";




typedef void(^completion)();

@interface BaseAnimationView : UIView {
@protected
    // 让继承者可以修改动画的结束跟开始位置
    NSValue *_startFrame;
    NSValue *_endFrame;
}

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
