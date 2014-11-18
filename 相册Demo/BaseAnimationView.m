//
//  BaseImageView.m
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 14-11-18.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import "BaseAnimationView.h"
#import "UIView+Animation.h"

@interface BaseAnimationView ()

@property (nonatomic , strong) BaseAnimationView *baseImageView;
@property (nonatomic , strong) UIView *maskView;
@property (nonatomic , strong) UINavigationController *navigaiton;

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
        NSIndexPath *indexPath = options[UIViewAnimationTypeViewWithIndexPath];
        UITableViewCell *cell= [tableView cellForRowAtIndexPath:indexPath];
        tempFrame = cell.imageView.frame;
        tempFrame.origin.y -= ( tableView.contentOffset.y - tableView.frame.origin.y) - indexPath.row * cell.frame.size.height;
        tempFrame.origin.x += tableView.frame.origin.x;
        
    }else if ([typeView isKindOfClass:[UICollectionView class]]){
        
    }else if ([typeView isKindOfClass:[UIScrollView class]]){
        
    }
    
    
    NSMutableDictionary *ops = [NSMutableDictionary dictionaryWithDictionary:options];
    ops[UIViewAnimationStartFrame] = [NSValue valueWithCGRect:tempFrame];

    return ops;
}


#pragma mark -初始化动画
- (instancetype) initViewWithOptions:(NSDictionary *) options completion:(void (^)(BaseAnimationView *baseView)) completion{
    
    
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
    
//    self.baseImageView.frame
    CGRect endFrame = [_endFrame CGRectValue];
//    (endFrame.size.height * self.currentPage) % (self.maskView)
    
    NSLog(@"%d",self.currentPage);
    
    // 1.  (item.size.width * self.currentPage) % (view原来的宽度 - view.orgin.x)
    
    NSValue *val = _startFrame;
    _startFrame = _endFrame;
    _endFrame = val;
    
    [UIView animateWithDuration:0.5 animations:^{
        self.baseImageView.frame = [_startFrame CGRectValue];
    } completion:^(BOOL finished) {
        if (completion) {
            completion(self);
        }
        
        [self.maskView removeFromSuperview];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.baseImageView.hidden = YES;
            self.navigaiton.navigationBarHidden = NO;
        });
    }];
    
    return  self.baseImageView;
}

@end
