//
//  baseView.m
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 14-11-18.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import "ZLBaseAnimationView.h"
#import "ZLPickerCommon.h"
#import "UIView+Extension.h"
#import "ZLPickerCommon.h"
#import "ZLBaseAnimationImageView.h"

@interface ZLBaseAnimationView ()
// 当前的View
@property (nonatomic , strong) ZLBaseAnimationView *baseView;
// 蒙版
@property (nonatomic , strong) UIView *maskView;
// 记录所有的参数
@property (nonatomic , strong) NSDictionary *options;
// 记录ToView的父View
@property (nonatomic , strong) UIView *parsentView;
// 上一个分页数
@property (nonatomic , assign) NSInteger lastCurrentPage;

@end

static ZLBaseAnimationView *_singleBaseView;

@implementation ZLBaseAnimationView

+ (instancetype) animationViewWithOptions:(NSDictionary *) options completion:(void (^)(ZLBaseAnimationView *baseView)) completion{
    return [[self animationView] initViewWithOptions:options completion:completion];
}

#pragma mark - 实例化对象
+ (instancetype) animationView{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _singleBaseView = [[self alloc] init];
    });
    return _singleBaseView;
}

#pragma mark - 重新判断值是否完整，如果不完整就补充
- (NSDictionary *) getTypeViewWithOptions:(NSDictionary *)options{
    UIView *cView = options[UIViewAnimationToView];
    
    NSMutableDictionary *ops = [NSMutableDictionary dictionaryWithDictionary:options];
    CGRect startFrame = [options[UIViewAnimationStartFrame] CGRectValue];
    if (!startFrame.size.width || !startFrame.size.height) {
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
        ops[UIViewAnimationDuration] = [NSNumber numberWithFloat:.25];
    }
    
    // iOS7以下
    if (!iOS7gt) {
        startFrame.origin.y += 64;
    }
    
    self.parsentView = [ops[UIViewAnimationToView] superview];
    
    
    return ops;
}


#pragma mark - 初始化动画
/**
 *  初始化动画
 *
 *  @param options    参数字典
 *  @param completion 结束的动画的block
 */
- (instancetype) initViewWithOptions:(NSDictionary *) options completion:(void (^)(ZLBaseAnimationView *baseView)) completion{
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    // 计算开始坐标
    self.options = [self getTypeViewWithOptions:options];
    
    // 动画执行的模式
    ZLPickerBrowserAnimationStatus animationStatus = [self.options[UIViewAnimationAnimationStatus] integerValue];
    
    // 起始位置、结束位置、动画时间、图片参数
    CGRect startFrame = [self.options[UIViewAnimationStartFrame] CGRectValue];
    CGFloat duration = [self.options[UIViewAnimationDuration] floatValue];
    UIView *selfView = self.options[UIViewAnimationSelfView];
    UIView *view = self.options[UIViewAnimationInView];
    view.userInteractionEnabled = NO;
    view.hidden = NO;
    
    [self.options[UIViewAnimationToView] setHidden:YES];
    
    // 如果不存在baseView就创建
    if (!selfView) {
        if (!_baseView) {
            _baseView =  [[[self class] alloc] init];
        }
    }else{
        _baseView = (ZLBaseAnimationView *)selfView;
    }
    
    // 重置
    _baseView.alpha = 1.0;
    _baseView.frame = startFrame;
    _baseView.hidden = NO;
    
    // 记录开始与结束的Frame
    _startFrame = self.options[UIViewAnimationEndFrame];
    _endFrame = self.options[UIViewAnimationStartFrame];
    
    // 避免重复添加View
    if (![view.subviews.lastObject isKindOfClass:[ZLBaseAnimationView class]]) {
        [view addSubview:_baseView];
    }
    
    // 淡入淡出模式
    if (animationStatus == ZLPickerBrowserAnimationStatusFade) {
        _baseView.alpha = 0;
        _baseView.frame = [self setMaxMinZoomScalesForCurrentBounds];
        //[self.options[UIViewAnimationEndFrame] CGRectValue];
    }
    
    // 开始动画
    [UIView animateWithDuration:duration animations:^{
        // 淡入淡出
        if (animationStatus == ZLPickerBrowserAnimationStatusFade) {
            _baseView.alpha = 1.0;
        }else{
            // 默认缩放
            _baseView.frame = [self setMaxMinZoomScalesForCurrentBounds];
            
        }
    } completion:^(BOOL finished) {
        [_baseView removeFromSuperview];
        if (completion) {
            completion(self);
        }
        // 恢复交互
        view.userInteractionEnabled = YES;
    }];
    
    return _baseView;
}

