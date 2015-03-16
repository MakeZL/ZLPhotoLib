//
//  ZLAnimationBaseView.m
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 14-11-27.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import "ZLAnimationBaseView.h"
#import "ZLPhotoPickerCommon.h"
#import "UIView+Extension.h"

@implementation ZLAnimationBaseView
// 当前的View
static ZLAnimationBaseView *_baseView = nil;
// 参数
static NSDictionary *_options = nil;
static NSInteger _currentPage = 0;
static NSIndexPath *_currentIndexPath = nil;
static NSMutableDictionary *_attachParams = nil;

// 单例
static ZLAnimationBaseView *_singleBaseView;

+ (instancetype) sharedManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _singleBaseView = [[self alloc] init];
        _attachParams = [NSMutableDictionary dictionary];
    });
    
    
    return _singleBaseView;
}

// 补充空的字典
+ (NSDictionary *) supplementOptionsEmptyParamWithDict:(NSDictionary *)options{
    
    NSMutableDictionary *ops = [NSMutableDictionary dictionaryWithDictionary:options];
    
    // 开始的View/开始View的根View
    UIView *toView = options[UIViewAnimationToView];
    UIView *fromView = options[UIViewAnimationFromView];
    
    // 如果没有起始位置
    CGRect startFrame = [options[UIViewAnimationStartFrame] CGRectValue];
    if (!startFrame.size.width || !startFrame.size.height) {
        startFrame = [self initStartFrameToView:toView fromView:fromView];
        ops[UIViewAnimationStartFrame] = [NSValue valueWithCGRect:startFrame];
    }
    
    // 如果没有结束位置
    CGRect endFrame = [options[UIViewAnimationEndFrame] CGRectValue];
    if (!endFrame.size.width || !endFrame.size.height) {
        endFrame = [self initEndFrameFromView:fromView];
        ops[UIViewAnimationEndFrame] = [NSValue valueWithCGRect:endFrame];
    }
    
    // 如果没有动画时间
    if (![ops[UIViewAnimationDuration] floatValue]) {
        ops[UIViewAnimationDuration] = [NSNumber numberWithFloat:.35];
    }
    
    return ops;
}

#pragma mark -
#pragma mark 补充开始的位置
+ (CGRect)initStartFrameToView:(UIView *)toView fromView:(UIView *)fromView{
    CGRect startFrame = CGRectZero;
    if ([toView isKindOfClass:[UITableViewCell class]]) {
        UITableViewCell *cell = (UITableViewCell *)toView;
        startFrame = [cell convertRect:cell.imageView.frame toView:fromView];
    }else{
        startFrame = [toView convertRect:toView.bounds toView:fromView];
    }
    
    // 如果是iOS7以下StartFrame需要y值需要加64
    if (!iOS7gt) startFrame.origin.y += 64;
    
    return startFrame;
}

#pragma mark 补充结束的位置
+ (CGRect)initEndFrameFromView:(UIView *)fromView{
    
    return fromView.bounds;
}

