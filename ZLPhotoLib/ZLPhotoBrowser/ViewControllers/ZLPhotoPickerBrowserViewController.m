//
//  ZLPhotoPickerBrowserViewController.m
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 14-11-14.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import <objc/runtime.h>
#import "ZLPhotoPickerBrowserViewController.h"
#import "ZLPhotoPickerBrowserPhoto.h"
#import "ZLPhotoPickerDatas.h"
#import "UIView+Extension.h"
#import "ZLPhotoPickerBrowserPhotoScrollView.h"
#import "ZLPhotoPickerCommon.h"
#import "ZLAnimationScrollView.h"

static NSString *_cellIdentifier = @"collectionViewCell";

@interface ZLPhotoPickerBrowserViewController () <UIScrollViewDelegate,ZLPhotoPickerPhotoScrollViewDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,UICollectionViewDelegate>

// 控件
@property (weak,nonatomic) UILabel          *pageLabel;
@property (weak,nonatomic) UIButton         *deleleBtn;
@property (weak,nonatomic) UIButton         *backBtn;
@property (weak,nonatomic) UICollectionView *collectionView;

// 数据相关
// 单击时执行销毁的block
@property (nonatomic , copy) ZLPickerBrowserViewControllerTapDisMissBlock disMissBlock;
// 装着所有的图片模型
@property (nonatomic , strong) NSMutableArray *photos;
// 当前提供的分页数
@property (nonatomic , assign) NSInteger currentPage;

@end


@implementation ZLPhotoPickerBrowserViewController

#pragma mark - getter
#pragma mark photos
- (NSMutableArray *)photos{
    if (!_photos) {
        _photos = [NSMutableArray array];
        [_photos addObjectsFromArray:[self getPhotos]];
    }
    return _photos;
}

#pragma mark collectionView
- (UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.minimumLineSpacing = ZLPickerColletionViewPadding;
        flowLayout.itemSize = self.view.size;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.width + ZLPickerColletionViewPadding,self.view.height) collectionViewLayout:flowLayout];
        collectionView.showsHorizontalScrollIndicator = NO;
        collectionView.showsVerticalScrollIndicator = NO;
        collectionView.pagingEnabled = YES;
        collectionView.backgroundColor = [UIColor clearColor];
        collectionView.bounces = YES;
        collectionView.delegate = self;
        [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:_cellIdentifier];
        
        [self.view addSubview:collectionView];
        self.collectionView = collectionView;
        
        _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_collectionView]-x-|" options:0 metrics:@{@"x":@(-20)} views:@{@"_collectionView":_collectionView}]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_collectionView]-0-|" options:0 metrics:nil views:@{@"_collectionView":_collectionView}]];
        
        self.pageLabel.hidden = NO;
        self.deleleBtn.hidden = !self.isEditing;
    }
    return _collectionView;
}

#pragma mark deleleBtn
- (UIButton *)deleleBtn{
    if (!_deleleBtn) {
        UIButton *deleleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        deleleBtn.translatesAutoresizingMaskIntoConstraints = NO;
        deleleBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        //        [deleleBtn setTitle:@"删除" forState:UIControlStateNormal];
        [deleleBtn setImage:[UIImage imageNamed:@"nav_delete_btn"] forState:UIControlStateNormal];
        
        // 设置阴影
        deleleBtn.layer.shadowColor = [UIColor blackColor].CGColor;
        deleleBtn.layer.shadowOffset = CGSizeMake(0, 0);
        deleleBtn.layer.shadowRadius = 3;
        deleleBtn.layer.shadowOpacity = 1.0;
        
        [deleleBtn addTarget:self action:@selector(delete) forControlEvents:UIControlEventTouchUpInside];
        deleleBtn.hidden = YES;
        [self.view addSubview:deleleBtn];
        self.deleleBtn = deleleBtn;
        
        NSString *widthVfl = @"H:[deleleBtn(deleteBtnWH)]-margin-|";
        NSString *heightVfl = @"V:|-margin-[deleleBtn(deleteBtnWH)]";
        NSDictionary *metrics = @{@"deleteBtnWH":@(50),@"margin":@(10)};
        NSDictionary *views = NSDictionaryOfVariableBindings(deleleBtn);
        
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:widthVfl options:0 metrics:metrics views:views]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:heightVfl options:0 metrics:metrics views:views]];
        
    }
    return _deleleBtn;
}

