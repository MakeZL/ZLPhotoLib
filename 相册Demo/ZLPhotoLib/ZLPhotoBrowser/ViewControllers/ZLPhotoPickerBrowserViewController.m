//
//  ZLPhotoPickerBrowserViewController.m
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 14-11-14.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import "ZLPhotoPickerBrowserViewController.h"
#import "ZLPhotoPickerBrowserPhoto.h"
#import "ZLPhotoPickerDatas.h"
#import "UIView+Extension.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "ZLPhotoPickerBrowserPhotoScrollView.h"
#import "ZLPhotoPickerCommon.h"
#import "ZLAnimationScrollView.h"
#import <objc/runtime.h>
#import "UIView+ZLAutoLayout.h"

static NSString *_cellIdentifier = @"collectionViewCell";

@interface ZLPhotoPickerBrowserViewController () <UIScrollViewDelegate,ZLPhotoPickerPhotoScrollViewDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,UICollectionViewDelegate>
// 自定义控件
@property (nonatomic , weak) UIPageControl *pageCtrl;
@property (nonatomic , weak) UIButton *deleleBtn;
@property (nonatomic , weak) UICollectionView *collectionView;
//@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
// 单击时执行销毁的block
@property (nonatomic , copy) ZLPickerBrowserViewControllerTapDisMissBlock disMissBlock;
// 装着所有的图片模型
@property (nonatomic , strong) NSMutableArray *photos;

@property (strong,nonatomic) UICollectionViewFlowLayout *flowLayout;

@property (nonatomic , assign) UIDeviceOrientation orientation;
@property (assign,nonatomic) BOOL isDelete;
@property (assign,nonatomic) BOOL isLoadScrollView;

@end


@implementation ZLPhotoPickerBrowserViewController

#pragma mark - getter
- (NSMutableArray *)photos{
    if (!_photos) {
        _photos = [NSMutableArray array];
        [_photos addObjectsFromArray:[self getPhotos]];
    }
    return _photos;
}


- (UICollectionView *)collectionView{
    if (!_collectionView) {
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.minimumLineSpacing = ZLPickerColletionViewPadding;
        flowLayout.itemSize = self.view.size;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.flowLayout = flowLayout;
        
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
        
        self.pageCtrl.numberOfPages = [self.dataSource numberOfPhotosInPickerBrowser:self];
        self.pageCtrl.currentPage = self.currentPage;
        self.pageCtrl.hidden =  [self.dataSource numberOfPhotosInPickerBrowser:self] <= 1;
        self.deleleBtn.hidden = !self.isEditing;
    }
    return _collectionView;
}

//- (UIScrollView *)scrollView{
//    if (!_scrollView) {
//        self.scrollView = [[UIScrollView alloc] init];
//        self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//        self.scrollView.delegate = self;
//        self.scrollView.frame = self.view.frame;
//        self.scrollView.backgroundColor = [UIColor clearColor];
//        self.scrollView.pagingEnabled = YES;
//        self.scrollView.showsHorizontalScrollIndicator = NO;
//        self.scrollView.showsVerticalScrollIndicator = NO;
//        [self.view addSubview:_scrollView];
//        
//        self.scrollView.width += ZLPickerColletionViewPadding;
//        
//        for (NSInteger i = 0; i < [self.dataSource numberOfPhotosInPickerBrowser:self]; i++) {
//            ZLPhotoPickerBrowserPhoto *photo = self.photos[i];
//            ZLPhotoPickerBrowserPhotoScrollView *scrollView =  [ZLPhotoPickerBrowserPhotoScrollView instanceAutoLayoutView];
//            scrollView.backgroundColor = [UIColor clearColor];
//            // 为了监听单击photoView事件
//            
//            scrollView.frame = CGRectMake(_scrollView.frame.size.width * i, 0, self.view.frame.size.width, self.view.frame.size.height);
//            scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
//            scrollView.photoScrollViewDelegate = self;
//            scrollView.photo = photo;
//            [_scrollView addSubview:scrollView];
//        }
//
//        self.deleleBtn.hidden = !self.isEditing;
//    }
//    return _scrollView;
//}


