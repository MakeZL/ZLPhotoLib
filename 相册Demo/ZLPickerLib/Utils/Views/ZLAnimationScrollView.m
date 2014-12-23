//
//  ZLAnimationScrollView.m
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 14-11-28.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import "ZLAnimationScrollView.h"
#import "UIView+Extension.h"
#import "ZLPickerCommon.h"

static UIView *_parsentView;
static NSArray *_photos;
static NSMutableDictionary *_attachParams = nil;
static NSUInteger prevAnimationStatusType;

@implementation ZLAnimationScrollView

+ (void)orientationChanged:(NSNotification *)noti{
    
    UIDevice *device = noti.object;
    if(device.orientation == UIDeviceOrientationLandscapeLeft || device.orientation == UIDeviceOrientationLandscapeRight){
        _attachParams[UIViewAnimationAnimationStatusType] = @(UIViewAnimationAnimationStatusFade);
    }else{
        _attachParams[UIViewAnimationAnimationStatusType] = @(UIViewAnimationAnimationStatusZoom);
    }
}

+ (NSDictionary *)updateOptions:(NSDictionary *)updateOptions{
    
    if (!_attachParams) {
        _attachParams = [NSMutableDictionary dictionary];
    }
    
    if (_attachParams) {
        NSMutableDictionary *ops = [NSMutableDictionary dictionaryWithDictionary:updateOptions];
        [ops addEntriesFromDictionary:_attachParams];
        updateOptions = ops;
    }
    
    return updateOptions;
}

+ (instancetype)animationViewWithOptions:(NSDictionary *)options animations:(void (^)())animations completion:(void (^)(ZLAnimationBaseView *))completion{
    [_attachParams setObject:@(UIViewAnimationAnimationStatusZoom) forKey:UIViewAnimationAnimationStatusType];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];

    prevAnimationStatusType = [options[UIViewAnimationAnimationStatusType] integerValue];
    
    options = [self updateOptions:options];
    
    UIView *toView = options[UIViewAnimationToView];
    
    if ([options[UIViewAnimationAnimationStatusType] integerValue] == UIViewAnimationAnimationStatusZoom) {
        toView.hidden = YES;
    }
    
    _photos = options[UIViewAnimationImages];
    _parsentView = toView.superview;
    
    return [super animationViewWithOptions:options animations:animations completion:completion];
}

