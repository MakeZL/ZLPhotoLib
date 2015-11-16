//
//  Example1ViewController.m
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 15-1-19.
//  Copyright (c) 2015年 com.zixue101.www. All rights reserved.
//

#import "Example1ViewController.h"
#import "Example1TableViewCell.h"
#import "ZLPhoto.h"
#import "UIImageView+WebCache.h"

@interface Example1ViewController() <UITableViewDataSource,UITableViewDelegate,ZLPhotoPickerBrowserViewControllerDelegate>
@property (nonatomic , strong) NSMutableArray *photos;

@end

@implementation Example1ViewController

#pragma mark - Getter
#pragma mark Get data
- (NSMutableArray *)photos{
    if (!_photos) {
        
        _photos = [NSMutableArray array];
        
        // 测试数据啦
        ZLPhotoPickerBrowserPhoto *photo1 = [[ZLPhotoPickerBrowserPhoto alloc] init];
        photo1.photoURL = [NSURL URLWithString:@"http://imgsrc.baidu.com/forum/w%3D580/sign=445a261ef01fbe091c5ec31c5b610c30/23064a90f603738d96e6154ab11bb051f819ec35.jpg"];
        [_photos addObject:photo1];
        
        ZLPhotoPickerBrowserPhoto *photo2 = [[ZLPhotoPickerBrowserPhoto alloc] init];
        photo2.photoURL = [NSURL URLWithString:@"http://imgsrc.baidu.com/forum/w%3D580/sign=14e206601d30e924cfa49c397c096e66/1bcc39dbb6fd5266c3fc277ca918972bd507368d.jpg"];
        [_photos addObject:photo2];
        
        ZLPhotoPickerBrowserPhoto *photo3 = [[ZLPhotoPickerBrowserPhoto alloc] init];
        photo3.photoURL = [NSURL URLWithString:@"http://imgsrc.baidu.com/forum/pic/item/4753564e9258d1095d4280dad358ccbf6c814d38.jpg"];
        [_photos addObject:photo3];
        
        ZLPhotoPickerBrowserPhoto *photo4 = [[ZLPhotoPickerBrowserPhoto alloc] init];
        photo4.photoURL = [NSURL URLWithString:@"http://imgsrc.baidu.com/forum/pic/item/6c04738da9773912fcb7ae09fa198618377ae2c8.jpg"];
        [_photos addObject:photo4];
        
    }
    return _photos;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [[SDImageCache sharedImageCache] clearDisk];
    [[SDImageCache sharedImageCache] clearMemory];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"Example1TableViewCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    self.view.backgroundColor = [UIColor whiteColor];
}

#pragma mark - <UITableViewDataSource>
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.photos.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ID = @"cell";
    Example1TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    // 判断类型来获取Image
    ZLPhotoPickerBrowserPhoto *photo = self.photos[indexPath.row];
    [cell.imageview1 sd_setImageWithURL:photo.photoURL];
    photo.toView = cell.imageview1;
    return cell;
}

#pragma mark - <UITableViewDelegate>
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // 点击cell 放大缩小图片
    [self setupPhotoBrowser:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 95;
}

#pragma mark - setupCell click ZLPhotoPickerBrowserViewController
- (void) setupPhotoBrowser:(NSIndexPath *)indexPath{
    // 图片游览器
    ZLPhotoPickerBrowserViewController *pickerBrowser = [[ZLPhotoPickerBrowserViewController alloc] init];
    // 数据源/delegate
    pickerBrowser.delegate = self;
    // 数据源可以不传，传photos数组 photos<里面是ZLPhotoPickerBrowserPhoto>
    pickerBrowser.photos = self.photos;
    // 是否可以删除照片
    pickerBrowser.editing = YES;
    // 当前选中的值
    pickerBrowser.currentIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
    // 展示控制器
    [pickerBrowser showPickerVc:self];
}

/**
 *  @MakeZL:以下传数据源模式，同样可行
 */
#pragma mark - <ZLPhotoPickerBrowserViewControllerDataSource>
//- (NSInteger)numberOfSectionInPhotosInPickerBrowser:(ZLPhotoPickerBrowserViewController *)pickerBrowser{
//    return 1;
//}
//
//- (NSInteger)photoBrowser:(ZLPhotoPickerBrowserViewController *)photoBrowser numberOfItemsInSection:(NSUInteger)section{
//    return self.assets.count;
//}
//
//#pragma mark - 每个组展示什么图片,需要包装下ZLPhotoPickerBrowserPhoto
//- (ZLPhotoPickerBrowserPhoto *) photoBrowser:(ZLPhotoPickerBrowserViewController *)pickerBrowser photoAtIndexPath:(NSIndexPath *)indexPath{
//    ZLPhotoAssets *imageObj = [self.assets objectAtIndex:indexPath.row];
//    // 包装下imageObj 成 ZLPhotoPickerBrowserPhoto 传给数据源
//    ZLPhotoPickerBrowserPhoto *photo = [ZLPhotoPickerBrowserPhoto photoAnyImageObjWith:imageObj];
//    Example1TableViewCell *cell = (Example1TableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
//    // 缩略图
//    photo.toView = cell.imageview1;
//    photo.thumbImage = cell.imageview1.image;
//    return photo;
//}

#pragma mark - <ZLPhotoPickerBrowserViewControllerDelegate>
#pragma mark 删除调用
- (void)photoBrowser:(ZLPhotoPickerBrowserViewController *)photoBrowser removePhotoAtIndexPath:(NSIndexPath *)indexPath{
    // 删除照片时调用
    if (indexPath.row > [self.photos count]) return;
    [self.photos removeObjectAtIndex:indexPath.row];
    [self.tableView reloadData];
}

@end