//- (void)viewWillLayoutSubviews{
//    
//    
//    if (self.isLoadScrollView) {
//        self.scrollView.contentSize = CGSizeMake([self.dataSource numberOfPhotosInPickerBrowser:self] * self.scrollView.width, 0);
//        for (NSInteger i = 0; i < [self.dataSource numberOfPhotosInPickerBrowser:self]; i++) {
//            ZLPhotoPickerBrowserPhotoScrollView *imageView = (ZLPhotoPickerBrowserPhotoScrollView *)[self.scrollView subviews][i];
//            imageView.frame = CGRectMake(i * self.scrollView.width - ZLPickerColletionViewPadding / 2, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
//            
//        }
//        
//        [_scrollView setContentOffset:CGPointMake(self.scrollView.width * [self currentPage], 0)];
//    }
//    [super viewWillLayoutSubviews];
//    
//}

#pragma mark -删除按钮
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
        NSDictionary *metrics = @{@"deleteBtnWH":@(30),@"margin":@(10)};
        NSDictionary *views = NSDictionaryOfVariableBindings(deleleBtn);
        
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:widthVfl options:0 metrics:metrics views:views]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:heightVfl options:0 metrics:metrics views:views]];
        
    }
    return _deleleBtn;
}

#pragma mark - 分页控件
- (UIPageControl *)pageCtrl{
    if (!_pageCtrl) {
        
        UIPageControl *pageCtrl = [[UIPageControl alloc] init];
        pageCtrl.userInteractionEnabled = NO;
        pageCtrl.translatesAutoresizingMaskIntoConstraints = NO;
        pageCtrl.currentPageIndicatorTintColor = [UIColor whiteColor];
        pageCtrl.pageIndicatorTintColor = [UIColor lightGrayColor];
        [self.view addSubview:pageCtrl];
        self.pageCtrl = pageCtrl;
        
        NSString *widthVfl = @"H:|-0-[pageCtrl]-0-|";
        NSString *heightVfl = @"V:[pageCtrl(ZLPickerPageCtrlH)]-20-|";
        NSDictionary *views = NSDictionaryOfVariableBindings(pageCtrl);
        NSDictionary *metrics = @{@"ZLPickerPageCtrlH":@(ZLPickerPageCtrlH)};
        
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:widthVfl options:0 metrics:metrics views:views]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:heightVfl options:0 metrics:metrics views:views]];
        
    }
    return _pageCtrl;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    NSAssert(self.dataSource, @"你没成为数据源代理");
    
    [self collectionView];
    // 初始化动画
    [self startLogddingAnimation];
    
}

#pragma mark - 获取父View
- (UIView *)getParsentView:(UIView *)view{
    if ([[view nextResponder] isKindOfClass:[UIViewController class]] || view == nil) {
        return view;
    }
    return [self getParsentView:view.superview];
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
    
    NSDictionary *options = @{
                              UIViewAnimationInView:self.view,
                              UIViewAnimationFromView:fromView,
                              UIViewAnimationAnimationStatusType:@(self.status),
                              UIViewAnimationToView:self.toView,
                              UIViewAnimationFromView:self.dataSource,
                              UIViewAnimationImages:self.photos,
                              UIViewAnimationTypeViewWithIndexPath:[NSIndexPath indexPathForRow:self.currentPage inSection:0]
                              };
    
    __weak typeof(self) weakSelf = self;
    
    [ZLAnimationScrollView animationViewWithOptions:options animations:^{
        
    } completion:^(ZLAnimationBaseView *baseView) {
        if (!weakSelf.isLoadScrollView){
            weakSelf.isLoadScrollView = YES;
        }
        // disMiss后调用
        weakSelf.disMissBlock = ^(NSInteger page){
            [ZLAnimationScrollView setCurrentPage:page];
            [weakSelf dismissViewControllerAnimated:NO completion:nil];
            [ZLAnimationScrollView restoreAnimation:^{
                //                NSLog(@"动画执行完...");
            }];
        };
        [weakSelf reloadData];
    }];
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 隐藏状态栏
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    self.view.backgroundColor = [UIColor blackColor];
}

#pragma mark -刷新表格

#pragma mark -刷新表格
- (void) reloadData{
    
    self.collectionView.dataSource = self;
    [self.collectionView reloadData];
    
    self.pageCtrl.numberOfPages = self.photos.count;
    if (self.currentPage >= 0) {
        CGFloat attachVal = 0;
        if (self.currentPage == [self.dataSource numberOfPhotosInPickerBrowser:self]-1 && self.currentPage > 0) {
            attachVal = ZLPickerColletionViewPadding;
        }
        
        self.collectionView.x = -attachVal;
        self.collectionView.contentOffset = CGPointMake(self.currentPage * self.collectionView.width, 0);
    }
    
}


