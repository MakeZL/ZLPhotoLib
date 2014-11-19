//
//  baseView.m
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 14-11-18.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import "BaseAnimationView.h"
#import "UIView+Extension.h"

@interface BaseAnimationView ()
// 当前的View
@property (nonatomic , strong) BaseAnimationView *baseView;
// 蒙版
@property (nonatomic , strong) UIView *maskView;
// 使导航栏隐藏
@property (nonatomic , strong) UINavigationController *navigaiton;
@property (nonatomic , strong) UIView *navigaitionView;
// 记录所有的参数
@property (nonatomic , strong) NSDictionary *options;
// 标志是否点击了销毁
@property (nonatomic , assign) BOOL isClickDisMiss;


@end

static BaseAnimationView *_singleBaseView;

@implementation BaseAnimationView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setupProperty];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        [self setupProperty];
    }
    return self;
}

- (void) setupProperty{
    self.contentMode = UIViewContentModeScaleAspectFit;
    self.clipsToBounds = YES;
}

+ (instancetype) animationViewWithOptions:(NSDictionary *) options completion:(void (^)(BaseAnimationView *baseView)) completion{
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
        UIView *cView = options[UIViewAnimationTypeView];
        if ([cView isKindOfClass:[UITableViewCell class]]) {
            UITableViewCell *cell = (UITableViewCell *)cView;
            startFrame = [cell convertRect:cell.imageView.frame toView:options[UIViewAnimationInView]];
        }else{
            startFrame = [cView convertRect:cView.bounds toView:options[UIViewAnimationInView]];
        }
        
        ops[UIViewAnimationStartFrame] = [NSValue valueWithCGRect:startFrame];
    }
    
    UIView *view = ops[UIViewAnimationInView];
    CGRect endFrame = [ops[UIViewAnimationEndFrame] CGRectValue];
    if (endFrame.size.width <= 0 || endFrame.size.height <= 0) {
        endFrame = view.bounds;
        ops[UIViewAnimationEndFrame] = [NSValue valueWithCGRect:endFrame];
    }
    
    return ops;
}


#pragma mark -初始化动画
- (instancetype) initViewWithOptions:(NSDictionary *) options completion:(void (^)(BaseAnimationView *baseView)) completion{
    
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
    
    if (!self.maskView) {
        self.maskView = [[UIView alloc] init];
        [view addSubview:self.maskView];
    }
    
    self.maskView.backgroundColor = self.options[UIViewAnimationMakeViewBackGroundColor];
    self.maskView.frame = view.frame;
    
    
    if (!selfView) {
        if (!_baseView) {
            _baseView =  [[[self class] alloc] init];
        }
    }else{
        _baseView = (BaseAnimationView *)selfView;
    }
    
    _baseView.hidden = NO;
    _baseView.frame = startFrame;
    
    _startFrame = self.options[UIViewAnimationEndFrame];
    _endFrame = self.options[UIViewAnimationStartFrame];
    
    if (![view.superview.subviews.lastObject isKindOfClass:[BaseAnimationView class]]) {
        _baseView.backgroundColor = bgColor;
        [view.superview addSubview:_baseView];
    }
    
    duration = duration ? duration : 0.5;
    
    self.isClickDisMiss = NO;
    [UIView animateWithDuration:duration animations:^{
        _baseView.frame = [self.options[UIViewAnimationEndFrame] CGRectValue];
        self.navigaiton.navigationBarHidden = YES;
        self.navigaitionView.hidden = YES;
    } completion:^(BOOL finished) {
        if (completion) {
            completion(self);
        }
        view.userInteractionEnabled = YES;
    }];
    
    return _baseView;
}

#pragma mark -清除动画
- (instancetype) viewformIdentity:(void(^)(BaseAnimationView *baseView)) completion{
    
    _baseView.frame = [_startFrame CGRectValue];
    self.isClickDisMiss = YES;
    
    [UIView animateWithDuration:0.5 animations:^{
        _baseView.frame = [_endFrame CGRectValue];
    } completion:^(BOOL finished) {
        if (completion) {
            completion(self);
        }
        
        self.navigaiton.navigationBarHidden = NO;
        self.navigaitionView.hidden = NO;
        [self.maskView removeFromSuperview];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // 让tableView能跟用户交互
            UITableView *tableView = self.options[UIViewAnimationTypeView];
            tableView.userInteractionEnabled = YES;
            _baseView.hidden = YES;
        });
    }];
    
    return  _baseView;
}

@end