#pragma mark pageLabel
- (UILabel *)pageLabel{
    if (!_pageLabel) {
        UILabel *pageLabel = [[UILabel alloc] init];
        pageLabel.font = [UIFont systemFontOfSize:18];
        pageLabel.textAlignment = NSTextAlignmentCenter;
        pageLabel.userInteractionEnabled = NO;
        pageLabel.translatesAutoresizingMaskIntoConstraints = NO;
        pageLabel.backgroundColor = [UIColor clearColor];
        pageLabel.textColor = [UIColor whiteColor];
        [self.view addSubview:pageLabel];
        self.pageLabel = pageLabel;
        
        NSString *widthVfl = @"H:|-0-[pageLabel]-0-|";
        NSString *heightVfl = @"V:[pageLabel(ZLPickerPageCtrlH)]-20-|";
        NSDictionary *views = NSDictionaryOfVariableBindings(pageLabel);
        NSDictionary *metrics = @{@"ZLPickerPageCtrlH":@(ZLPickerPageCtrlH)};
        
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:widthVfl options:0 metrics:metrics views:views]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:heightVfl options:0 metrics:metrics views:views]];
        
    }
    return _pageLabel;
}

#pragma mark - Life cycle
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSAssert(self.dataSource, @"你没成为数据源代理");
    [self collectionView];
    // 初始化动画
    [self startLogddingAnimation];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
}

#pragma mark - Get
#pragma mark getPhotos
- (NSArray *) getPhotos{
    NSMutableArray *photos = [NSMutableArray array];
    NSInteger section = self.currentIndexPath.section;
    NSInteger rows = [self.dataSource photoBrowser:self numberOfItemsInSection:section];
    for (NSInteger i = 0; i < rows; i++) {
        [photos addObject:[self.dataSource photoBrowser:self photoAtIndexPath:[NSIndexPath indexPathForItem:i inSection:section]]];
    }
    return photos;
}

#pragma mark get Controller.view
- (UIView *)getParsentView:(UIView *)view{
    if ([[view nextResponder] isKindOfClass:[UIViewController class]] || view == nil) {
        return view;
    }
    return [self getParsentView:view.superview];
}

- (id)getParsentViewController:(UIView *)view{
    if ([[view nextResponder] isKindOfClass:[UIViewController class]] || view == nil) {
        return [view nextResponder];
    }
    return [self getParsentViewController:view.superview];
}

#pragma makr - init Animation
- (void)startLogddingAnimation{
    if (!(self.toView) ) {
        [self reloadData];
        return;
    }
    
    // 判断是否是控制器
    UIView *fromView = object_getIvar(self.dataSource, class_getInstanceVariable([self.dataSource class],"_view"));
    // 如果是自定义View
    if (fromView == nil) {
        fromView = [self getParsentView:self.toView];
    }
    
    if (!self.currentIndexPath) {
        self.currentIndexPath = [NSIndexPath indexPathForItem:self.currentPage inSection:0];
    }else{
        self.currentPage = self.currentIndexPath.row;
    }
    
    NSDictionary *options = @{
                              UIViewAnimationInView:self.view,
                              UIViewAnimationFromView:fromView,
                              UIViewAnimationAnimationStatusType:@(self.status),
                              UIViewAnimationNavigationHeight : @(self.navigationHeight),
                              UIViewAnimationToView:self.toView,
                              UIViewAnimationFromView:self.dataSource,
                              UIViewAnimationImages:self.photos,
                              UIViewAnimationTypeViewWithIndexPath:self.currentIndexPath
                              };
    
    __weak typeof(self) weakSelf = self;
    
    [ZLAnimationScrollView animationViewWithOptions:options animations:nil completion:^(ZLAnimationBaseView *baseView) {
        // disMiss后调用
        weakSelf.disMissBlock = ^(NSInteger page){
            if (self.currentIndexPath) {
                [ZLAnimationScrollView setCurrentIndexPath:[NSIndexPath indexPathForItem:page inSection:self.currentIndexPath.section]];
            }else{
                [ZLAnimationScrollView setCurrentIndexPath:[NSIndexPath indexPathForItem:page inSection:0]];
            }
            [weakSelf dismissViewControllerAnimated:NO completion:nil];
            [ZLAnimationScrollView restoreAnimation:nil];
        };
        [weakSelf reloadData];
    }];
}

