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
 
 UIViewAnimationInView 参照View
 UIViewAnimationSelfView 动画里面的View，用于继承它的View
 
 UIViewAnimationBackGroundColor 当前View的背景色
 UIViewAnimationMakeViewBackGroundColor 蒙版的背景色，默认白色
 
 UIViewAnimationTypeView 动画的View(什么View需要动画就传那个)
 UIViewAnimationTypeViewWithIndexPath 记录值
 
 */
// 开始坐标 default 0,0
static NSString *const UIViewAnimationStartFrame = @"UIViewAnimationStartFrame";
// 结束坐标 默认屏幕高宽度
static NSString *const UIViewAnimationEndFrame = @"UIViewAnimationEndFrame";
// 动画时间 default 0.5
static NSString *const UIViewAnimationDuration = @"UIViewAnimationDuration";
// 动画执行的模式
static NSString *const UIViewAnimationAnimationStatus = @"UIViewAnimationAnimationStatus";

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
// 计算坐标的方向
static NSString *const UIViewAnimationScrollDirection = @"UIViewAnimationTypeViewWithScrollDirection";

// 九宫格排练
static NSString *const UIViewAnimationSudokuMarginX = @"UIViewAnimationSudokuMarginX";
static NSString *const UIViewAnimationSudokuMarginY = @"UIViewAnimationSudokuMarginY";
static NSString *const UIViewAnimationSudokuDisplayCellNumber = @"UIViewAnimationSudokuDisplayCellNumber";

typedef void(^completion)();

@interface ZLBaseAnimationView : UIView {
@protected
    // 让继承者可以修改动画的结束跟开始位置
    NSValue *_startFrame;
    NSValue *_endFrame;
    NSInteger _photoCount;
}

/**
 *  初始化动画
 *
 *  @param options    参数
 *  @param completion 完成回调
 */
+ (instancetype) animationViewWithOptions:(NSDictionary *) options completion:(void (^)(ZLBaseAnimationView *baseView)) completion;

- (instancetype) initViewWithOptions:(NSDictionary *) options completion:(void (^)(ZLBaseAnimationView *baseView)) completion;

/**
 *  还原动画
 *
 *  @param completion 结束回调
 */
- (instancetype) viewformIdentity:(void(^)(ZLBaseAnimationView *baseView)) completion;


/**
 *  还原动画
 *
 *  @param completion 执行动画调用
 *  @param identity 结束回调
 */
- (instancetype) viewAnimateWithAnimations:(void(^)())animations identity:(void(^)(ZLBaseAnimationView *baseView)) completion;



@property (nonatomic , assign) NSInteger currentPage;

@end