// 计算Frame根据屏幕的尺寸拉伸或缩小
- (CGRect )setMaxMinZoomScalesForCurrentBounds {
    
    UIImageView *imageView = (UIImageView *)_baseView;
    if (imageView.image == nil) return CGRectZero;
    
    // Sizes
    CGSize boundsSize = [UIScreen mainScreen].bounds.size;
    CGSize imageSize = imageView.image.size;
    
    // 获取最小比例
    CGFloat xScale = boundsSize.width / imageSize.width;
    CGFloat yScale = boundsSize.height / imageSize.height;
    CGFloat minScale = MIN(xScale, yScale);
    
    // 最大的比例不能超过1.0，最小比例按屏幕来拉伸
    if (xScale > 1 && yScale > 1) {
        minScale = MIN(xScale, yScale);
    }
    
    // 重置
    imageView.frame = CGRectMake(0, 0, imageView.image.size.width * minScale, imageView.image.size.height * minScale);
    
    if (![_baseView isKindOfClass:[UIImageView class]]) return CGRectZero;
    
    // Size
    CGRect frameToCenter = _baseView.frame;
    
    // 计算水平方向居中
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = floorf((boundsSize.width - frameToCenter.size.width) / 2.0);
    } else {
        frameToCenter.origin.x = 0;
    }
    
    // 计算垂直方向居中
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = floorf((boundsSize.height - frameToCenter.size.height) / 2.0);
    } else {
        frameToCenter.origin.y = 0;
    }
    
    // Center
    //    if (!CGRectEqualToRect(_baseView.frame, frameToCenter))
    return frameToCenter;
    //    return CGRectZero;
}

#pragma mark - 遍历自己是不是TableViewCell 或者 UICollectionCell
- (UIView *) getViewWithCell:(UIView *)view{
    if ([view.superview isKindOfClass:[UITableViewCell class]] || [view.superview isKindOfClass:[UICollectionViewCell class]] || view == nil) {
        return view.superview;
    }
    return [self getViewWithCell:view.superview];
}

#pragma mark - 根据动画的方向来计算Frame
- (CGRect ) animationDirectionWithRect{
    
    NSNumber *direction = self.options[UIViewAnimationScrollDirection];
    UIButton *cView = self.options[UIViewAnimationToView];
    UIView *parsentView = cView.superview ? cView.superview : self.parsentView;
    
    if (cView.height <= 0) {
        return [self.options[UIViewAnimationStartFrame] CGRectValue];
    }
    
    CGFloat marginX = [self.options[UIViewAnimationSudokuMarginX] floatValue];
    CGFloat marginY = [self.options[UIViewAnimationSudokuMarginY] floatValue];
    
    CGRect imageFrame = CGRectZero;
    
    switch ([direction integerValue]) {
        case ZLPickerBrowserScrollDirectionHorizontal:{
            // 水平方向
            // 如果点击都是同一个图片就不增加x值
            // 记录宽度
            CGFloat width = 0;
            // 如果是第一个view就不需要添加间距
            CGFloat margin = cView.tag == self.currentPage ? 0 : marginX ;
            
            UIView *cell = [self getViewWithCell:cView];
            // 先算父View的x值
            // 求出点击的View的最大x值与点击View的父View进行一个比较
            // 如果得出来的值小于0，就拿点击的View进行计算
            // 如果得出来的值大于等于0，就拿点击View的父View进行计算
            if (cell) {
                // 分页数没改变的情况下, x值就是0
                CGFloat cellX = 0;
                
                cellX = (self.currentPage - cView.tag) * (cView.width + marginX);
                //                if (self.currentPage > cView.tag) {
                //                }
                imageFrame = [parsentView convertRect:CGRectMake(cellX, cView.y, cView.width, cView.height) toView: self.options[UIViewAnimationFromView]];
            }else{
                if (cView.superview) {
                    CGFloat viewX = CGRectGetMaxX(cView.frame) - (cView.tag + 1) * cView.superview.width + marginX;
                    
                    if (viewX < 0) {
                        viewX = CGRectGetMaxX(cView.frame) - (cView.tag + 1) * cView.width + margin + (cView.width ) * self.currentPage;
                        width = cView.width;
                    }else{
                        width = cView.superview.width;
                        viewX += (cView.superview.width) * self.currentPage;
                    }
                    
                    imageFrame = [cView.superview convertRect:CGRectMake(viewX,  cView.y, width, cView.height) toView: self.options[UIViewAnimationFromView]];
                }else{
                    CGFloat margin = CGRectGetMaxX(cView.frame) - (cView.tag + 1) * cView.width;
                    CGFloat imageX = cView.frame.size.width * self.currentPage;
                    imageFrame = [parsentView convertRect:CGRectMake(imageX + margin,  cView.y, cView.frame.size.width, cView.bounds.size.height) toView: self.options[UIViewAnimationFromView]];
                }
            }
            
        }
            break;
        case ZLPickerBrowserScrollDirectionVertical:{
            // 垂直方向
            UIView *cell = [self getViewWithCell:cView];
            // 如果不是tableViewCell/UICollectionCell这类情况
            if (cell == nil) {
                imageFrame = [parsentView convertRect:CGRectMake(cView.x,  self.currentPage * (cView.height + marginY), cView.width, cView.height) toView: self.options[UIViewAnimationFromView]];
            }else{
                CGRect cellF = CGRectMake(cView.x, cView.y + (cView.height + marginY)  * self.currentPage, cView.width, cView.height);
                imageFrame = [cell.superview convertRect:cellF toView: self.options[UIViewAnimationFromView]];
            }
        }
            break;
            
        case ZLPickerBrowserScrollDirectionSudoku:{
            // 九宫格
            NSInteger btnH = cView.height;
            
            // 有间距的情况下
            NSInteger page = [self.options[UIViewAnimationSudokuDisplayCellNumber] integerValue];
            NSInteger row = self.currentPage / page;
            NSInteger col = self.currentPage % page;
            
            CGFloat margin = (cView.width + marginX) * col;
            imageFrame = [cView.superview convertRect:CGRectMake(margin, row * btnH + (row * marginY), cView.frame.size.width, cView.bounds.size.height) toView: self.options[UIViewAnimationFromView]];
        }
            
            break;
        default:
            break;
    }
    
    // iOS7以下需要增加64的高度
    if (!iOS7gt) {
        imageFrame.origin.y += 64;
    }
    
    
    return imageFrame;
}

