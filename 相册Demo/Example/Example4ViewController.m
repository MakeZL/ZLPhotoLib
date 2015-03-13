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
                                                   @"http://www.qqaiqin.com/uploads/allimg/130520/4-13052022531U60.gif",
                                                   @"http://www.1tong.com/uploads/wallpaper/anime/124-2-1280x800.jpg",
                                                   @"http://imgsrc.baidu.com/forum/pic/item/c59ca2ef76c6a7ef603e17c7fcfaaf51f2de6640.jpg",
                                                   @"http://www.qqaiqin.com/uploads/allimg/130520/4-13052022531U60.gif",
                                                   @"http://www.1tong.com/uploads/wallpaper/anime/124-2-1280x800.jpg",
                                                   @"http://imgsrc.baidu.com/forum/pic/item/c59ca2ef76c6a7ef603e17c7fcfaaf51f2de6640.jpg",
                                                   @"http://www.qqaiqin.com/uploads/allimg/130520/4-13052022531U60.gif",
                                                   @"http://www.1tong.com/uploads/wallpaper/anime/124-2-1280x800.jpg",
                                                   @"http://imgsrc.baidu.com/forum/pic/item/c59ca2ef76c6a7ef603e17c7fcfaaf51f2de6640.jpg",
                                                   @"http://www.qqaiqin.com/uploads/allimg/130520/4-13052022531U60.gif",
                                                   @"http://www.1tong.com/uploads/wallpaper/anime/124-2-1280x800.jpg",
                                                   @"http://imgsrc.baidu.com/forum/pic/item/c59ca2ef76c6a7ef603e17c7fcfaaf51f2de6640.jpg",
                                                   ]];
    }
    return _assets;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Custom View
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
    // 淡入淡出
//    pickerBrowser.status = UIViewAnimationAnimationStatusFade;
    // 传入点击图片View的话，会有微信朋友圈照片的风格
    pickerBrowser.toView = btn;
    // 数据源/delegate
    pickerBrowser.delegate = self;
    pickerBrowser.dataSource = self;
    // 是否可以删除照片
    pickerBrowser.editing = YES;
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

- (ZLPhotoPickerBrowserPhoto *) photoBrowser:(ZLPhotoPickerBrowserViewController *)pickerBrowser photoAtIndexPath:(NSIndexPath *)indexPath{
    
    ZLPhotoAssets *imageObj = [self.assets objectAtIndex:indexPath.row];
    ZLPhotoPickerBrowserPhoto *photo = [ZLPhotoPickerBrowserPhoto photoAnyImageObjWith:imageObj];
    
    UIButton *btn = self.photoView.subviews[indexPath.row];
    
    photo.thumbImage = btn.imageView.image;
    return photo;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