#pragma mark - 开始动画
+ (instancetype) animationViewWithOptions:(NSDictionary *)options animations:(void(^)())animations completion:(void (^)(ZLAnimationBaseView *baseView)) completion{
    
    // 准备动画前的一些操作
    [self willStartAnimationOperation];
    // 补充没填的参数
    NSMutableDictionary *ops = [NSMutableDictionary dictionaryWithDictionary:[self supplementOptionsEmptyParamWithDict:options]];
    
    [ops addEntriesFromDictionary:_attachParams];
    
    
    _options = [NSMutableDictionary dictionaryWithDictionary:ops];
    
    // 起始位置、结束位置、动画时间
    CGRect  startFrame   =                 [_options[UIViewAnimationStartFrame] CGRectValue];
    CGFloat duration     =                 [_options[UIViewAnimationDuration] floatValue];
    ZLAnimationBaseView *selfView    =      _options[UIViewAnimationSelfView];
    UIView *inView       =                  _options[UIViewAnimationInView];
    
    // 如果已经有子类继承并且修改了selfView, 就用子类的
    if (selfView) {
        _baseView = selfView;
    }else{
        if (!([_options[UIViewAnimationToView] isKindOfClass:[UIImageView class]])) {
            _baseView = _options[UIViewAnimationToView];
        }else{
            _baseView = [self sharedManager];
        }
    }
    
    // 初始化baseView的参数
    _baseView.hidden = NO;
    _baseView.frame = startFrame;
    
    if ([_options[UIViewAnimationAnimationStatusType] integerValue] == UIViewAnimationAnimationStatusFade) {
        // 淡入淡出
        _baseView.alpha = 0.0;
        _baseView.frame = [self setMaxMinZoomScalesForCurrentBounds];
    }else{
        // 缩放/旋转
        _baseView.alpha = 1.0;
        _baseView.frame = startFrame;
    }
    
    // 避免重复添加View
    if (![inView.subviews.lastObject isKindOfClass:[ZLAnimationBaseView class]]) {
        [inView addSubview:_baseView];
    }
    
    __weak typeof(_baseView) weakBaseView = _baseView;
    __weak typeof(self) weakSelf = self;
    
    // 隐藏状态栏
    if ([UIDevice currentDevice].systemVersion.floatValue >= 7.0){
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    }
    
    // 开始动画
    [UIView animateWithDuration:duration animations:^{
        if (animations) {
            animations();
        }
        if ([ops[UIViewAnimationAnimationStatusType] integerValue] == UIViewAnimationAnimationStatusFade) {
            // 淡入淡出
            weakBaseView.alpha = 1.0;
        }else{
            // 缩放/旋转
            weakBaseView.frame = [weakSelf setMaxMinZoomScalesForCurrentBounds];
        }
        if (!iOS7gt) {
            // 在iOS6因为隐藏了状态栏。所以需要加上20的高度
//            weakBaseView.y += 20;
        }
    } completion:^(BOOL finished) {
        if (completion) {
            completion(nil);
        }
        [weakBaseView removeFromSuperview];
    }];
    
    return nil;
}

+ (void) restoreAnimation:(void(^)()) completion{
    [self restoreWithOptions:_options animation:completion];
}

#pragma mark - 遍历view的父节点是不是TableViewCell 或者 UICollectionCell
+ (UIView *)traversalViewWithCell:(UIView *)view{
    if ([view isKindOfClass:[UITableViewCell class]] || [view isKindOfClass:[UICollectionViewCell class]] || view == nil) {
        return view;
    }
    return [self traversalViewWithCell:view.superview];
}

+ (void) restoreWithOptions:(NSDictionary *)options animation:(void (^)())completion{
    
    // 即将消失调用
    [self willUnLoadAnimationOperation];
    
    // 补充没填的参数
    //    _options = [self supplementOptionsEmptyParamWithDict:options];
    
    NSMutableDictionary *ops = [NSMutableDictionary dictionaryWithDictionary:[self supplementOptionsEmptyParamWithDict:options]];
    [ops addEntriesFromDictionary:_attachParams];
    
    if ([[self currentIndexPath] item] > KPhotoShowMaxCount) {
        ops[UIViewAnimationAnimationStatusType] = @(UIViewAnimationAnimationStatusFade);
    }
    
    _options = [NSMutableDictionary dictionaryWithDictionary:ops];
    
    CGRect endFrame      =  [_options[UIViewAnimationEndFrame] CGRectValue];;
    CGFloat duration     =                 [_options[UIViewAnimationDuration] floatValue];
    
    // 把_baseView添加到Window上
    UIWindow *myWindow = [[[UIApplication sharedApplication] windows] firstObject];
    UIView *view = myWindow.subviews.lastObject;
    if (!([view isKindOfClass:[ZLAnimationBaseView class]]) &&
        (![view isKindOfClass:[UIImageView class]]))
    {
        [myWindow addSubview:_baseView];
    }
    
//    if ([UIDevice currentDevice].systemVersion.floatValue < 7.0){
//        _baseView.frame = [_options[UIViewAnimationInView] frame];
//    }else{
        _baseView.frame = [self setMaxMinZoomScalesForCurrentBounds];
//    }
    
    UIViewAnimationAnimationStatus status = [_options[UIViewAnimationAnimationStatusType] intValue];
    
    __weak typeof(self) weakSelf = self;
    __weak UIView *weakBaseView = _baseView;
    
    
    [UIView animateWithDuration:duration animations:^{
        if (status == UIViewAnimationAnimationStatusRotate) {
            weakBaseView.transform = CGAffineTransformMakeScale(0.7, 0.7);
            weakBaseView.transform = CGAffineTransformRotate(_baseView.transform, M_PI_4);
            weakBaseView.alpha = 0;
        }else if(status == UIViewAnimationAnimationStatusFade){
            weakBaseView.alpha = 0.0;
        }else{
            weakBaseView.frame = endFrame;
        }
        myWindow.userInteractionEnabled = NO;
    } completion:^(BOOL finished) {
        if (completion) {
            completion();
        }
        [weakBaseView removeFromSuperview];
        [weakSelf unLoadStopAnimationOperation];
        if (status == UIViewAnimationAnimationStatusRotate || status == UIViewAnimationAnimationStatusFade) {
            weakBaseView.transform = CGAffineTransformIdentity;
            weakBaseView.alpha = 1;
        }
    }];
}

