//
//  Example7ViewController.m
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 15-4-3.
//  Copyright (c) 2015年 com.zixue101.www. All rights reserved.
//

#import "Example7ViewController.h"
#import "ZLPhoto.h"

@interface Example7ViewController () <ZLPhotoPickerBrowserViewControllerDataSource,ZLPhotoPickerBrowserViewControllerDelegate>

@property (nonatomic , strong) NSMutableArray *assets;
@property (weak,nonatomic) UIScrollView *scrollView;

@end

@implementation Example7ViewController


- (NSMutableArray *)assets{
    if (!_assets) {
        _assets = [NSMutableArray arrayWithArray:@[
                                                   @"http://www.qqaiqin.com/uploads/allimg/130520/4-13052022531U60.gif",
                                                   @"http://www.1tong.com/uploads/wallpaper/anime/124-2-1280x800.jpg",
                                                   @"http://imgsrc.baidu.com/forum/pic/item/c59ca2ef76c6a7ef603e17c7fcfaaf51f2de6640.jpg",
                                                   @"http://www.qqaiqin.com/uploads/allimg/130520/4-13052022531U60.gif",
                                                   @"http://www.1tong.com/uploads/wallpaper/anime/124-2-1280x800.jpg",
                                                   ]];
    }
    return _assets;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 这个属性不能少
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64);
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;
    
    // 属性scrollView
    [self reloadScrollView];
}

- (void)reloadScrollView{
    
    // 先移除，后添加
    [[self.scrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSUInteger column = 3;
    // 加一是为了有个添加button
    NSUInteger assetCount = self.assets.count + 1;
    
    CGFloat width = self.view.frame.size.width / column;
    for (NSInteger i = 0; i < assetCount; i++) {
        
        NSInteger row = i / column;
        NSInteger col = i % column;
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.imageView.contentMode = UIViewContentModeScaleAspectFill;
        btn.frame = CGRectMake(width * col, row * width, width, width);
        
        // UIButton
        if (i == self.assets.count){
            // 最后一个Button
            [btn setImage:[UIImage imageNamed:@"iconfont-tianjia"] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(photoSelecte) forControlEvents:UIControlEventTouchUpInside];
        }else{
            // 如果是本地ZLPhotoAssets就从本地取，否则从网络取
            if ([[self.assets objectAtIndex:i] isKindOfClass:[ZLPhotoAssets class]]) {
                [btn setImage:[self.assets[i] thumbImage] forState:UIControlStateNormal];
            }else{
                [btn sd_setImageWithURL:[NSURL URLWithString:self.assets[i % (self.assets.count)]] forState:UIControlStateNormal];
            }
            btn.tag = i;
            [btn addTarget:self action:@selector(tapBrowser:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        [self.scrollView addSubview:btn];
    }
    
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, CGRectGetMaxY([[self.scrollView.subviews lastObject] frame]));
}

#pragma mark - 选择图片
- (void)photoSelecte{
    ZLPhotoPickerViewController *pickerVc = [[ZLPhotoPickerViewController alloc] init];
    pickerVc.minCount = 9;
    pickerVc.status = PickerViewShowStatusCameraRoll;
    pickerVc.callBack = ^(NSArray *status){
        [self.assets addObjectsFromArray:status];
        [self reloadScrollView];
    };
    
    [pickerVc show];
}

- (void)tapBrowser:(UIButton *)btn{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:btn.tag inSection:0];
    // 图片游览器
    ZLPhotoPickerBrowserViewController *pickerBrowser = [[ZLPhotoPickerBrowserViewController alloc] init];
    // 淡入淡出效果
    // pickerBrowser.status = UIViewAnimationAnimationStatusFade;
    // 传入点击图片View的话，会有微信朋友圈照片的风格
    pickerBrowser.toView = btn;
    // 数据源/delegate
    pickerBrowser.delegate = self;
    pickerBrowser.dataSource = self;
    // 当前选中的值
    pickerBrowser.currentIndexPath = [NSIndexPath indexPathForItem:indexPath.row inSection:0];
    // 展示控制器
    [pickerBrowser show];
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
    
    UIButton *btn = self.scrollView.subviews[indexPath.row];
    // 缩略图
    photo.thumbImage = btn.imageView.image;
    return photo;
}

@end
