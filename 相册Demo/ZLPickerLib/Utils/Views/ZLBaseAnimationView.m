//
//  baseView.m
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 14-11-18.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import "ZLBaseAnimationView.h"
#import "UIView+Extension.h"

@interface ZLBaseAnimationView ()
// 当前的View
@property (nonatomic , strong) ZLBaseAnimationView *baseView;
// 蒙版
@property (nonatomic , strong) UIView *maskView;
// 使导航栏隐藏
@property (nonatomic , strong) UINavigationController *navigaiton;
@property (nonatomic , strong) UIView *navigaitionView;
// 记录所有的参数
@property (nonatomic , strong) NSDictionary *options;


@end

static ZLBaseAnimationView *_singleBaseView;

@implementation ZLBaseAnimationView

+ (instancetype) animationViewWithOptions:(NSDictionary *) options completion:(void (^)(ZLBaseAnimationView *baseView)) completion{
    return [[self animationView] initViewWithOptions:options completion:completion];
}

+ (instancetype) animationView{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _singleBaseView = [[self alloc] init];
    });
    return _singleBaseView;
}

- (NSDictionary *) getTypeViewWithOptions:(NSDictionary *)options{
    
    NSMutableDictionary *ops = [NSMutableDictionary dictionaryWithDictionary:options];
    CGRect startFrame = [options[UIViewAnimationStartFrame] CGRectValue];
    if (!startFrame.size.width || !startFrame.size.height) {
        UIView *cView = options[UIViewAnimationToView];
        if ([cView isKindOfClass:[UITableViewCell class]]) {
            UITableViewCell *cell = (UITableViewCell *)cView;
            startFrame = [cell convertRect:cell.imageView.frame toView:options[UIViewAnimationFromView]];
        }else{
            startFrame = [cView convertRect:cView.bounds toView:options[UIViewAnimationFromView]];
        }
        
        ops[UIViewAnimationStartFrame] = [NSValue valueWithCGRect:startFrame];
    }
    
    // 计算EndFrame是否为空
    UIView *view = ops[UIViewAnimationInView];
    CGRect endFrame = [ops[UIViewAnimationEndFrame] CGRectValue];
    if (endFrame.size.width <= 0 || endFrame.size.height <= 0) {
        endFrame = view.bounds;
        ops[UIViewAnimationEndFrame] = [NSValue valueWithCGRect:endFrame];
    }
    
    // 计算Duration是否为空
    if (![ops[UIViewAnimationDuration] floatValue]) {
        ops[UIViewAnimationDuration] = [NSNumber numberWithFloat:0.5];
    }
    
    return ops;
}


#pragma mark -初始化动画
- (instancetype) initViewWithOptions:(NSDictionary *) options completion:(void (^)(ZLBaseAnimationView *baseView)) completion{
    
    // 计算开始坐标
    self.options = [self getTypeViewWithOptions:options];

    // 获取参数
    CGRect startFrame = [self.options[UIViewAnimationStartFrame] CGRectValue];
    CGFloat duration = [self.options[UIViewAnimationDuration] floatValue];
    UIColor *bgColor = self.options[UIViewAnimationBackGroundColor];
    UIView *selfView = self.options[UIViewAnimationSelfView];
    UIView *view = self.options[UIViewAnimationInView];

    // 起始位置、结束位置、动画时间、图片参数
    self.navigaiton = self.options[UIViewAnimationNavigation];
    self.navigaitionView = self.options[UIViewAnimationNavigationView];
    
    view.userInteractionEnabled = NO;
    view.hidden = NO;
    
    if (!selfView) {
        if (!_baseView) {
            _baseView =  [[[self class] alloc] init];
        }
    }else{
        _baseView = (ZLBaseAnimationView *)selfView;
    }
    
    _baseView.hidden = NO;
    _baseView.frame = startFrame;
    
    _startFrame = self.options[UIViewAnimationEndFrame];
    _endFrame = self.options[UIViewAnimationStartFrame];
    
    if (![view.subviews.lastObject isKindOfClass:[ZLBaseAnimationView class]]) {
        if (bgColor) {
            _baseView.backgroundColor = bgColor;
        }
        [view addSubview:_baseView];
    }
    
    [UIView animateWithDuration:duration animations:^{
        _baseView.frame = [self.options[UIViewAnimationEndFrame] CGRectValue];
        self.navigaiton.navigationBarHidden = YES;
        self.navigaitionView.hidden = YES;
    } completion:^(BOOL finished) {
        [_baseView removeFromSuperview];
        if (completion) {
            completion(self);
        }
        
        view.userInteractionEnabled = YES;
    }];
    
    return _baseView;
}

#pragma mark -结束动画，支持动画block
- (instancetype) viewAnimateWithAnimations:(void(^)())animations identity:(void(^)(ZLBaseAnimationView *baseView)) completion{
    // 让最外面的View不能跟用户进行交互
    [self.options[UIViewAnimationFromView] setUserInteractionEnabled:NO];
    _baseView.hidden = NO;
    // 把_baseView添加到Window上
    UIWindow *myWindow = [[[UIApplication sharedApplication] windows] lastObject];
    UIView *view = myWindow.subviews.lastObject;
    myWindow.userInteractionEnabled = NO;
    if (!([view isKindOfClass:[ZLBaseAnimationView class]]) &&
        (![view isKindOfClass:[UIImageView class]]))
    {
        [myWindow addSubview:_baseView];
    }
    
    _baseView.frame = [self.options[UIViewAnimationEndFrame] CGRectValue];

    [UIView animateWithDuration:.5 animations:^{
        if (animations) {
            animations();
        }else{
            _baseView.frame = [_endFrame CGRectValue];//[self.options[UIViewAnimationStartFrame] CGRectValue];
        }
    } completion:^(BOOL finished) {
        if (completion) {
            completion(self);
        }
        
        _baseView.hidden = YES;
        self.navigaiton.navigationBarHidden = NO;
        self.navigaitionView.hidden = NO;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // 让最外面的View能跟用户进行交互
            [self.options[UIViewAnimationFromView] setUserInteractionEnabled:YES];
        });
    }];
    
    return  _baseView;
}

#pragma mark -结束动画
- (instancetype) viewformIdentity:(void(^)(ZLBaseAnimationView *baseView)) completion{
   return [self viewAnimateWithAnimations:nil identity:completion];
}

@end
