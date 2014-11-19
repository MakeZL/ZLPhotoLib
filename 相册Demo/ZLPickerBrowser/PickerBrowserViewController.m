//
//  PickerBrowserViewController.m
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 14-11-14.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import "PickerBrowserViewController.h"
#import "PickerPhoto.h"
#import "SDWebImageDownloader.h"
#import "PickerDatas.h"
#import "PickerPhotosView.h"
#import "UIView+Extension.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "PickerPhotoScrollView.h"

@interface PickerBrowserViewController () <UIScrollViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate,PickerPhotoScrollViewDelegate>

//@property (nonatomic , weak) UIScrollView *scrollView;
@property (nonatomic , strong) UIPageControl *pageCtrl;
@property (nonatomic , weak) UIButton *deleleBtn;

@property (nonatomic , weak) PickerPhotosView *collectionView;

@end

static NSString *_cellIdentifier = @"collectionViewCell";

@implementation PickerBrowserViewController

#pragma mark -getter
//- (UIScrollView *)scrollView{
//    if (!_scrollView) {
//        UIScrollView *scrollView = [[UIScrollView alloc] init];
//        scrollView.delegate = self;
//        scrollView.minimumZoomScale = 1.0;
//        scrollView.maximumZoomScale = 2.0;
//        scrollView.showsVerticalScrollIndicator = NO;
//        scrollView.showsHorizontalScrollIndicator = NO;
//        scrollView.bouncesZoom = YES;
//        scrollView.frame = self.view.bounds;
//        scrollView.pagingEnabled = YES;
//        [self.view addSubview:scrollView];
//        self.scrollView = scrollView;
//    }
//    return _scrollView;
//}

- (PickerPhotosView *)collectionView{
    if (!_collectionView) {
        
        PickerPhotosView *collectionView = [[PickerPhotosView alloc] initWithFrame:CGRectMake(0, 0, self.view.width + 20,self.view.height) collectionViewLayout:nil];
        collectionView.maximumZoomScale = 2.5;
        collectionView.minimumZoomScale = 1.0;
        collectionView.bouncesZoom = YES;
        collectionView.dataSource = self;
        collectionView.delegate = self;
        [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:_cellIdentifier];

        [self.view addSubview:collectionView];
        self.collectionView = collectionView;
    }
    return _collectionView;
}

- (UIButton *)deleleBtn{
    if (!_deleleBtn) {
        UIButton *deleleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat deleleBtnW = 50;
        CGFloat deleleBtnX = self.view.width - deleleBtnW;
        CGFloat deleleBtnY = 0;
        CGFloat deleleBtnH = deleleBtnW;
        deleleBtn.frame = CGRectMake(deleleBtnX, deleleBtnY, deleleBtnW, deleleBtnH);
        [deleleBtn setTitle:@"删除" forState:UIControlStateNormal];
        [deleleBtn addTarget:self action:@selector(delete) forControlEvents:UIControlEventTouchUpInside];
        deleleBtn.hidden = YES;
        [self.view addSubview:deleleBtn];
        self.deleleBtn = deleleBtn;
    }
    return _deleleBtn;
}


