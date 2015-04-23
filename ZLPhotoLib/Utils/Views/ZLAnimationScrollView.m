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
        if ([[self currentIndexPath] item] >= KPhotoShowMaxCount) {
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
    
    if ([options[UIViewAnimationAnimationStatusType] longLongValue] == UIViewAnimationAnimationStatusFade) {
        toView.hidden = NO;
    }
    
    __block NSArray *subViews = nil;
    // 如果是TableView子控件的话
    if (tableView || collectionView) {
        if (tableView) {
            if ([[toView.superview subviews] count] == [options[UIViewAnimationImages] count]){
                subViews = [toView.superview subviews];
            }else{
                subViews = [tableView visibleCells];
            }
        }else{
            // note:collectionView visibleCells 里面的元素并不是按frame来排序的
            // 进行frame来排序
            NSMutableArray *cells = [[NSMutableArray alloc] init];
            NSMutableArray *frames = [[NSMutableArray alloc] init];
            
            if (collectionView.visibleCells.count == 0) {
                ops[UIViewAnimationAnimationStatusType] = @(UIViewAnimationAnimationStatusFade);
            }
            
            NSUInteger index = [collectionView.dataSource collectionView:collectionView numberOfItemsInSection:[options[UIViewAnimationTypeViewWithIndexPath] section]];
            
            for (NSInteger i = 0; i < index; i++) {
                UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:[options[UIViewAnimationTypeViewWithIndexPath] section]]];
                if (cell) {
                    [cells addObject:cell];
                }
            }
            
            //            subViews = [collectionView.dataSource collectionView:<#(UICollectionView *)#> cellForItemAtIndexPath:<#(NSIndexPath *)#>];
            //            if ([[collectionView visibleCells] count]) {
            //                subViews = [collectionView visibleCells];
            //            }else{
            //                subViews = [[self getCollectionViewWithCell:_parsentView] subviews];
            //            }
            
            for (UICollectionViewCell *cell in cells) {
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
    }else{
        // scrollView
        if (toView.superview == nil) {
            subViews = _parsentView.subviews;
        } else if ([[toView.superview subviews] count] >= [ops[UIViewAnimationImages] count]) {
            subViews = [toView.superview subviews];
        }else{
            NSMutableArray *subViewsM = [NSMutableArray array];
            subViews = [[self getParsentView:toView maxCount:_photos.count] subviews];
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
        }
        
    }
    
    __block NSInteger val = [self currentIndexPath].item;
    if (collectionView) {
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:[self currentIndexPath]];
        [subViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([cell isEqual:obj]) {
                val = idx;
                *stop = YES;
            }
        }];
    }else if(tableView){
        NSIndexPath *minIndexPath = [tableView indexPathForCell: [subViews firstObject]];
        NSIndexPath *maxIndexPath = [tableView indexPathForCell: [subViews lastObject]];
        
        val = ([self currentIndexPath].item - minIndexPath.row) % subViews.count;
        
        if ((val == 0 && [self currentIndexPath].item > 0) || [self currentIndexPath].item > subViews.count){
            val = subViews.count - 1;
        }
        
        if ([self currentIndexPath].item != 0 && maxIndexPath != nil && ([self currentIndexPath].item <= minIndexPath.row || [self currentIndexPath].item > maxIndexPath.row)) {
            // 改变动画模式
            val = subViews.count + 1;
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
                ios6NavH = -20;
                startFrame = [_parsentView convertRect:toView.frame toView: options[UIViewAnimationFromView]];
                startFrame.origin.y = [ops[UIViewAnimationStartFrame] CGRectValue].origin.y;
                
                startFrame.origin.x = [self currentIndexPath].item * (toView.width + flowLayout.minimumLineSpacing) + collectionView.x - collectionView.contentOffset.x;
                
            } else if(tableView){
                UIView *superView = toView;
                if ([subViews[val] respondsToSelector:@selector(contentView)]){
                    for (UIView *view in [[subViews[val] contentView] subviews]) {
                        if (view.width == toView.width && view.height == toView.height) {
                            superView = view;
                            break;
                        }
                    }
                }else{
                    superView = subViews[val];
                }
                
                startFrame.origin.y = [superView.superview convertRect:superView.frame toView:[self getParsentView:toView]].origin.y;
                startFrame.origin.x = [superView.superview convertRect:superView.frame toView:options[UIViewAnimationFromView]].origin.x;
                startFrame.size.width = toView.width;
                startFrame.size.height = toView.height;
                toView.hidden = NO;
            }else{
                
                if ([options[UIViewAnimationAnimationStatusType] integerValue] != UIViewAnimationAnimationStatusFade) {
                    // 竖屏 UICollectionView 九宫格
                    NSIndexPath *maxIndexPath = [collectionView indexPathForCell:[subViews lastObject]];
                    
                    NSInteger minRow = [[collectionView indexPathForCell:[subViews firstObject]] item];
                    if(minRow == 0){
                        startFrame = [subViews[[[self currentIndexPath] item]] frame];
                    }else{
                        NSInteger count = subViews.count - (maxIndexPath.item - [self currentIndexPath].item);
                        startFrame = [subViews[count-1] frame];
                    }
                    startFrame.origin.y -= collectionView.contentOffset.y;
                    startFrame.size.width = toView.width;
                    startFrame.size.height = toView.height;
                }
                
                if ([options[UIViewAnimationAnimationStatusType] integerValue] == UIViewAnimationAnimationStatusZoom) {
                    [subViews[val] setHidden:YES];
                }
            }
            
        }else{
            // scrollView
            startFrame = [subViews[val] frame];
            startFrame = [_parsentView convertRect:startFrame toView:options[UIViewAnimationFromView]];
            startFrame.size.width = toView.width;
            
            if (
                toView.superview == nil && _parsentView
                && [options[UIViewAnimationNavigationHeight] isEqual:@(0)]) {
                startFrame.origin.y += [self getNavigaitionViewControllerWithView:_parsentView];
            }
            
            if ([options[UIViewAnimationAnimationStatusType] integerValue] == UIViewAnimationAnimationStatusZoom) {
                [subViews[val] setHidden:YES];
            }
        }
    }else{
        ops[UIViewAnimationAnimationStatusType] = @(UIViewAnimationAnimationStatusFade);
    }
    
    if ([options[UIViewAnimationNavigationHeight] integerValue] > 0) {
        startFrame.origin.y += [options[UIViewAnimationNavigationHeight] integerValue];
    }
    
    if (!iOS7gt) {
        startFrame.origin.y += ios6NavH;
    }
    
    if ([options[UIViewAnimationAnimationStatusType] integerValue] == UIViewAnimationAnimationStatusRotate) {
        if (val < subViews.count) {
            [subViews[val] setHidden:NO];
        }
        toView.hidden = NO;
    }
    
    if (subViews.count == 1) {
        startFrame.origin.x = [_parsentView convertRect:toView.frame toView:[self getParsentView:options[UIViewAnimationToView]]].origin.x;
    }
    //    startFrame.origin.y += [[self getParsentView:options[UIViewAnimationToView]] frame].origin.y;
    
    if (subViews.count == 1 && subViews.count < [options[UIViewAnimationImages] count]){
        ops[UIViewAnimationEndFrame] = options[UIViewAnimationStartFrame];
    }else{
        ops[UIViewAnimationEndFrame] = [NSValue valueWithCGRect:startFrame];
    }
    
    [super restoreWithOptions:ops animation:^{
        
        if (collectionView && flowLayout.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
            UIView *cell = [[self getParsentView:_parsentView] hitTest:CGPointMake(startFrame.origin.x, startFrame.origin.y) withEvent:nil];
            if ([options[UIViewAnimationAnimationStatusType] integerValue] == UIViewAnimationAnimationStatusZoom) {
                [cell setHidden:NO];
            }
        }
        
        if ([ops[UIViewAnimationAnimationStatusType] integerValue] != UIViewAnimationAnimationStatusFade) {
            if (subViews.count > val) {
                [subViews[val] setHidden:NO];
            }
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

#pragma mark - 获取CollectionView
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

#pragma mark - 通过View获取控制器
+ (UIViewController *)getViewControllerWithView:(UIView *)view{
    if ([view.nextResponder isKindOfClass:[UIViewController class]] || view == nil) {
        return (UIViewController *)view.nextResponder;
    }
    return [self getViewControllerWithView:view.superview];
}

+ (CGFloat)getNavigaitionViewControllerWithView:(UIView *)view{
    // 1.判断View是否有导航控制器
    if ([[self getViewControllerWithView:view] navigationController] == nil || [[[self getViewControllerWithView:view] navigationController] isNavigationBarHidden]){
        return 0;
    }
    
    // 2.判断是否是iOS6系统返回导航栏高度
    if ([[UIDevice currentDevice].systemVersion floatValue] < 7.0){
        return 44;
    }
    
    return 64;
}

@end