#pragma mark - reloadData
- (void) reloadData{
    self.collectionView.dataSource = self;
    [self.collectionView reloadData];
    
    // 添加自定义View
    if ([self.delegate respondsToSelector:@selector(photoBrowserShowToolBarViewWithphotoBrowser:)]) {
        UIView *toolBarView = [self.delegate photoBrowserShowToolBarViewWithphotoBrowser:self];
        toolBarView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        CGFloat width = self.view.width;
        CGFloat x = self.view.x;
        if (toolBarView.width) {
            width = toolBarView.width;
        }
        if (toolBarView.x) {
            x = toolBarView.x;
        }
        toolBarView.frame = CGRectMake(x, self.view.height - 44, width, 44);
        [self.view addSubview:toolBarView];
    }
    
    [self setPageLabelPage:self.currentPage];
    if (self.currentPage >= 0) {
        CGFloat attachVal = 0;
        if (self.currentPage == [self.dataSource photoBrowser:self numberOfItemsInSection:self.currentIndexPath.section] - 1 && self.currentPage > 0) {
            attachVal = ZLPickerColletionViewPadding;
        }
        
        self.collectionView.x = -attachVal;
        self.collectionView.contentOffset = CGPointMake(self.currentPage * self.collectionView.width, 0);
    }
    
}


#pragma mark - <UICollectionViewDataSource>
- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.dataSource photoBrowser:self numberOfItemsInSection:self.currentIndexPath.section];
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:_cellIdentifier forIndexPath:indexPath];
    
    if (self.photos.count) {
        cell.backgroundColor = [UIColor clearColor];
        ZLPhotoPickerBrowserPhoto *photo = self.photos[indexPath.item]; //[self.dataSource photoBrowser:self photoAtIndex:indexPath.item];
        
        if([[cell.contentView.subviews lastObject] isKindOfClass:[UIView class]]){
            [[cell.contentView.subviews lastObject] removeFromSuperview];
        }
        
        UIView *scrollBoxView = [[UIView alloc] init];
        scrollBoxView.frame = [UIScreen mainScreen].bounds;
        scrollBoxView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [cell.contentView addSubview:scrollBoxView];
        
        ZLPhotoPickerBrowserPhotoScrollView *scrollView =  [[ZLPhotoPickerBrowserPhotoScrollView alloc] init];
        scrollView.sheet = self.sheet;
        scrollView.backgroundColor = [UIColor clearColor];
        // 为了监听单击photoView事件
        scrollView.frame = [UIScreen mainScreen].bounds;
        scrollView.photoScrollViewDelegate = self;
        scrollView.photo = photo;
        __weak typeof(scrollBoxView)weakScrollBoxView = scrollBoxView;
        __weak typeof(self)weakSelf = self;
        if ([self.delegate respondsToSelector:@selector(photoBrowser:photoDidSelectView:atIndexPath:)]) {
            [[scrollBoxView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
            scrollView.callback = ^(id obj){
                [weakSelf.delegate photoBrowser:weakSelf photoDidSelectView:weakScrollBoxView atIndexPath:indexPath];
            };
        }
        
        [scrollBoxView addSubview:scrollView];
        scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        if (self.currentPage == self.photos.count - 1 && scrollView.x >= 0 && !collectionView.isDragging) {
            UICollectionView *collecitonView2 = (UICollectionView *)[self getScrollViewBaseViewWithCell:self.toView] ;
            if ([collecitonView2 isMemberOfClass:[UICollectionView class]]) {
                UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)collecitonView2.collectionViewLayout;
                if (layout.scrollDirection == UICollectionViewScrollDirectionVertical) {
                    scrollView.x = -ZLPickerColletionViewPadding;
                }else{
                }
            }else{
                scrollView.x = 0;
            }
        }
        
    }
    
    return cell;
}

