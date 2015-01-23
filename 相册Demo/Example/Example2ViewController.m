//
//  Example2ViewController.m
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 15-1-19.
//  Copyright (c) 2015年 com.zixue101.www. All rights reserved.
//

#import "Example2ViewController.h"
#import "Example2CollectionViewCell.h"
#import "ZLPhoto.h"

@interface Example2ViewController () <UICollectionViewDataSource,UICollectionViewDelegate,ZLPhotoPickerBrowserViewControllerDataSource,ZLPhotoPickerBrowserViewControllerDelegate>

@property (nonatomic , strong) NSMutableArray *assets;
@property (weak,nonatomic) UICollectionView *collectionView;
@property (strong,nonatomic) ZLCameraViewController *cameraVc;

@end

@implementation Example2ViewController

- (NSMutableArray *)assets{
    if (!_assets) {
        _assets = [NSMutableArray arrayWithArray:@[
                                                   @"http://www.qqaiqin.com/uploads/allimg/130520/4-13052022531U60.gif",
                                                   @"http://www.1tong.com/uploads/wallpaper/anime/124-2-1280x800.jpg",
                                                   @"http://imgsrc.baidu.com/forum/pic/item/xc59ca2ef76c6a7ef603e17c7fcfaaf51f2de6640.jpg",
                                                   @"http://imgsrc.baidu.com/forum/pic/item/3f7dacaf2edda3cc7d2289ab01e93901233f92c5.jpg",
                                                   ]];
    }
    return _assets;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [self setupUI];
}

- (void)setupUI{
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupCollectionView];
    [self setupButtons];
}

- (void)setupCollectionView{
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(130, 130);
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.minimumLineSpacing = 10;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    [collectionView registerNib:[UINib nibWithNibName:@"Example2CollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"Example2CollectionViewCell"];
    [self.view addSubview:collectionView];
    
    self.collectionView = collectionView;
}

- (void)setupButtons{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"选择照片" style:UIBarButtonItemStyleDone target:self action:@selector(selectPhotos)];
}

#pragma mark - <UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.assets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    Example2CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Example2CollectionViewCell" forIndexPath:indexPath];

    ZLPhotoAssets *asset = self.assets[indexPath.row];
    if ([asset isKindOfClass:[ZLPhotoAssets class]]) {
        cell.imageView.image = asset.thumbImage;
    }else if ([asset isKindOfClass:[NSString class]]){
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:(NSString *)asset] placeholderImage:[UIImage imageNamed:@"wallpaper_placeholder"]];
    }else if([asset isKindOfClass:[UIImage class]]){
        cell.imageView.image = (UIImage *)asset;
    }else if ([asset isKindOfClass:[ZLCamera class]]){
        cell.imageView.image = [asset thumbImage];
    }
    
    return cell;
    
}

#pragma mark - <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    Example2CollectionViewCell *cell = (Example2CollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    // 图片游览器
    ZLPhotoPickerBrowserViewController *pickerBrowser = [[ZLPhotoPickerBrowserViewController alloc] init];
    // 传入点击图片View的话，会有微信朋友圈照片的风格
    pickerBrowser.toView = cell.imageView;
    // 数据源/delegate
    pickerBrowser.delegate = self;
    pickerBrowser.dataSource = self;
    // 是否可以删除照片
    pickerBrowser.editing = YES;
    // 当前选中的值
    pickerBrowser.currentPage = indexPath.row;
    // 展示控制器
    [pickerBrowser show];
}

#pragma mark - <ZLPhotoPickerBrowserViewControllerDataSource>
- (NSInteger) numberOfPhotosInPickerBrowser:(ZLPhotoPickerBrowserViewController *)pickerBrowser{
    return self.assets.count;
}

- (ZLPhotoPickerBrowserPhoto *) photoBrowser:(ZLPhotoPickerBrowserViewController *)pickerBrowser photoAtIndex:(NSUInteger)index{
    
    id imageObj = [self.assets objectAtIndex:index];
    ZLPhotoPickerBrowserPhoto *photo = [ZLPhotoPickerBrowserPhoto photoAnyImageObjWith:imageObj];
    
    Example2CollectionViewCell *cell = (Example2CollectionViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    
    photo.thumbImage = cell.imageView.image;
    
    return photo;
}

#pragma mark - <ZLPhotoPickerBrowserViewControllerDelegate>
- (void)photoBrowser:(ZLPhotoPickerBrowserViewController *)photoBrowser removePhotoAtIndex:(NSUInteger)index{
    if (index > self.assets.count) return;
    [self.assets removeObjectAtIndex:index];
    [self.collectionView reloadData];
}

#pragma mark - select Photo Library
- (void)selectPhotos {
    ZLCameraViewController *cameraVc = [[ZLCameraViewController alloc] init];
    __weak typeof(self) weakSelf = self;
    [cameraVc startCameraOrPhotoFileWithViewController:self complate:^(NSArray *object) {
        // 回调 ,
        [object enumerateObjectsUsingBlock:^(id asset, NSUInteger idx, BOOL *stop) {
            if ([asset isKindOfClass:[ZLCamera class]]) {
                [weakSelf.assets addObject:asset];
            }else{
                [weakSelf.assets addObject:asset];
            }
        }];
        [weakSelf.collectionView reloadData];
    }];
    self.cameraVc = cameraVc;

}

@end
