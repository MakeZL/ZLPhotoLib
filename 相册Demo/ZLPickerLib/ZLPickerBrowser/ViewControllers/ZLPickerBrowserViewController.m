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
#import "ZLBaseAnimationImageView.h"
#import "ZLPickerCommon.h"

static NSString *_cellIdentifier = @"collectionViewCell";

@interface ZLPickerBrowserViewController () <UIScrollViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate,PickerPhotoScrollViewDelegate>

@property (nonatomic , weak) UIPageControl *pageCtrl;
@property (nonatomic , weak) UIButton *deleleBtn;
@property (nonatomic , weak) UICollectionView *collectionView;
// 单击时执行的block
@property (nonatomic , copy) ZLPickerBrowserViewControllerTapDisMissBlock disMissBlock;

@end


@implementation ZLPickerBrowserViewController

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
    }
    return _collectionView;
}

#pragma mark -删除按钮
- (UIButton *)deleleBtn{
    if (!_deleleBtn) {
        UIButton *deleleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat deleleBtnW = 50;
        CGFloat deleleBtnX = self.view.width - deleleBtnW;
        CGFloat deleleBtnY = 20;
        CGFloat deleleBtnH = deleleBtnW;
        deleleBtn.frame = CGRectMake(deleleBtnX, deleleBtnY, deleleBtnW, deleleBtnH);
        deleleBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [deleleBtn setTitle:@"删除" forState:UIControlStateNormal];
        [deleleBtn addTarget:self action:@selector(delete) forControlEvents:UIControlEventTouchUpInside];
        deleleBtn.hidden = YES;
        [self.view addSubview:deleleBtn];
        self.deleleBtn = deleleBtn;
    }
    return _deleleBtn;
}

#pragma mark -分页控件
- (UIPageControl *)pageCtrl{
    if (!_pageCtrl) {
        UIPageControl *pageCtrl = [[UIPageControl alloc] init];
        pageCtrl.userInteractionEnabled = NO;
        pageCtrl.frame = CGRectMake(0, self.view.height - ZLPickerPageCtrlH, self.view.width, ZLPickerPageCtrlH);
        pageCtrl.currentPageIndicatorTintColor = [UIColor whiteColor];
        pageCtrl.pageIndicatorTintColor = [UIColor lightGrayColor];
        [self.view addSubview:pageCtrl];
        self.pageCtrl = pageCtrl;
    }
    return _pageCtrl;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    // 初始化collectionView
    [self collectionView];
    
    // 开始动画
    [self startLogddingAnimation];
}

// 开始动画
- (void)startLogddingAnimation{
    NSDictionary *options = @{
                              UIViewAnimationFromView:self.fromView,
                              UIViewAnimationInView:self.view,
                              UIViewAnimationToView:self.toView,
                              UIViewAnimationScrollDirection:@(self.scrollDirection),
                              UIViewAnimationImages:[self getPhotos],
                              UIViewAnimationTypeViewWithIndexPath:[NSIndexPath indexPathForRow:self.currentPage inSection:0]
                              };
    
    __weak typeof(self) weakSelf = self;
    [ZLBaseAnimationImageView animationViewWithOptions:options completion:^(ZLBaseAnimationView *baseView) {
        // disMiss后调用
        weakSelf.disMissBlock = ^(NSInteger page){
            baseView.currentPage = page;
            [weakSelf dismissViewControllerAnimated:NO completion:nil];
            [baseView viewformIdentity:^(ZLBaseAnimationView *baseView) {
                
            }];
        };
        
        [weakSelf reloadData];
    }];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
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
    
    ZLPickerBrowserPhoto *photo = [self.dataSource photoBrowser:self photoAtIndex:indexPath.item];
    
    ZLPickerBrowserPhotoScrollView *scrollView = [cell.contentView.subviews lastObject];
    if (![scrollView isKindOfClass:[ZLPickerBrowserPhotoScrollView class]]) {
        scrollView = [[ZLPickerBrowserPhotoScrollView alloc] init];
        // 为了监听单击photoView事件
        scrollView.frame = cell.bounds;
        scrollView.photoScrollViewDelegate = self;
        [cell.contentView addSubview:scrollView];
        
    }
    
    scrollView.photo = photo;
    
    return cell;
    
}

#pragma mark -刷新表格
- (void) reloadData{
    
    self.collectionView.dataSource = self;
    [self.collectionView reloadData];
    
    if (self.currentPage >= 0) {
        CGFloat attachVal = 0;
        if (self.currentPage == [self.dataSource numberOfPhotosInPickerBrowser:self]-1 && self.currentPage > 0) {
            attachVal = ZLPickerColletionViewPadding;
        }
        
        self.collectionView.x = -attachVal;
        self.collectionView.contentOffset = CGPointMake(self.currentPage * self.collectionView.width, 0);
        
    }
    self.pageCtrl.numberOfPages = [self.dataSource numberOfPhotosInPickerBrowser:self];
    self.pageCtrl.currentPage = self.currentPage;
    self.deleleBtn.hidden = !self.isEditing;
    
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

#pragma mark -<UIScrollViewDelegate>
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    self.currentPage = (NSInteger)((scrollView.contentOffset.x / scrollView.width) + 0.5);
    
    self.pageCtrl.currentPage = self.currentPage;
 
    CGRect tempF = self.collectionView.frame;
    if (self.currentPage < [self.dataSource numberOfPhotosInPickerBrowser:self] - 1) {
        tempF.origin.x = 0
        ;
    }else{
        tempF.origin.x = -ZLPickerColletionViewPadding;
    }
    self.collectionView.frame = tempF;
}


#pragma mark -删除照片
- (void) delete{
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
        [self reloadData];
    }
}


#pragma mark -<PickerPhotoScrollViewDelegate>
- (void)pickerPhotoScrollViewDidSingleClick:(ZLPickerBrowserPhotoScrollView *)photoScrollView{
    if (self.disMissBlock) {
        self.disMissBlock(self.currentPage);
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
@end