- (UIPageControl *)pageCtrl{
    if (!_pageCtrl) {
        UIPageControl *pageCtrl = [[UIPageControl alloc] init];
        CGFloat pageCtrlH = 44;
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
    
    // 监听手势
//    [self addGesture];
    
    // 刷新数据
    [self reloadData];
}

#pragma mark -监听手势
- (void) addGesture{
    
    // 双击放大
//    UITapGestureRecognizer *scaleBigTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scaleBigTap:)];
//    scaleBigTap.numberOfTapsRequired = 2;
//    scaleBigTap.numberOfTouchesRequired = 1;
//    [self.view addGestureRecognizer:scaleBigTap];
    // 单击缩小
//    UITapGestureRecognizer *disMissTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(disMissTap:)];
//    disMissTap.numberOfTapsRequired = 1;
//    disMissTap.numberOfTouchesRequired = 1;
//    [self.view addGestureRecognizer:disMissTap];
//    // 只能有一个手势存在
//    [disMissTap requireGestureRecognizerToFail:scaleBigTap];
}

//- (void) scaleBigTap:(UITapGestureRecognizer *)tap{
//    if(self.currentPage > [self.dataSource numberOfPhotosInPickerBrowser:self]) return;
//    
//    UICollectionViewCell *cell = [self collectionView:self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentPage inSection:0]];
//    
//    PickerPhotoScrollView *scrollView = [cell.contentView.subviews lastObject];
//    if (![scrollView isKindOfClass:[PickerPhotoScrollView class]]) return;
////    UIScrollView *scrollView = [self.collectionView.subviews objectAtIndex:self.currentPage];
//    if (scrollView.zoomScale == scrollView.maximumZoomScale) {
//        [scrollView setZoomScale:1.0 animated:YES];
//    }else{
//        
//        CGPoint touchPoint = [tap locationInView:tap.view];
//        // Zoom in
//        CGFloat newZoomScale;
//        // Go to max zoom
//        newZoomScale = scrollView.maximumZoomScale;
//        CGFloat xsize = self.view.width / newZoomScale;
//        CGFloat ysize = self.view.height / newZoomScale;
//        [scrollView zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
//    }
//    
////    UIScrollView *scrollView = [self.scrollView.subviews objectAtIndex:self.currentPage];
////    if (scrollView.zoomScale == scrollView.maximumZoomScale) {
////        [scrollView setZoomScale:1.0 animated:YES];
////    }else{
////        
////        CGPoint touchPoint = [tap locationInView:tap.view];
////        // Zoom in
////        CGFloat newZoomScale;
////        // Go to max zoom
////        newZoomScale = scrollView.maximumZoomScale;
////        CGFloat xsize = self.view.width / newZoomScale;
////        CGFloat ysize = self.view.height / newZoomScale;
////        [scrollView zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
////    }
//}

//- (void) disMissTap:(UITapGestureRecognizer *)tap{
//    
//    if (self.disMissBlock) {
//        self.disMissBlock(self.currentPage);
//    }else{
//        [self dismissViewControllerAnimated:YES completion:nil];
//    }
//}

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
    }
    if (indexPath.item == [self.dataSource numberOfPhotosInPickerBrowser:self] - 1) {
        scrollView.frame = CGRectMake(-20, 0, cell.width, cell.height);
    }else{
        scrollView.frame = CGRectMake(0, 0, cell.width, cell.height);
    }
    
    scrollView.photo = photo;
    
    return cell;
    
}

- (void) reloadData{
    // 计算控件
    [self.collectionView reloadData];
    
    if (self.currentPage) {
        self.collectionView.contentOffset = CGPointMake(self.currentPage * self.collectionView.width, 0);
    }
    self.pageCtrl.numberOfPages = [self.dataSource numberOfPhotosInPickerBrowser:self];
    self.pageCtrl.currentPage = self.currentPage;
}

- (void) setUI{
    
    NSInteger count = [self.dataSource numberOfPhotosInPickerBrowser:self];
    if (!count) return ;

    
//    self.scrollView.contentSize = CGSizeMake(count * self.view.bounds.size.width, 0);
//    
//    for (int i = 0; i < count; i++) {
//        PickerPhoto *photo = [self.dataSource photoBrowser:self photoAtIndex:i];
//        PickerPhotoScrollView *scrollView = [[PickerPhotoScrollView alloc] init];
//        scrollView.frame = CGRectMake(self.scrollView.bounds.size.width * i, 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
//        scrollView.photo = photo;
//        [self.scrollView addSubview:scrollView];
//    }
//    self.deleleBtn.hidden = !self.isEditing;
//    
//    self.pageCtrl.numberOfPages = count;
//    
//    if (self.currentPage) {
//        self.scrollView.contentOffset = CGPointMake(self.currentPage * self.scrollView.width, 0);
//    }
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    self.currentPage = (NSInteger)((scrollView.contentOffset.x / scrollView.width) + 0.5);
    
    self.pageCtrl.currentPage = self.currentPage;
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
    
//    self collectionView:self.collectionView cellForItemAtIndexPath:[]
    
//    PickerPhoto *photo = [self.dataSource photoBrowser:self photoAtIndex:indexPath.item];
    
                                         
//    if (self.currentPage != (NSInteger)(scView.contentOffset.x / scView.width) ) {
//        for (UIScrollView *sc in self.scrollView.subviews) {
//            if ([scView zoomScale] != 1.0) {
//                [scView setZoomScale:1.0 animated:YES];
//            }
//        }
//    }
//    if (self.currentPage != (NSInteger)(scrollView.contentOffset.x / scrollView.width) ) {
//        for (UIScrollView *sc in self.scrollView.subviews) {
//            if ([sc zoomScale] != 1.0) {
//                [sc setZoomScale:1.0 animated:YES];
//            }
//        }
//    }
}



#pragma mark -删除照片
- (void) delete{
    if ([self.delegate respondsToSelector:@selector(photoBrowser:removePhotoAtIndex:)]) {
        [self.delegate photoBrowser:self removePhotoAtIndex:self.currentPage];
    }
    [self reloadData];
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
