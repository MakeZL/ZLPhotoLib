//
//  ZLAnimationScrollView.m
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 14-11-28.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import "ZLAnimationScrollView.h"
#import "UIView+Extension.h"
#import "ZLPhotoPickerCommon.h"

static UIView *_parsentView;
static NSArray *_photos;
static NSMutableDictionary *_attachParams = nil;
static NSArray *_subViews = nil;

@implementation ZLAnimationScrollView

+ (NSDictionary *)updateOptions:(NSDictionary *)updateOptions statusStart:(BOOL)start{
    
    if (!_attachParams) {
        _attachParams = [NSMutableDictionary dictionary];
    }
    
    NSMutableDictionary *ops = [NSMutableDictionary dictionaryWithDictionary:updateOptions];
    
    if (!start) {
        if ([self currentPage] >= KPhotoShowMaxCount) {
            ops[UIViewAnimationAnimationStatusType] = @(UIViewAnimationAnimationStatusFade);
        }
    }
    [ops addEntriesFromDictionary:_attachParams];
    
    return ops;
}

+ (instancetype)animationViewWithOptions:(NSDictionary *)options animations:(void (^)())animations completion:(void (^)(ZLAnimationBaseView *))completion{
    
    options = [self updateOptions:options statusStart:YES];
    
    
    UIView *toView = options[UIViewAnimationToView];
    
    if ([_attachParams[UIViewAnimationAnimationStatusType] integerValue] == UIViewAnimationAnimationStatusZoom && (![self getCollectionViewWithView:toView])) {
        toView.hidden = YES;
    }
    
    _photos = options[UIViewAnimationImages];
    _parsentView = toView.superview;
    
    return [super animationViewWithOptions:options animations:animations completion:completion];
}