#pragma mark -
#pragma mark 准备开始动画前的操作
+ (void) willStartAnimationOperation{
//    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    //    [_options[UIViewAnimationFromView] setUserInteractionEnabled:NO];
}


// 计算Frame根据屏幕的尺寸拉伸或缩小
+ (CGRect )setMaxMinZoomScalesForCurrentBounds {
    
    UIImageView *imageView = (UIImageView *) _baseView;
    if (!([imageView isKindOfClass:[UIImageView class]]) || imageView.image == nil) {
        if (!([imageView isKindOfClass:[UIImageView class]])) {
            return [_options[UIViewAnimationInView] frame];
        }else{
            return CGRectZero;
        }
    }
    
    // Sizes
    CGSize boundsSize = [UIScreen mainScreen].bounds.size;
    CGSize imageSize = imageView.image.size;
    if (imageSize.width == 0 && imageSize.height == 0) {
        return [_options[UIViewAnimationInView] frame];
    }
    
    CGFloat xScale = boundsSize.width / imageSize.width;    // the scale needed to perfectly fit the image width-wise
    CGFloat yScale = boundsSize.height / imageSize.height;  // the scale needed to perfectly fit the image height-wise
    CGFloat minScale = MIN(xScale, yScale);                 // use minimum of these to allow the image to become fully visible
    // Image is smaller than screen so no zooming!
    if (xScale >= 1 && yScale >= 1) {
        minScale = MIN(xScale, yScale);
    }
    
    CGRect frameToCenter = CGRectMake(0, 0, imageSize.width * minScale, imageSize.height * minScale);
    
    // Horizontally
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = floorf((boundsSize.width - frameToCenter.size.width) / 2.0);
    } else {
        frameToCenter.origin.x = 0;
    }
    
    // Vertically
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = floorf((boundsSize.height - frameToCenter.size.height) / 2.0);
    } else {
        frameToCenter.origin.y = 0;
    }
    
    return frameToCenter;
}

+ (void)setterParamsWithOrientation:(UIDevice *)device{
    if(device.orientation == UIDeviceOrientationLandscapeLeft || device.orientation == UIDeviceOrientationLandscapeRight){
        _attachParams[UIViewAnimationAnimationStatusType] = @(UIViewAnimationAnimationStatusRotate);
    }else{
        _attachParams[UIViewAnimationAnimationStatusType] = @(UIViewAnimationAnimationStatusZoom);
    }
}

#pragma mark -
#pragma mark 开始动画
+ (void) willUnLoadAnimationOperation{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [UIApplication sharedApplication].keyWindow.userInteractionEnabled = NO;
}
#pragma mark 结束动画的操作
+ (void) unLoadStopAnimationOperation{
    [_options[UIViewAnimationFromView] setUserInteractionEnabled:YES];
    [UIApplication sharedApplication].keyWindow.userInteractionEnabled = YES;
}


#pragma mark -
#pragma mark 设置分页/获取分页
+ (void) setCurrentPage:(NSInteger)currentPage{
    _currentPage = currentPage;
}
+ (NSInteger) currentPage{
    return _currentPage;
}

+ (void)setCurrentIndexPath:(NSIndexPath *)indexPath{
    _currentIndexPath = indexPath;
}

+ (NSIndexPath *)currentIndexPath{
    return _currentIndexPath;
}

#pragma mark - 生命周期
- (void)dealloc{
    _attachParams = nil;
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [_options[UIViewAnimationFromView] setUserInteractionEnabled:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
