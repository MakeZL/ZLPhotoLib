//
//  Example4ViewController.m
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 15-3-13.
//  Copyright (c) 2015年 com.zixue101.www. All rights reserved.
//

#import "Example4ViewController.h"
#import "ZLPhotoPickerBrowserViewController.h"
#import "UIButton+WebCache.h"

@interface Example4ViewController () <ZLPhotoPickerBrowserViewControllerDataSource,ZLPhotoPickerBrowserViewControllerDelegate>

@property (nonatomic , strong) NSMutableArray *assets;
@property (weak,nonatomic) UIView *photoView;

@end

@implementation Example4ViewController

- (NSMutableArray *)assets{
    if (!_assets) {
        _assets = [NSMutableArray arrayWithArray:@[
                                                   @"http://imgsrc.baidu.com/forum/pic/item/d097f603738da97772b89243b251f8198718e3ce.jpg",
                                                   @"http://imgsrc.baidu.com/forum/w%3D580/sign=a49682b40afa513d51aa6cd60d6d554c/18055aafa40f4bfbcef4893c014f78f0f73618bc.jpg",
                                                   @"http://imgsrc.baidu.com/forum/w%3D580/sign=012250d34510b912bfc1f6f6f3fcfcb5/4f658535e5dde7115cdc549ea5efce1b9d166157.jpg",
                                                   @"http://imgsrc.baidu.com/forum/w%3D580/sign=56ae691222a446237ecaa56aa8237246/e3360a55b319ebc48cc965f18026cffc1e17162f.jpg",
                                                   @"http://imgsrc.baidu.com/forum/w%3D580/sign=3290b51dd488d43ff0a991fa4d1fd2aa/541c9d16fdfaaf513d4d93d78e5494eef01f7a37.jpg",
                                                   @"http://imgsrc.baidu.com/forum/w%3D580/sign=02b953d19c510fb37819779fe932c893/085fd109b3de9c82352ce4e76e81800a19d84310.jpg",
                                                   @"http://imgsrc.baidu.com/forum/w%3D580/sign=153a71b63f6d55fbc5c6762e5d234f40/61eaab64034f78f0c49b879b7b310a55b2191cc8.jpg",
                                                   @"http://imgsrc.baidu.com/forum/w%3D580/sign=39a980b48813632715edc23ba18ea056/4334c895d143ad4bf9655aa880025aafa40f0611.jpg",
                                                   @"http://imgsrc.baidu.com/forum/w%3D580/sign=01ea27ac19d5ad6eaaf964e2b1ca39a3/0ee9f01f3a292df5330fb07dbe315c6035a87395.jpg",
                                                   @"http://imgsrc.baidu.com/forum/w%3D580/sign=0c02237ca918972ba33a00c2d6cd7b9d/17b6cb134954092301407c169058d109b3de49b0.jpg",
                                                   @"http://imgsrc.baidu.com/forum/w%3D580/sign=100bd7a2ad51f3dec3b2b96ca4eef0ec/4d2d6059252dd42aa5291ec3013b5bb5c9eab8b9.jpg",
                                                   @"http://imgsrc.baidu.com/forum/w%3D580/sign=da399d521bd8bc3ec60806c2b28aa6c8/0ddaa144ad345982040fcdfa0ef431adcaef84dc.jpg",
                                                   ]];
    }
    return _assets;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Custom View
    [self setupPhotoView];
}

#pragma mark 创建九宫格的View
- (void)setupPhotoView{
    UIView *photoView = [[UIView alloc] init];
    photoView.frame = self.view.frame;
    [self.view addSubview:photoView];
    
    NSUInteger column = 3;
    CGFloat width = self.view.frame.size.width / column;
    for (NSInteger i = 0; i < self.assets.count; i++) {
        
        NSInteger row = i / column;
        NSInteger col = i % column;
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(width * col, 64 + row * width, width, width);
        [btn sd_setImageWithURL:[NSURL URLWithString:self.assets[i % (self.assets.count)]] forState:UIControlStateNormal];
        btn.tag = i;
        [photoView addSubview:btn];
        [btn addTarget:self action:@selector(tapBrowser:) forControlEvents:UIControlEventTouchUpInside];
    }
    self.photoView = photoView;
}

- (void)tapBrowser:(UIButton *)btn{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:btn.tag inSection:0];
    // 图片游览器
    ZLPhotoPickerBrowserViewController *pickerBrowser = [[ZLPhotoPickerBrowserViewController alloc] init];
    // 淡入淡出效果
    // pickerBrowser.status = UIViewAnimationAnimationStatusFade;
//    pickerBrowser.toView = btn;
    // 数据源/delegate
    pickerBrowser.delegate = self;
    pickerBrowser.dataSource = self;
    // 是否可以删除照片
    pickerBrowser.editing = YES;
    // 当前选中的值
    pickerBrowser.currentIndexPath = [NSIndexPath indexPathForItem:indexPath.row inSection:0];
    // 展示控制器
    [pickerBrowser showPickerVc:self];
}


#pragma mark - <ZLPhotoPickerBrowserViewControllerDataSource>
- (NSInteger)numberOfSectionInPhotosInPickerBrowser:(ZLPhotoPickerBrowserViewController *)pickerBrowser{
    return 1;
}

- (NSInteger)photoBrowser:(ZLPhotoPickerBrowserViewController *)photoBrowser numberOfItemsInSection:(NSUInteger)section{
    return self.assets.count;
}

#pragma mark - 每个组展示什么图片,需要包装下ZLPhotoPickerBrowserPhoto
- (ZLPhotoPickerBrowserPhoto *) photoBrowser:(ZLPhotoPickerBrowserViewController *)pickerBrowser photoAtIndexPath:(NSIndexPath *)indexPath{
    ZLPhotoAssets *imageObj = [self.assets objectAtIndex:indexPath.row];
    // 包装下imageObj 成 ZLPhotoPickerBrowserPhoto 传给数据源
    ZLPhotoPickerBrowserPhoto *photo = [ZLPhotoPickerBrowserPhoto photoAnyImageObjWith:imageObj];
    
    UIButton *btn = self.photoView.subviews[indexPath.row];
    photo.toView = btn.imageView;
    // 缩略图
    photo.thumbImage = btn.imageView.image;
    return photo;
}

#pragma mark - <ZLPhotoPickerBrowserViewControllerDelegate>
#pragma mark - 删除照片调用
- (void)photoBrowser:(ZLPhotoPickerBrowserViewController *)photoBrowser removePhotoAtIndexPath:(NSIndexPath *)indexPath{
    // 删除照片，重新刷新View
    if (indexPath.row > [self.assets count]) return;
    [self.assets removeObjectAtIndex:indexPath.row];
    [self.photoView removeFromSuperview];
    [self setupPhotoView];
}

@end