#pragma mark -<UICollectionViewDataSource>
- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.dataSource numberOfPhotosInPickerBrowser:self];
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:_cellIdentifier forIndexPath:indexPath];
    
    if (self.photos.count) {
        if (collectionView.isDragging || self.currentPage == indexPath.row || (self.isDelete && self.currentPage - 1 == indexPath.row)) {
            cell.hidden = NO;
        }else{
            cell.hidden = YES;
        }
        cell.backgroundColor = [UIColor clearColor];
        ZLPhotoPickerBrowserPhoto *photo = self.photos[indexPath.item]; //[self.dataSource photoBrowser:self photoAtIndex:indexPath.item];
        
        if([[cell.contentView.subviews lastObject] isKindOfClass:[ZLPhotoPickerBrowserPhotoScrollView class]]){
            [[cell.contentView.subviews lastObject] removeFromSuperview];
        }
        
        ZLPhotoPickerBrowserPhotoScrollView *scrollView =  [ZLPhotoPickerBrowserPhotoScrollView instanceAutoLayoutView];
        scrollView.backgroundColor = [UIColor clearColor];
        // 为了监听单击photoView事件
        scrollView.frame = cell.bounds;
        scrollView.photoScrollViewDelegate = self;
        [cell.contentView addSubview:scrollView];
        scrollView.photo = photo;
        
        [scrollView autoEqualToSuperViewAutoLayouts];
    }
    
    return cell;
}


/**
 *  获取所有的图片
 */
- (NSArray *) getPhotos{
    NSMutableArray *photos = [NSMutableArray array];
    NSInteger count = [self.dataSource numberOfPhotosInPickerBrowser:self];
    for (NSInteger i = 0; i < count; i++) {
        [photos addObject:[self.dataSource photoBrowser:self photoAtIndex:i]];
    }
    
    return photos;
}

#pragma mark - <UIScrollViewDelegate>


#pragma mark - <UIScrollViewDelegate>
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGRect tempF = self.collectionView.frame;
    NSInteger currentPage = (NSInteger)((scrollView.contentOffset.x / scrollView.width) + 0.5);
    
    if ((currentPage < [self.dataSource numberOfPhotosInPickerBrowser:self] - 1) || self.photos.count == 1) {
        tempF.origin.x = 0;
    }else{
        tempF.origin.x = -ZLPickerColletionViewPadding;
    }
    
    self.collectionView.frame = tempF;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    [[self.collectionView visibleCells] enumerateObjectsUsingBlock:^(UICollectionViewCell *cell, NSUInteger idx, BOOL *stop) {
        if (cell.isHidden && idx != self.currentPage) {
            // 取消cell的隐藏
            cell.hidden = YES;
        }
    }];
    
    self.currentPage = (NSInteger)(scrollView.contentOffset.x / (scrollView.width - ZLPickerColletionViewPadding));
    self.pageCtrl.currentPage = self.currentPage;
    
    if ([self.delegate respondsToSelector:@selector(photoBrowser:didCurrentPage:)]) {
        [self.delegate photoBrowser:self didCurrentPage:self.currentPage];
    }
    
}


#pragma mark - 展示控制器
- (void)show{
    BOOL animation = !self.toView;
    [[[[[UIApplication sharedApplication] windows] firstObject] rootViewController] presentViewController:self animated:animation completion:nil];
}

#pragma mark - 删除照片
- (void) delete{
    
    // 准备删除
    if ([self.delegate respondsToSelector:@selector(photoBrowser:willRemovePhotoAtIndex:)]) {
        if(![self.delegate photoBrowser:self willRemovePhotoAtIndex:self.currentPage]){
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
        if ([self.delegate respondsToSelector:@selector(photoBrowser:removePhotoAtIndex:)]) {
            [self.delegate photoBrowser:self removePhotoAtIndex:page];
        }
        
        self.isDelete = YES;
        [self.photos removeObjectAtIndex:self.currentPage];
        
        if (self.currentPage >= self.photos.count) {
            self.currentPage--;
        }
        
        [self reloadData];
        
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

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end