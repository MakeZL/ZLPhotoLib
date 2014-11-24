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

@interface ZLBaseAnimationView ()
// 当前的View
@property (nonatomic , strong) ZLBaseAnimationView *baseView;
// 蒙版
@property (nonatomic , strong) UIView *maskView;
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
        ops[UIViewAnimationDuration] = [NSNumber numberWithFloat:0.5];
    }
    
    // iOS7以下
    if (!iOS7gt) {
        startFrame.origin.y += 64;
    }
    
    return ops;
}


#pragma mark -初始化动画
- (instancetype) initViewWithOptions:(NSDictionary *) options completion:(void (^)(ZLBaseAnimationView *baseView)) completion{
    
    // 计算开始坐标
    self.options = [self getTypeViewWithOptions:options];
    
    // 起始位置、结束位置、动画时间、图片参数
    CGRect startFrame = [self.options[UIViewAnimationStartFrame] CGRectValue];
    CGFloat duration = [self.options[UIViewAnimationDuration] floatValue];
    UIView *selfView = self.options[UIViewAnimationSelfView];
    UIView *view = self.options[UIViewAnimationInView];
    
    
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
        [view addSubview:_baseView];
    }
    
    [UIView animateWithDuration:duration animations:^{
        _baseView.frame = [self.options[UIViewAnimationEndFrame] CGRectValue];
    } completion:^(BOOL finished) {
        [_baseView removeFromSuperview];
        if (completion) {
            completion(self);
        }
        
        view.userInteractionEnabled = YES;
    }];
    
    return _baseView;
}

- (UIView *) getViewWithCell:(UIView *)view{
    if ([view.superview isKindOfClass:[UITableViewCell class]] || [view.superview isKindOfClass:[UICollectionViewCell class]] || view == nil) {
        return view.superview;
    }
    
    return [self getViewWithCell:view.superview];
}

#pragma mark -结束动画，支持动画block
- (instancetype) viewAnimateWithAnimations:(void(^)())animations identity:(void(^)(ZLBaseAnimationView *baseView)) completion{
    
    //    UIView *fromView = self.options[UIViewAnimationFromView];
    NSNumber *direction = self.options[UIViewAnimationScrollDirection];
    UIButton *cView = self.options[UIViewAnimationToView];
    CGRect imageFrame = CGRectZero;
    
    switch ([direction integerValue]) {
        case ZLPickerBrowserScrollDirectionHorizontal:{
            // 水平方向
            CGFloat margin = CGRectGetMaxX(cView.frame) - (cView.tag + 1) * cView.width;
            CGFloat imageX = cView.frame.size.width * self.currentPage;
            imageFrame = [cView.superview convertRect:CGRectMake(imageX + margin,  cView.y, cView.frame.size.width, cView.bounds.size.height) toView: self.options[UIViewAnimationFromView]];
        }
            break;
        case ZLPickerBrowserScrollDirectionVertical:{
            // 垂直方向
            UIView *cell = [self getViewWithCell:cView];
            if (cell == nil) {
                NSInteger padding = ((NSInteger)cView.y % (NSInteger)cView.height);
                
                // NOTE: 保证计算y的间距是正常的。
                // !!  : self.currentPage如果为0还计算会崩溃
                if (!self.currentPage) {
                    padding = 0;
                }else{
                    padding = padding / (self.currentPage - 1);
                }
                
                imageFrame = [cView.superview convertRect:CGRectMake(cView.x,  self.currentPage * (cView.height + padding), cView.width, cView.height) toView: self.options[UIViewAnimationFromView]];
            }else{
                CGRect cellF = CGRectMake(cView.x, cView.y + cView.height  * self.currentPage, cView.width, cView.height);
                imageFrame = [cell.superview convertRect:cellF toView: self.options[UIViewAnimationFromView]];
            }
        }
            break;
            
        case ZLPickerBrowserScrollDirectionSudoku:{
            // 九宫格
            CGFloat marginX = [self.options[UIViewAnimationSudokuMarginX] floatValue];
            CGFloat marginY = [self.options[UIViewAnimationSudokuMarginY] floatValue];
            
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
    _endFrame = [NSValue valueWithCGRect:imageFrame];
    
    
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
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // 让最外面的View能跟用户进行交互
            myWindow.userInteractionEnabled = YES;
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
