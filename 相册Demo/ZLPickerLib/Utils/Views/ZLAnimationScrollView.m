//
//  ZLAnimationScrollView.m
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 14-11-28.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import "ZLAnimationScrollView.h"
#import "UIView+Extension.h"

static UIView *_parsentView;
static NSArray *_photos;

@implementation ZLAnimationScrollView

+ (instancetype)animationViewWithOptions:(NSDictionary *)options animations:(void (^)())animations completion:(void (^)(ZLAnimationBaseView *))completion{
    
    UIView *toView = options[UIViewAnimationToView];
    toView.hidden = YES;
    
    _photos = options[UIViewAnimationImages];
    _parsentView = toView.superview;
    
    return [super animationViewWithOptions:options animations:animations completion:completion];
}

+ (void)restoreWithOptions:(NSDictionary *)options animation:(void (^)())completion{
    
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
            subViews = [[self getParsentView:_parsentView maxCount:_photos.count] subviews];
        }
        
        compareView = [self traversalViewWithCell:toView];
    }else{
        // scrollView
        subViews = toView.superview.subviews;
        if (toView.superview == nil) {
            subViews = _parsentView.subviews;
        }
        compareView = toView;
    }
    
    
    NSInteger nowPage = 0;
    for (NSInteger index = 0; index < subViews.count; index++) {
        UIView *toBrotherView = subViews[index];
        if (compareView == toBrotherView) {
            // 记录当前第几页
            nowPage = index;
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
    if (nowPage == [self currentPage] && subViews.count >= _photos.count) {
        startFrame = [toView.superview convertRect:toView.frame toView:options[UIViewAnimationFromView]];
    }else{
        toView.hidden = NO;
        if ([self currentPage] < subViews.count) {
            if (tableView || collectionView) {
                
                // 横屏
                if (direction == UICollectionViewScrollDirectionHorizontal) {
                    // 分页数没改变的情况下, x值就是0
                    CGFloat cellX = 0;
                    
                    cellX = (self.currentPage - toView.tag) * (toView.width + flowLayout.minimumLineSpacing);
                    startFrame = [_parsentView convertRect:CGRectMake(cellX, toView.y, toView.width, toView.height) toView: options[UIViewAnimationFromView]];
                    
                    
                }else {
                    // 竖屏
                    startFrame = [subViews[[self currentPage]] frame];
                    startFrame.origin.x = toView.x;
                    startFrame.size.width = toView.width;
                    startFrame.size.height = toView.height;
                    startFrame.origin.y = toView.height * ([self currentPage] - (nowPage));
                    
                    startFrame = [toView.superview convertRect:startFrame toView:options[UIViewAnimationFromView]];
                    
                    [subViews[[self currentPage]] setHidden:YES];
                }
                
            }else{
               // scrollView
                startFrame = [subViews[[self currentPage]] frame];
                startFrame = [_parsentView convertRect:startFrame toView:options[UIViewAnimationFromView]];
                
                [subViews[[self currentPage]] setHidden:YES];
            }
            
            
        }
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
    if ([[view subviews] count] >= maxCount) {
        return view;
    }
    return [self getParsentView:view.superview maxCount:maxCount];
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

@end
