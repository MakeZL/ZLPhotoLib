//
//  PickerBrowserViewController.m
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 14-11-14.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import "ZLPickerBrowserViewController.h"
#import "ZLPickerBrowserPhoto.h"
#import "ZLPickerDatas.h"
#import "UIView+Extension.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "ZLPickerBrowserPhotoScrollView.h"
#import "ZLPickerCommon.h"
#import "ZLAnimationScrollView.h"
//#import "ZLBaseAnimationImageView.h"
#import <objc/runtime.h>
#import "UIView+ZLAutoLayout.h"

static NSString *_cellIdentifier = @"collectionViewCell";

@interface ZLPickerBrowserViewController () <UIScrollViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate,PickerPhotoScrollViewDelegate,UICollectionViewDelegateFlowLayout>
// 自定义控件
@property (nonatomic , weak) UIPageControl *pageCtrl;
@property (nonatomic , weak) UIButton *deleleBtn;
@property (nonatomic , weak) UICollectionView *collectionView;
// 单击时执行销毁的block
@property (nonatomic , copy) ZLPickerBrowserViewControllerTapDisMissBlock disMissBlock;
// 装着所有的图片模型
@property (nonatomic , strong) NSMutableArray *photos;

@property (strong,nonatomic) UICollectionViewFlowLayout *flowLayout;

@property (nonatomic , assign) UIDeviceOrientation orientation;


@end


@implementation ZLPickerBrowserViewController

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
        self.deleleBtn.hidden = !self.isEditing;
    }
    return _collectionView;
}

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

#pragma mark -分页控件
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
    
    // 初始化collectionView
    [self collectionView];
    
    // 开始动画
    [self startLogddingAnimation];
    
}

#pragma mark - 获取父View
- (UIView *)getParsentView:(UIView *)view{
    if ([[view nextResponder] isKindOfClass:[UIViewController class]] || view == nil) {
        return view;
    }
    return [self getParsentView:view.superview];
}

// 开始动画
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
                              UIViewAnimationAnimationStatusType:@(0),
                              UIViewAnimationToView:self.toView,
                              UIViewAnimationFromView:self.dataSource,
                              UIViewAnimationImages:self.photos,
                              UIViewAnimationTypeViewWithIndexPath:[NSIndexPath indexPathForRow:self.currentPage inSection:0]
                              };
    
    __weak typeof(self) weakSelf = self;
    
    [ZLAnimationScrollView animationViewWithOptions:options animations:^{
        
    } completion:^(ZLAnimationBaseView *baseView) {
        // disMiss后调用
        weakSelf.disMissBlock = ^(NSInteger page){
            [ZLAnimationScrollView setCurrentPage:page];
            [weakSelf dismissViewControllerAnimated:NO completion:nil];
            [ZLAnimationScrollView restoreAnimation:^{
                NSLog(@"---");
            }];
        };
        [weakSelf reloadData];
    }];
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 隐藏状态栏
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    self.view.backgroundColor = [UIColor blackColor];
    
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = UIInterfaceOrientationPortrait;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
    
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter]; //Get the notification centre for the app
    [nc addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification  object:nil];
}