- (UIView *) getParsentView:(UIView *) view{
    if ([[view subviews] count] >= _photoCount) {
        return view;
    }
    
    return [self getParsentView:view.superview];
}

#pragma mark - 结束动画，支持动画block
- (instancetype) viewAnimateWithAnimations:(void(^)())animations identity:(void(^)(ZLBaseAnimationView *baseView)) completion{
    
    // 设置导航栏显示
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    UIView *cView = self.options[UIViewAnimationToView];
    UIView *parsentView = cView.superview ? cView.superview : self.parsentView;
    
    
    UIView *cell = [self getViewWithCell:cView];
    
    if (cell) {
        cView.hidden = NO;
        if ([cell isKindOfClass:[UICollectionViewCell class]]) {
            for (UICollectionViewCell *childView in cell.superview.subviews) {
                if (![childView isKindOfClass:[UICollectionViewCell class]]) break;
                UIView *iv = [childView.contentView.subviews lastObject];
                if (iv.tag == self.currentPage) {
                    childView.hidden = YES;
                    break;
                }
            }
        }
    }else if (parsentView.subviews.count >= _photoCount){
        parsentView = [self getParsentView:parsentView];
        cView.hidden = NO;
        [parsentView.subviews[self.currentPage] setHidden:YES];
    }
    
    // 动画执行的模式
    ZLPickerBrowserAnimationStatus animationStatus = [self.options[UIViewAnimationAnimationStatus] integerValue];
    _endFrame = [NSValue valueWithCGRect:[self animationDirectionWithRect]];
    
    // 淡入淡出模式
    if (animationStatus == ZLPickerBrowserAnimationStatusFade) {
        _baseView.frame = [_endFrame CGRectValue];
    }
    
    // 让最外面的View不能跟用户进行交互
    [self.options[UIViewAnimationFromView] setUserInteractionEnabled:NO];
    _baseView.hidden = NO;
    _baseView.alpha = 1.0;
    // 把_baseView添加到Window上
    UIWindow *myWindow = [[[UIApplication sharedApplication] windows] firstObject];
    UIView *view = myWindow.subviews.lastObject;
    if (!([view isKindOfClass:[ZLBaseAnimationView class]]) &&
        (![view isKindOfClass:[UIImageView class]]))
    {
        [myWindow addSubview:_baseView];
    }
    
    self.lastCurrentPage = self.currentPage;
    _baseView.frame = [self setMaxMinZoomScalesForCurrentBounds];
    [UIView animateWithDuration:.25 animations:^{
        if (animations) {
            animations();
        }else{
            // 淡入淡出模式
            if (animationStatus == ZLPickerBrowserAnimationStatusFade) {
                [self.options[UIViewAnimationToView] setHidden:NO];
                _baseView.alpha = 0;
            }else{
                _baseView.frame = [_endFrame CGRectValue];
            }
        }
    } completion:^(BOOL finished) {
        if (completion) {
            completion(self);
        }
        
        [_baseView removeFromSuperview];
        
        if (cell) {
            if ([cell isKindOfClass:[UICollectionViewCell class]]) {
                for (UICollectionViewCell *childView in cell.superview.subviews) {
                    if(![childView isKindOfClass:[UICollectionViewCell class]]) break;
                    UIView *iv = [childView.contentView.subviews lastObject];
                    if (iv.tag == self.currentPage) {
                        childView.hidden = NO;
                    }
                }
            }
        }else if (parsentView.subviews.count >= _photoCount){
            [parsentView.subviews[self.currentPage] setHidden:NO];
        }
        
        [self.options[UIViewAnimationToView] setHidden:NO];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // 让最外面的View能跟用户进行交互
            [self.options[UIViewAnimationFromView] setUserInteractionEnabled:YES];
        });
    }];
    
    return  _baseView;
}

#pragma mark - 结束动画
- (instancetype) viewformIdentity:(void(^)(ZLBaseAnimationView *baseView)) completion{
    return [self viewAnimateWithAnimations:nil identity:completion];
}

@end
