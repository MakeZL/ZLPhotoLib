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
#import "UIImageView+WebCache.h"

@interface Example2ViewController () <UICollectionViewDataSource,UICollectionViewDelegate,ZLPhotoPickerBrowserViewControllerDataSource,ZLPhotoPickerBrowserViewControllerDelegate,UIActionSheetDelegate>

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
                                                                    @"http://imgsrc.baidu.com/forum/w%3D580/sign=4bbc9d7ecdfc1e17fdbf8c397a90f67c/eac83bc79f3df8dcd915a5f9cf11728b471028b0.jpg",
                                                                    @"http://imgsrc.baidu.com/forum/w%3D580/sign=a68da75679ec54e741ec1a1689399bfd/0225720e0cf3d7cafc79151ef01fbe096a63a9d6.jpg",
                                                                    @"http://imgsrc.baidu.com/forum/w%3D580/sign=7f1993869e82d158bb8259b9b00a19d5/2a79ca8065380cd73f33b785a344ad34598281b4.jpg",
                                                                    @"http://imgsrc.baidu.com/forum/w%3D580/sign=3c94ce51b1de9c82a665f9875c8080d2/0914b07eca806538a21b8e7b95dda144ac3482e8.jpg"
                                                                    ]];
        NSMutableArray *section2 = [NSMutableArray arrayWithArray:@[
                                                                    @"http://imgsrc.baidu.com/forum/pic/item/db33970a304e251f6940f190a586c9177f3e532e.jpg",
                                                                    @"http://imgsrc.baidu.com/forum/w%3D580/sign=975a92499113b07ebdbd50003cd69113/90d662d9f2d3572c7d7789b48813632763d0c3cc.jpg",
                                                                    @"http://imgsrc.baidu.com/forum/w%3D580/sign=5d2a6aa3f9edab6474724dc8c736af81/32d4fd1f4134970ac96b044797cad1c8a7865d41.jpg",
                                                                    @"http://imgsrc.baidu.com/forum/w%3D580/sign=cab899c1ab014c08193b28ad3a7a025b/c861d0160924ab18b4b7f55f37fae6cd7b890b3f.jpg",
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
        cell.imageView.image = [asset aspectRatioImage];
    }else if ([asset isKindOfClass:[NSString class]]){
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:(NSString *)asset] placeholderImage:[UIImage imageNamed:@"pc_circle_placeholder"]];
    }else if([asset isKindOfClass:[UIImage class]]){
        cell.imageView.image = (UIImage *)asset;
    }else if ([asset isKindOfClass:[ZLCamera class]]){
        cell.imageView.image = [asset thumbImage];
    }
    
    return cell;
    
}

#pragma mark - <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    // 图片游览器
    ZLPhotoPickerBrowserViewController *pickerBrowser = [[ZLPhotoPickerBrowserViewController alloc] init];
    
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
    [pickerBrowser showPickerVc:self];
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
    if ([imageObj isKindOfClass:[ZLPhotoAssets class]]) {
        photo.asset = imageObj;
    }
    photo.toView = cell.imageView;
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

#pragma mark - ActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 0:  //打开照相机拍照
            [self openCamera];
            break;
        case 1:  //打开本地相册
            [self openLocalPhoto];
            break;
    }
}

- (void)openCamera{
    ZLCameraViewController *cameraVc = [[ZLCameraViewController alloc] init];
    // 拍照最多个数
    cameraVc.maxCount = 6;
    __weak typeof(self) weakSelf = self;
    cameraVc.callback = ^(NSArray *cameras){
        [[weakSelf.assets firstObject] addObjectsFromArray:cameras];
        [weakSelf.collectionView reloadData];
    };
    [cameraVc showPickerVc:self];
}

- (void)openLocalPhoto{
    ZLPhotoPickerViewController *pickerVc = [[ZLPhotoPickerViewController alloc] init];
    // 最多能选9张图片
    if (self.assets.count > 9) {
        pickerVc.maxCount = 0;
    }else{
        pickerVc.maxCount = 9 - self.assets.count;
    }
    pickerVc.status = PickerViewShowStatusCameraRoll;
    [pickerVc showPickerVc:self];
    
    __weak typeof(self) weakSelf = self;
    pickerVc.callBack = ^(NSArray *assets){
        [[weakSelf.assets firstObject] addObjectsFromArray:assets];
        [weakSelf.collectionView reloadData];
    };
}

#pragma mark - 选择照片
- (void)selectPhotos {
    UIActionSheet *myActionSheet = [[UIActionSheet alloc]initWithTitle:nil
                                                              delegate:self
                                                     cancelButtonTitle:@"取消"
                                                destructiveButtonTitle:nil
                                                     otherButtonTitles:@"打开照相机",@"从手机相册获取",nil];
    
    [myActionSheet showInView:[UIApplication sharedApplication].keyWindow];
}

@end
