//
//  PickerBrowserViewController.m
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 14-11-14.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import "PickerBrowserViewController.h"
#import "PickerPhoto.h"
#import "PickerDatas.h"
#import "PickerPhotosView.h"
#import "UIView+Extension.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "PickerPhotoScrollView.h"
#import "PickerCommon.h"

@interface PickerBrowserViewController () <UIScrollViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate,PickerPhotoScrollViewDelegate>

@property (nonatomic , weak) UIPageControl *pageCtrl;
@property (nonatomic , weak) UIButton *deleleBtn;
@property (nonatomic , weak) PickerPhotosView *collectionView;

@end


@implementation PickerBrowserViewController

- (PickerPhotosView *)collectionView{
    if (!_collectionView) {
        
        PickerPhotosView *collectionView = [[PickerPhotosView alloc] initWithFrame:CGRectMake(0, 0, self.view.width + PADDING,self.view.height) collectionViewLayout:nil];
        collectionView.maximumZoomScale = maxZoomScale;
        collectionView.minimumZoomScale = minZoomScale;
        collectionView.bouncesZoom = YES;
        collectionView.dataSource = self;
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
        pageCtrl.frame = CGRectMake(0, self.view.height - pageCtrlH, self.view.width, pageCtrlH);
        pageCtrl.currentPageIndicatorTintColor = [UIColor whiteColor];
        pageCtrl.pageIndicatorTintColor = [UIColor lightGrayColor];
        [self.view addSubview:pageCtrl];
        self.pageCtrl = pageCtrl;
    }
    return _pageCtrl;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 刷新数据
    [self reloadData];
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
    
    PickerPhoto *photo = [self.dataSource photoBrowser:self photoAtIndex:indexPath.item];
    
    PickerPhotoScrollView *scrollView = [cell.contentView.subviews lastObject];
    if (![scrollView isKindOfClass:[PickerPhotoScrollView class]]) {
        scrollView = [[PickerPhotoScrollView alloc] init];
        // 为了监听单击photoView事件
        scrollView.photoScrollViewDelegate = self;
        [cell.contentView addSubview:scrollView];
        
        scrollView.frame = cell.bounds;
    }
    scrollView.photo = photo;
    
    return cell;
    
}

#pragma mark -刷新表格
- (void) reloadData{
    // 计算控件
    [self.collectionView reloadData];
    
    if (self.currentPage) {
        CGFloat attachVal = 0;
        if (self.currentPage == [self.dataSource numberOfPhotosInPickerBrowser:self]-1) {
            attachVal = PADDING;
        }
        
        self.collectionView.x = -attachVal;
        self.collectionView.contentOffset = CGPointMake(self.currentPage * self.collectionView.width, 0);
    }
    self.pageCtrl.numberOfPages = [self.dataSource numberOfPhotosInPickerBrowser:self];
    self.pageCtrl.currentPage = self.currentPage;
    self.deleleBtn.hidden = !self.isEditing;
    
}

#pragma mark -<UIScrollViewDelegate>
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    self.currentPage = (NSInteger)((scrollView.contentOffset.x / scrollView.width) + 0.5);
    
    self.pageCtrl.currentPage = self.currentPage;

}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (self.currentPage == [self.dataSource numberOfPhotosInPickerBrowser:self] - 1 &&
        scrollView.contentOffset.x + scrollView.width <= scrollView.contentSize.width &&
        scrollView.contentOffset.x >= 0
        ) {
        self.collectionView.x = -PADDING;
    }else{
        self.collectionView.x = 0;
    }
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    // 如果已经切换了幻灯片就恢复最原始的比例
    NSInteger count = [self.dataSource numberOfPhotosInPickerBrowser:self];
    
    
    for (int i = 0; i < count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
        if (scrollView.contentOffset.x / scrollView.width != self.currentPage &&
            scrollView.contentOffset.x >= 0 &&
            scrollView.contentOffset.x + scrollView.width <= scrollView.contentSize.width
            ) {
            PickerPhotoScrollView *scView = [cell.contentView.subviews lastObject];
            if (scView.zoomScale != 1.0) {
                [scView setZoomScale:1.0 animated:YES];
            }
        }
    }
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
- (void)pickerPhotoScrollViewDidSingleClick:(PickerPhotoScrollView *)photoScrollView{
    if (self.disMissBlock) {
        self.disMissBlock(self.currentPage);
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
@end