#pragma mark - 获取CollectionView
- (UIView *) getScrollViewBaseViewWithCell:(UIView *)view{
    for (int i = 0; i < view.subviews.count; i++) {
        UICollectionViewCell *cell = view.subviews[i];
        if ([cell isKindOfClass:[UICollectionView class]] || [cell isKindOfClass:[UITableView class]]  || [cell isKindOfClass:[UIScrollView class]] || view == nil) {
            return cell;
        }
    }
    return [self getScrollViewBaseViewWithCell:view.superview];
}

#pragma mark - <UIScrollViewDelegate>
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGRect tempF = self.collectionView.frame;
    NSInteger currentPage = (NSInteger)((scrollView.contentOffset.x / scrollView.width) + 0.5);
    if (tempF.size.width < [UIScreen mainScreen].bounds.size.width){
        tempF.size.width = [UIScreen mainScreen].bounds.size.width;
    }
    
    if ((currentPage < [self.dataSource photoBrowser:self numberOfItemsInSection:self.currentIndexPath.section] - 1) || self.photos.count == 1) {
        tempF.origin.x = 0;
    }else{
        tempF.origin.x = -ZLPickerColletionViewPadding;
    }
    self.collectionView.frame = tempF;
}

-(void)setPageLabelPage:(NSInteger)page{
    self.pageLabel.text = [NSString stringWithFormat:@"%ld / %ld",page + 1, self.photos.count];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    NSInteger currentPage = (NSInteger)scrollView.contentOffset.x / (scrollView.width - ZLPickerColletionViewPadding);
    
    if (currentPage == self.photos.count - 1 && currentPage != self.currentPage && [[[UIDevice currentDevice] systemVersion] doubleValue] >= 8.0) {
        self.collectionView.contentOffset = CGPointMake(self.collectionView.contentOffset.x + ZLPickerColletionViewPadding, 0);
    }
    
    self.currentPage = currentPage;
    [self setPageLabelPage:currentPage];
    
    if ([self.delegate respondsToSelector:@selector(photoBrowser:didCurrentPage:)]) {
        [self.delegate photoBrowser:self didCurrentPage:self.currentPage];
    }
    
}

#pragma mark - 展示控制器
- (void)show{
    BOOL animation = !self.toView;
    if (animation) {
        [[[[UIApplication sharedApplication] windows] lastObject] presentViewController:self animated:animation completion:nil];
    }else{
        [[self getParsentViewController:self.toView] presentViewController:self animated:animation completion:nil];
    }
}

#pragma mark - 删除照片
- (void) delete{
    
    // 准备删除
    if ([self.delegate respondsToSelector:@selector(photoBrowser:willRemovePhotoAtIndexPath:)]) {
        if(![self.delegate photoBrowser:self willRemovePhotoAtIndexPath:[NSIndexPath indexPathForItem:self.currentPage inSection:self.currentIndexPath.section]]){
            return ;
        }
    }
    
    UIAlertView *removeAlert = [[UIAlertView alloc]
                                initWithTitle:@"确定要删除此图片？"
                                message:nil
                                delegate:self
                                cancelButtonTitle:@"取消"
                                otherButtonTitles:@"确定", nil];
    [removeAlert show];
}