+ (void)restoreWithOptions:(NSDictionary *)options animation:(void (^)())completion{
    
    options = [self updateOptions:options statusStart:NO];
    NSMutableDictionary *ops = [NSMutableDictionary dictionaryWithDictionary:options];
    UIView *toView = options[UIViewAnimationToView];
    
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
            
            if ([[collectionView visibleCells] count]) {
                subViews = [collectionView visibleCells];
            }else{
                subViews = [[self getCollectionViewWithCell:_parsentView] subviews];
            }
            
            for (UICollectionViewCell *cell in subViews) {
                if (![cell isKindOfClass:[UICollectionViewCell class]]) {
                    continue;
                }
                if ([options[UIViewAnimationAnimationStatusType] integerValue] == UIViewAnimationAnimationStatusZoom) {
                    cell.hidden = NO;
                }
                
                [frames addObject:[NSValue valueWithCGRect:cell.frame]];
            }
            
            NSMutableSet *set = [NSMutableSet setWithArray:frames];
            
            for (NSValue *val in [set allObjects]) {
                for (UICollectionViewCell *cell in subViews) {
                    if (CGRectEqualToRect(cell.frame, [val CGRectValue])) {
                        [cells addObject:cell];
                        break;
                    }
                }
            }
            
            cells = [NSMutableArray arrayWithArray:[cells sortedArrayUsingComparator:^NSComparisonResult(UICollectionViewCell *cell1,UICollectionViewCell *cell2) {
                NSValue *obj1 = [NSValue valueWithCGRect:[cell1.superview convertRect:cell1.frame toView:options[UIViewAnimationFromView]]];
                NSValue *obj2 = [NSValue valueWithCGRect:[cell2.superview convertRect:cell2.frame toView:options[UIViewAnimationFromView]]];
                CGRect rc1 = [obj1 CGRectValue];
                CGRect rc2 = [obj2 CGRectValue];
                
                NSComparisonResult ca = [@(rc1.origin.y) compare:@(rc2.origin.y)];
                if (ca == NSOrderedSame) {
                    ca = [@(rc1.origin.x) compare:@(rc2.origin.x)];
                }
                return ca;
            }]];
            
            subViews = cells;
        }
        
        compareView = [self traversalViewWithCell:toView];
    }else{
        
        NSMutableArray *subViewsM = [NSMutableArray array];
        
        // scrollView
        if (toView.superview == nil) {
            subViews = _parsentView.subviews;
        } else {
            subViews = [[self getParsentView:toView maxCount:_photos.count] subviews];
        }
        
        for (UIView *view in subViews) {
            if (view.tag >= 1) {
                [subViewsM addObject:view];
            }
        }
        
        for (int i = 0; i < subViews.count; i++) {
            if ([(UIView *)subViews[i] tag] == 0) {
                if([subViews[i] width] == [[subViewsM firstObject] width] && [subViews[i] isKindOfClass:[[subViewsM firstObject] class]]){
                    [subViewsM insertObject:subViews[i] atIndex:0];
                }
            }
        }
        
        for (UIView *view in subViews) {
            if (view.tag < 1) {
                [subViewsM addObject:view];
            }
        }
        
        subViews = subViewsM;
        compareView = toView;
    }
    
    NSInteger val = [self currentPage];
    if ([self currentPage] >= subViews.count) {
        val = [self currentPage] - (([self currentPage] % subViews.count == 0 ? [self currentPage] - subViews.count  : [self currentPage] % subViews.count)) - 1;
        if (val < 0) {
            val = 0;
        }
    }
    
    CGRect startFrame = CGRectZero;
    // 如果点击的图还是一样，并且图片的数量一致的就恢复
    if ([options[UIViewAnimationAnimationStatusType] integerValue] == UIViewAnimationAnimationStatusZoom) {
        toView.hidden = NO;
    }
    NSInteger ios6NavH = 20;
    if (val < subViews.count) {
        if (tableView || collectionView) {
            
            // 横屏
            if (direction == UICollectionViewScrollDirectionHorizontal) {
                // 分页数没改变的情况下, x值就是0
                NSArray *indexPaths = [collectionView indexPathsForVisibleItems];
                NSIndexPath *minPath = [[indexPaths sortedArrayUsingSelector:@selector(compare:)] firstObject];
                NSIndexPath *maxPath = [[indexPaths sortedArrayUsingSelector:@selector(compare:)] lastObject];
                
                ios6NavH = -20;
                startFrame = [_parsentView convertRect:toView.frame toView: options[UIViewAnimationFromView]];
                startFrame.origin.y = [ops[UIViewAnimationStartFrame] CGRectValue].origin.y;
                
                NSInteger currentPage = [self currentPage];
                if (maxPath.item > subViews.count) {
                    currentPage = [self currentPage] - minPath.item;
                }
                startFrame.origin.x = currentPage * (toView.width + flowLayout.minimumLineSpacing) + collectionView.x;
                if ([options[UIViewAnimationAnimationStatusType] integerValue] == UIViewAnimationAnimationStatusZoom) {
                    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:[self currentPage] inSection:0]];
                    [cell setHidden:YES];
                }
            } else if(tableView){
                
                // 竖屏
                startFrame = [subViews[[self currentPage]] frame];
                startFrame.origin.x = [toView.superview convertRect:toView.frame toView:options[UIViewAnimationFromView]].origin.x;
                startFrame.size.width = toView.width;
                startFrame.size.height = toView.height;
                startFrame.origin.y = toView.height * ([self currentPage]) + 64;
                
                if ([options[UIViewAnimationAnimationStatusType] integerValue] == UIViewAnimationAnimationStatusZoom) {
                    [subViews[[self currentPage]] setHidden:YES];
                }
            }else{
                
                if ([options[UIViewAnimationAnimationStatusType] integerValue] != UIViewAnimationAnimationStatusFade) {
                    // 竖屏 UICollectionView 九宫格
                    startFrame = [subViews[[self currentPage]] frame];
                    startFrame.size.width = toView.width;
                    startFrame.size.height = toView.height;
                    startFrame.origin.y += 64;
                }
                
                if ([options[UIViewAnimationAnimationStatusType] integerValue] == UIViewAnimationAnimationStatusZoom) {
                    [subViews[[self currentPage]] setHidden:YES];
                }
            }
            
        }else{
            // scrollView
            startFrame = [subViews[[self currentPage]] frame];
            startFrame = [_parsentView convertRect:startFrame toView:options[UIViewAnimationFromView]];
            
            if (toView.superview == nil && _parsentView) {
                startFrame.origin.y += 64;
            }
            
            if ([options[UIViewAnimationAnimationStatusType] integerValue] == UIViewAnimationAnimationStatusZoom) {
                [subViews[[self currentPage]] setHidden:YES];
            }
        }
    }
    
    if (!iOS7gt) {
        startFrame.origin.y += ios6NavH;
    }
    
    if ([options[UIViewAnimationAnimationStatusType] integerValue] == UIViewAnimationAnimationStatusRotate) {
        if ([self currentPage] < subViews.count) {
            [subViews[[self currentPage]] setHidden:NO];
        }
        toView.hidden = NO;
    }
    
    startFrame.origin.y += [[self getParsentView:options[UIViewAnimationToView]] frame].origin.y;
    
    if (subViews.count == 1) {
        startFrame.origin.x = toView.x + startFrame.origin.x;
    }
    
    ops[UIViewAnimationEndFrame] = [NSValue valueWithCGRect:startFrame];
    [super restoreWithOptions:ops animation:^{
        
        if ([ops[UIViewAnimationAnimationStatusType] integerValue] != UIViewAnimationAnimationStatusFade) {
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
    
    NSMutableArray *array = [NSMutableArray array];
    for (UIView *childView in [view subviews]) {
        if ([childView isKindOfClass:[UIImageView class]]) {
            [array addObject:childView];
        }
    }
    
    if ([[view subviews] count] >= maxCount || view == nil) {
        return view;
    }
    
    return [self getParsentView:view.superview maxCount:maxCount];
}

#pragma mark - 获取ScrollView
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