+ (void)restoreWithOptions:(NSDictionary *)options animation:(void (^)())completion{
    
    prevAnimationStatusType = [options[UIViewAnimationAnimationStatusType] integerValue];
    
    options = [self updateOptions:options];
    
    NSMutableDictionary *ops = [NSMutableDictionary dictionaryWithDictionary:options];
    
    UIView *toView = options[UIViewAnimationToView];
    
    // 所有的图片
    //    NSArray *images = options[UIViewAnimationImages];
    
    UITableView *tableView = (UITableView *)[self getTableViewWithView:toView];
    UICollectionView *collectionView = (UICollectionView *)[self getCollectionViewWithView:toView];
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)collectionView.collectionViewLayout;
    UICollectionViewScrollDirection direction = flowLayout.scrollDirection;
    
    __block NSArray *subViews = nil;
    UIView *compareView = nil;
    // 如果是TableView子控件的话
    if (tableView || collectionView) {
        if (tableView) {
            subViews = [tableView visibleCells];
        }else{
            // note:collectionView visibleCells 里面的元素并不是按frame来排序的
            // 进行frame来排序
            NSMutableArray *cells = [[NSMutableArray alloc] init];
            NSMutableArray *frames = [[NSMutableArray alloc] init];
            
            CGRect rect = [[[collectionView visibleCells] firstObject] frame];
            
            UIView *subV = [self getCollectionViewWithCell:_parsentView];
            
            for (UICollectionViewCell *cell in subV.subviews) {
                if (![cell isKindOfClass:[UICollectionViewCell class]]) {
                    continue;
                }
                if ([options[UIViewAnimationAnimationStatusType] integerValue] == UIViewAnimationAnimationStatusZoom) {
                    cell.hidden = NO;
                }
                CGRect cellFrame = [cell.superview convertRect:cell.frame toView:options[UIViewAnimationFromView]];
                [frames addObject:[NSNumber numberWithFloat:cellFrame.origin.x]];
            }
            
            NSArray *framexs = [frames sortedArrayUsingSelector:@selector(compare:)];
            
            for (NSNumber *x in framexs) {
                rect.origin.x = [x floatValue];
                
                UIView *cell = [collectionView hitTest:CGPointMake(rect.origin.x, rect.origin.y) withEvent:nil];
                if (cell != nil) {
                    [cells addObject:cell];
                }
            }
            subViews = cells;
        }
        
        compareView = [self traversalViewWithCell:toView];
    }else{
        // scrollView
        subViews = [[self getParsentView:toView maxCount:_photos.count] subviews];
        //        subViews = toView.superview.subviews;
        if (toView.superview == nil) {
            subViews = _parsentView.subviews;
        }
        compareView = toView;
    }
    
    NSInteger nowPage = 0;
    NSInteger currPage = 0;
    for (NSInteger index = 0; index < subViews.count; index++) {
        UIView *toBrotherView = subViews[index];
        if ([compareView isEqual:toBrotherView]) {
            // 记录当前第几页
            nowPage = index;
        }
        
        if (collectionView) {
            if ([subViews[[self currentPage]] isEqual:toBrotherView]) {
                currPage = index;
            }
        }
    }
    
    // 计算当前的值
    if (tableView || collectionView) {
        if (tableView) {
            nowPage = [[tableView indexPathForCell:(UITableViewCell *)compareView] row];
        }
        
        if (collectionView) {
            nowPage = [[collectionView indexPathForCell:(UICollectionViewCell *)compareView] row];
        }
    }
    
    CGRect startFrame = CGRectZero;
    // 如果点击的图还是一样，并且图片的数量一致的就恢复
    if ([options[UIViewAnimationAnimationStatusType] integerValue] == UIViewAnimationAnimationStatusZoom) {
        toView.hidden = NO;
    }
    NSInteger ios6NavH = 20;
    if ([self currentPage] < subViews.count) {
        if (tableView || collectionView) {
            
            // 横屏
            if (direction == UICollectionViewScrollDirectionHorizontal) {
                // 分页数没改变的情况下, x值就是0
                ios6NavH = -20;
                startFrame = [_parsentView convertRect:toView.frame toView: options[UIViewAnimationFromView]];
                startFrame.origin.y = [ops[UIViewAnimationStartFrame] CGRectValue].origin.y;
                startFrame.origin.x = self.currentPage * (toView.width + flowLayout.minimumLineSpacing) + collectionView.x;
                if ([options[UIViewAnimationAnimationStatusType] integerValue] == UIViewAnimationAnimationStatusZoom) {
                    [subViews[[self currentPage]] setHidden:YES];
                }
            }else {
                // 竖屏
                startFrame = [subViews[[self currentPage]] frame];
                startFrame.origin.x = toView.x;
                startFrame.size.width = toView.width;
                startFrame.size.height = toView.height;
                startFrame.origin.y = toView.height * ([self currentPage] - (nowPage));
                
                startFrame = [toView.superview convertRect:startFrame toView:options[UIViewAnimationFromView]];
                if ([options[UIViewAnimationAnimationStatusType] integerValue] == UIViewAnimationAnimationStatusZoom) {
                    [subViews[[self currentPage]] setHidden:YES];
                }
            }
            
        }else{
            // scrollView
            UIView *p = subViews[[self currentPage]];
            
            startFrame = [subViews[[self currentPage]] frame];
            startFrame = [p.superview convertRect:startFrame toView:options[UIViewAnimationFromView]];
            if ([options[UIViewAnimationAnimationStatusType] integerValue] == UIViewAnimationAnimationStatusZoom) {
                [subViews[[self currentPage]] setHidden:YES];
            }
        }
    }
    
    if (!iOS7gt) {
        startFrame.origin.y += ios6NavH;
    }
    
    if ([options[UIViewAnimationAnimationStatusType] integerValue] == UIViewAnimationAnimationStatusFade) {
        if ([self currentPage] < subViews.count) {
            [subViews[[self currentPage]] setHidden:NO];
        }
        toView.hidden = NO;
    }
    
    startFrame.origin.y += [[self getParsentView:options[UIViewAnimationToView]] frame].origin.y;
    
    if ([options[UIViewAnimationAnimationStatusType] integerValue] == UIViewAnimationAnimationStatusZoom && prevAnimationStatusType != UIViewAnimationAnimationStatusZoom) {
        startFrame.origin.y += 20;
    }
    
    ops[UIViewAnimationEndFrame] = [NSValue valueWithCGRect:startFrame];
    [super restoreWithOptions:ops animation:^{
        
        if ([self currentPage] < subViews.count) {
            [subViews[[self currentPage]] setHidden:NO];
        }
        
        toView.hidden = NO;
        subViews = nil;
        if (completion) {
            completion();
        }
    }];
    
}

#pragma mark -
#pragma mark 获取父View
+ (UIView *) getParsentView:(UIView *) view maxCount:(NSInteger)maxCount{
    if ([[view subviews] count] >= maxCount || view == nil) {
        return view;
    }
    return [self getParsentView:view.superview maxCount:maxCount];
}

#pragma mark 获取ScrollView
+ (UIView *) getCollectionViewWithCell:(UIView *)view{
    
    for (int i = 0; i < view.subviews.count; i++) {
        UICollectionViewCell *cell = view.subviews[i];
        if ([cell isKindOfClass:[UICollectionViewCell class]] || view == nil) {
            return view;
        }
    }
    return [self getCollectionViewWithCell:view.superview];
}


#pragma mark 获取ScrollView
+ (UIView *) getScrollViewWithView:(UIView *)view{
    if ([view isKindOfClass:[UIScrollView class]] || view == nil) {
        return view;
    }
    return [self getScrollViewWithView:view.superview];
}


#pragma mark 获取TableView
+ (UIView *) getTableViewWithView:(UIView *)view{
    
    if ([view.superview isKindOfClass:[UITableView class]]) {
        for (UIView *tView in view.superview.subviews) {
            if ([tView isKindOfClass:[UITableViewHeaderFooterView class]]) {
                return nil;
            }
        }
    }
    
    if ([view isKindOfClass:[UITableView class]] || view == nil) {
        
        return view;
    }
    return [self getTableViewWithView:view.superview];
}

#pragma mark 获取CollectionView
+ (UIView *) getCollectionViewWithView:(UIView *)view{
    
    if ([view isKindOfClass:[UICollectionView class]] || view == nil) {
        return view;
    }
    return [self getCollectionViewWithView:view.superview];
}

#pragma mark - 获取父View
+ (UIView *)getParsentView:(UIView *)view{
    if ([[view nextResponder] isKindOfClass:[UIViewController class]] || view == nil) {
        return view;
    }
    return [self getParsentView:view.superview];
}




@end