#pragma mark - <UIAlertViewDelegate>
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        NSInteger page = self.currentPage;
        if ([self.delegate respondsToSelector:@selector(photoBrowser:removePhotoAtIndexPath:)]) {
            [self.delegate photoBrowser:self removePhotoAtIndexPath:[NSIndexPath indexPathForItem:page inSection:self.currentIndexPath.section]];
        }
        
        [self.photos removeObjectAtIndex:self.currentPage];
        
        if (self.currentPage >= self.photos.count) {
            self.currentPage--;
        }
        
        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:page inSection:self.currentIndexPath.section]];
        if (cell) {
            if([[[cell.contentView subviews] lastObject] isKindOfClass:[UIView class]]){
                
                [UIView animateWithDuration:.35 animations:^{
                    [[[cell.contentView subviews] lastObject] setAlpha:0.0];
                } completion:^(BOOL finished) {
                    [self reloadData];
                }];
            }
        }
        
        if (self.photos.count < 1)
        {
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            [self dismissViewControllerAnimated:YES completion:nil];
            [[UIApplication sharedApplication] setStatusBarHidden:NO];
        }
    }
}

#pragma mark - <PickerPhotoScrollViewDelegate>
- (void)pickerPhotoScrollViewDidSingleClick:(ZLPhotoPickerBrowserPhotoScrollView *)photoScrollView{
    if (self.disMissBlock) {
        
        if (self.photos.count == 1) {
            self.currentPage = 0;
        }
        self.disMissBlock(self.currentPage);
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - showHeadPortrait 放大缩小一张图片的情况下（查看头像）
- (void)showHeadPortrait:(UIImageView *)toImageView{
    [self showHeadPortrait:toImageView originUrl:nil];
}

- (void)showHeadPortrait:(UIImageView *)toImageView originUrl:(NSString *)originUrl{
    UIView *mainView = [[UIView alloc] init];
    mainView.backgroundColor = [UIColor blackColor];
    mainView.frame = [UIScreen mainScreen].bounds;
    [[UIApplication sharedApplication].keyWindow addSubview:mainView];
    
    CGRect tempF = [toImageView.superview convertRect:toImageView.frame toView:[self getParsentView:toImageView]];
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.userInteractionEnabled = YES;
    imageView.frame = tempF;
    imageView.image = toImageView.image;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [mainView addSubview:imageView];
    mainView.clipsToBounds = YES;
    
    [UIView animateWithDuration:.25 animations:^{
        imageView.frame = [UIScreen mainScreen].bounds;
    } completion:^(BOOL finished) {
        imageView.hidden = YES;
        
        ZLPhotoPickerBrowserPhoto *photo = [[ZLPhotoPickerBrowserPhoto alloc] init];
        photo.photoURL = [NSURL URLWithString:originUrl];
        photo.photoImage = toImageView.image;
        photo.thumbImage = toImageView.image;
        
        ZLPhotoPickerBrowserPhotoScrollView *scrollView = [[ZLPhotoPickerBrowserPhotoScrollView alloc] init];
        
        __weak typeof(ZLPhotoPickerBrowserPhotoScrollView *)weakScrollView = scrollView;
        scrollView.callback = ^(id obj){
            [weakScrollView removeFromSuperview];
            mainView.backgroundColor = [UIColor clearColor];
            imageView.hidden = NO;
            [UIView animateWithDuration:.25 animations:^{
                imageView.frame = tempF;
            } completion:^(BOOL finished) {
                [mainView removeFromSuperview];
            }];
        };
        scrollView.frame = [UIScreen mainScreen].bounds;
        scrollView.photo = photo;
        [mainView addSubview:scrollView];
    }];
}

@end