- (void)orientationChanged:(NSNotification *)noti{
    UIDevice *device = noti.object;
    self.orientation = device.orientation;
        [self.collectionView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    CGFloat attchValue = self.currentPage > 0 ? ZLPickerColletionViewPadding : ZLPickerColletionViewPadding;
    
    self.collectionView.contentSize = CGSizeMake(self.photos.count * self.collectionView.width, 0);
    [self.collectionView reloadData];
    [self.collectionView setContentOffset:CGPointMake(self.currentPage * self.view.width + attchValue, 0)];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    CGSize size = self.flowLayout.itemSize;
    if (self.orientation == UIDeviceOrientationPortrait || self.orientation == UIDeviceOrientationPortraitUpsideDown) {
        size = CGSizeMake(self.collectionView.frame.size.width, self.view.frame.size.height);
        size.width -= ZLPickerColletionViewPadding;
    }else if (self.orientation == UIDeviceOrientationLandscapeLeft || self.orientation == UIDeviceOrientationLandscapeRight){
        size = self.view.frame.size;
    }
    
    return size;
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
    
    cell.hidden = !(self.currentPage == indexPath.row);
    cell.backgroundColor = [UIColor clearColor];
    ZLPickerBrowserPhoto *photo = self.photos[indexPath.item]; //[self.dataSource photoBrowser:self photoAtIndex:indexPath.item];

    if([[cell.contentView.subviews lastObject] isKindOfClass:[ZLPickerBrowserPhotoScrollView class]]){
        [[cell.contentView.subviews lastObject] removeFromSuperview];
    }
    
//    NSLog(@"%@", NSStringFromCGRect(cell.bounds));
    
    ZLPickerBrowserPhotoScrollView *scrollView =  [ZLPickerBrowserPhotoScrollView instanceAutoLayoutView];//[[ alloc] init];
    scrollView.backgroundColor = [UIColor clearColor];
    // 为了监听单击photoView事件
    scrollView.frame = cell.bounds;
    scrollView.photoScrollViewDelegate = self;
    [cell.contentView addSubview:scrollView];
    scrollView.photo = photo;
    
    [scrollView autoEqualToSuperViewAutoLayouts];
    return cell;
    
}

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

- (BOOL)shouldAutorotate{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return YES;
}


//#pragma mark -<UIScrollViewDelegate>
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    [[self.collectionView visibleCells] enumerateObjectsUsingBlock:^(UICollectionViewCell *cell, NSUInteger idx, BOOL *stop) {
        if (cell.isHidden) {
            // 取消cell的隐藏
            cell.hidden = NO;
        }
    }];
    
    NSInteger currentPage = (NSInteger)((scrollView.contentOffset.x / scrollView.width) + 0.5);
    
    CGRect tempF = self.collectionView.frame;
    if ((currentPage < [self.dataSource numberOfPhotosInPickerBrowser:self] - 1) || self.photos.count == 1) {
        tempF.origin.x = 0;
    }else{
        tempF.origin.x = -ZLPickerColletionViewPadding;
    }
    
    self.collectionView.frame = tempF;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    self.currentPage = (NSInteger)(scrollView.contentOffset.x / (scrollView.width - ZLPickerColletionViewPadding));
    self.pageCtrl.currentPage = self.currentPage;
    
    if ([self.delegate respondsToSelector:@selector(photoBrowser:didCurrentPage:)]) {
        [self.delegate photoBrowser:self didCurrentPage:self.currentPage];
    }
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if ([self.delegate respondsToSelector:@selector(photoBrowser:willCurrentPage:)]) {
        [self.delegate photoBrowser:self willCurrentPage:self.currentPage];
    }
}

#pragma mark - 展示控制器
- (void)show{
    [[[UIApplication sharedApplication].keyWindow rootViewController] presentViewController:self animated:NO completion:nil];
}


#pragma mark -删除照片
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

#pragma mark -<UIAlertViewDelegate>
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        if ([self.delegate respondsToSelector:@selector(photoBrowser:removePhotoAtIndex:)]) {
            [self.delegate photoBrowser:self removePhotoAtIndex:self.currentPage];
        }
        
        [self.photos removeObjectAtIndex:self.currentPage];
        [self reloadData];
        
        if (self.photos.count < 1)
        {
            [self dismissViewControllerAnimated:NO completion:nil];
            [[UIApplication sharedApplication] setStatusBarHidden:NO];
        }
    }
}


#pragma mark -<PickerPhotoScrollViewDelegate>
- (void)pickerPhotoScrollViewDidSingleClick:(ZLPickerBrowserPhotoScrollView *)photoScrollView{
    if (self.disMissBlock) {
        self.disMissBlock(self.currentPage);
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end