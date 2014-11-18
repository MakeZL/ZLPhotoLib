//
//  BaseImageView.m
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 14-11-18.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import "BaseAnimationView.h"
#import "UIView+Extension.h"

@interface BaseAnimationView ()
// 当前的View
@property (nonatomic , strong) BaseAnimationView *baseImageView;
// 蒙版
@property (nonatomic , strong) UIView *maskView;
// 使导航栏隐藏
@property (nonatomic , strong) UINavigationController *navigaiton;
// 记录所有的参数
@property (nonatomic , strong) NSDictionary *options;
// 标志是否点击了销毁
@property (nonatomic , assign) BOOL isClickDisMiss;

@end

static NSValue *_startFrame;
static NSValue *_endFrame;
static BaseAnimationView *_baseView;

@implementation BaseAnimationView

- (UIView *)maskView{
    if (!_maskView) {
        UIView *maskView = [[UIView alloc] init];
        maskView.backgroundColor = [UIColor blackColor];
        self.maskView = maskView;
    }
    return _maskView;
}

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
         _baseView = [[self alloc] init];
    });
    return _baseView;
}

- (NSDictionary *) getTypeViewWithOptions:(NSDictionary *)options{
    
    UIView *typeView = options[UIViewAnimationTypeView];
    
    CGRect tempFrame = CGRectZero;
    if ([typeView isKindOfClass:[UITableView class]]) {
        // tableView就按TableView的方式
        UITableView *tableView = options[UIViewAnimationTypeView];
        tableView.userInteractionEnabled = NO;
        NSIndexPath *indexPath = self.isClickDisMiss ? [NSIndexPath indexPathForRow:self.currentPage inSection:0] : options[UIViewAnimationTypeViewWithIndexPath];
        
        UITableViewCell *cell= [tableView cellForRowAtIndexPath:indexPath];
        tempFrame = cell.imageView.frame;
        tempFrame.origin.y -= ( tableView.contentOffset.y - tableView.frame.origin.y) - indexPath.row * cell.frame.size.height;
        tempFrame.origin.x += tableView.frame.origin.x;
        
    }else if ([typeView isKindOfClass:[UICollectionView class]]){
        
    }else if ([typeView isKindOfClass:[UIScrollView class]]){
        
    }
    
    NSMutableDictionary *ops = nil;
    if (self.isClickDisMiss) {
        _endFrame = [NSValue valueWithCGRect:tempFrame];
        self.isClickDisMiss = NO;
    }else{
        
        ops = [NSMutableDictionary dictionaryWithDictionary:options];
        ops[UIViewAnimationStartFrame] = [NSValue valueWithCGRect:tempFrame];
    }
    
    return ops;
}


#pragma mark -初始化动画
- (instancetype) initViewWithOptions:(NSDictionary *) options completion:(void (^)(BaseAnimationView *baseView)) completion{
    
    self.options = options;
    
    NSDictionary *ops = [self getTypeViewWithOptions:options];
    
    CGRect startFrame = [ops[UIViewAnimationStartFrame] CGRectValue];
    CGRect endFrame = [ops[UIViewAnimationEndFrame] CGRectValue];
    CGFloat duration = [ops[UIViewAnimationDuration] floatValue];
    UIView *view = ops[UIViewAnimationInView];
    UIColor *bgColor = ops[UIViewAnimationBackGroundColor];
    UIView *selfView = ops[UIViewAnimationSelfView];
    self.navigaiton = ops[UIViewAnimationNavigation];
    
    view.userInteractionEnabled = NO;
    [view addSubview:self.maskView];
    self.maskView.frame = view.frame;
    
    if (!selfView) {
        if (!self.baseImageView) {
            self.baseImageView =  [[[self class] alloc] init];
        }
    }else{
        self.baseImageView = (BaseAnimationView *)selfView;
    }
    
    self.baseImageView.hidden = NO;
    self.baseImageView.frame = startFrame;
    
    _startFrame = ops[UIViewAnimationEndFrame];
    _endFrame = ops[UIViewAnimationStartFrame];
    
    if (![view.superview.subviews.lastObject isKindOfClass:[BaseAnimationView class]]) {
        self.baseImageView.backgroundColor = bgColor;
        [view.superview addSubview:self.baseImageView];
    }
    
    duration = duration ? duration : 0.5;
    
    self.isClickDisMiss = NO;
    [UIView animateWithDuration:duration animations:^{
        self.baseImageView.frame = endFrame;
        self.navigaiton.navigationBarHidden = YES;
    } completion:^(BOOL finished) {
        if (completion) {
            completion(self);
        }
        view.userInteractionEnabled = YES;
    }];
    
    return self.baseImageView;
}

#pragma mark -清除动画
- (instancetype) viewformIdentity:(void(^)(BaseAnimationView *baseView)) completion{
    
    self.baseImageView.frame = [_startFrame CGRectValue];
    self.isClickDisMiss = YES;
    
    [self getTypeViewWithOptions:self.options];
    // 如果超过了显示的分页数 。 就默认跳到最后一条+50像素
    if ([self.options[UIViewAnimationTypeView] isKindOfClass:[UITableView class]]) {
        UITableView *tableView = self.options[UIViewAnimationTypeView];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if( cell.height * self.currentPage  >= tableView.height ){
            CGRect tempEndFrame = [_endFrame CGRectValue];
            tempEndFrame.origin.y = tableView.height + tableView.y;
            _endFrame = [NSValue valueWithCGRect:tempEndFrame];
        }
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        self.baseImageView.frame = [_endFrame CGRectValue];
    } completion:^(BOOL finished) {
        if (completion) {
            completion(self);
        }
        
        [self.maskView removeFromSuperview];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // 让tableView能跟用户交互
            UITableView *tableView = self.options[UIViewAnimationTypeView];
            tableView.userInteractionEnabled = YES;
            self.baseImageView.hidden = YES;
            self.navigaiton.navigationBarHidden = NO;
        });
    }];
    
    return  self.baseImageView;
}

@end
