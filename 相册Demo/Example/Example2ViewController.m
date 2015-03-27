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

#pragma mark - Getter
#pragma mark Get Data
- (NSMutableArray *)assets{
    if (!_assets) {
        // CollctionView 可以分组。
        NSMutableArray *section1 = [NSMutableArray arrayWithArray:@[
                                                                    @"http://www.qqaiqin.com/uploads/allimg/130520/4-13052022531U60.gif",
                                                                    @"http://www.1tong.com/uploads/wallpaper/anime/124-2-1280x800.jpg",
                                                                    @"http://imgsrc.baidu.com/forum/pic/item/xc59ca2ef76c6a7ef603e17c7fcfaaf51f2de6640.jpg",
                                                                    @"http://imgsrc.baidu.com/forum/pic/item/3f7dacaf2edda3cc7d2289ab01e93901233f92c5.jpg",
                                                                    ]];
        NSMutableArray *section2 = [NSMutableArray arrayWithArray:@[
                                                                    @"http://d.hiphotos.baidu.com/image/pic/item/5ab5c9ea15ce36d3e6ce923138f33a87e850b1ec.jpg",
                                                                    @"http://b.hiphotos.baidu.com/image/pic/item/810a19d8bc3eb135eae45086a51ea8d3fd1f44e8.jpg",
                                                                    @"http://c.hiphotos.baidu.com/image/pic/item/b3b7d0a20cf431ade14e30214936acaf2edd980d.jpg",
                                                                    @"http://c.hiphotos.baidu.com/image/pic/item/0df3d7ca7bcb0a46202bd1386963f6246b60afa2.jpg",
                                                                    ]];
        
        _assets = [NSMutableArray arrayWithObjects:section1,section2, nil];
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

#pragma mark setup UI
- (void)setupCollectionView{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(130, 130);
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.minimumLineSpacing = 10;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.sectionInset = UIEdgeInsetsMake(10, 0, 0, 0);
    
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
    return self.assets.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.assets[section] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    Example2CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Example2CollectionViewCell" forIndexPath:indexPath];
    
    // 判断类型来获取Image
    ZLPhotoAssets *asset = self.assets[indexPath.section][indexPath.item];
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
    // 动画方式
    /*
     * 
         UIViewAnimationAnimationStatusZoom = 0, // 放大缩小
         UIViewAnimationAnimationStatusFade , // 淡入淡出
         UIViewAnimationAnimationStatusRotate // 旋转
         pickerBrowser.status = UIViewAnimationAnimationStatusFade;
     */
    pickerBrowser.delegate = self;
    pickerBrowser.dataSource = self;
    // 是否可以删除照片
    pickerBrowser.editing = YES;
    // 当前分页的值
    // pickerBrowser.currentPage = indexPath.row;
    // 传入组
    pickerBrowser.currentIndexPath = indexPath;
    // 展示控制器
    [pickerBrowser show];
}

#pragma mark - <ZLPhotoPickerBrowserViewControllerDataSource>
- (NSInteger)numberOfSectionInPhotosInPickerBrowser:(ZLPhotoPickerBrowserViewController *)pickerBrowser{
    return self.assets.count;
}

- (NSInteger)photoBrowser:(ZLPhotoPickerBrowserViewController *)photoBrowser numberOfItemsInSection:(NSUInteger)section{
    return [self.assets[section] count];
}

- (ZLPhotoPickerBrowserPhoto *)photoBrowser:(ZLPhotoPickerBrowserViewController *)pickerBrowser photoAtIndexPath:(NSIndexPath *)indexPath{
    id imageObj = [self.assets[indexPath.section] objectAtIndex:indexPath.item];
    ZLPhotoPickerBrowserPhoto *photo = [ZLPhotoPickerBrowserPhoto photoAnyImageObjWith:imageObj];
    // 包装下imageObj 成 ZLPhotoPickerBrowserPhoto 传给数据源
    Example2CollectionViewCell *cell = (Example2CollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    // 缩略图
    photo.thumbImage = cell.imageView.image;
    return photo;
}

#pragma mark - <ZLPhotoPickerBrowserViewControllerDelegate>
#pragma mark 返回自定义View
- (ZLPhotoPickerCustomToolBarView *)photoBrowserShowToolBarViewWithphotoBrowser:(ZLPhotoPickerBrowserViewController *)photoBrowser{
    UIButton *customBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [customBtn setTitle:@"实现代理自定义ToolBar" forState:UIControlStateNormal];
    customBtn.frame = CGRectMake(10, 0, 200, 44);
    return (ZLPhotoPickerCustomToolBarView *)customBtn;
}

- (void)photoBrowser:(ZLPhotoPickerBrowserViewController *)photoBrowser removePhotoAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row > [self.assets[indexPath.section] count]) return;
    [self.assets[indexPath.section] removeObjectAtIndex:indexPath.row];
    [self.collectionView reloadData];
}

#pragma mark - 选择照片
- (void)selectPhotos {
    ZLCameraViewController *cameraVc = [[ZLCameraViewController alloc] init];
    __weak typeof(self) weakSelf = self;
    // 多选相册+相机多拍 回调
    [cameraVc startCameraOrPhotoFileWithViewController:self complate:^(NSArray *object) {
        // 选择完照片、拍照完回调
        [object enumerateObjectsUsingBlock:^(id asset, NSUInteger idx, BOOL *stop) {
            if ([asset isKindOfClass:[ZLCamera class]]) {
                [[weakSelf.assets firstObject] addObject:asset];
            }else{
                [[weakSelf.assets firstObject] addObject:asset];
            }
        }];
        [weakSelf.collectionView reloadData];
    }];
    self.cameraVc = cameraVc;

}

@end
