//
//  PickerAssetsViewController.m
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 14-11-12.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//


// CellFrame
#define CELL_ROW 4
#define CELL_MARGIN 2
#define CELL_LINE_MARGIN CELL_MARGIN

// 通知
#define PICKER_TAKE_DONE @"PICKER_TAKE_DONE"
// TOOLBAR 展示最大图片数
#define TOOLBAR_COUNT 9
// 间距
#define TOOLBAR_IMG_MARGIN 2

#define TOOLBAR_HEIGHT 44

#import "ZLPickerAssetsViewController.h"
#import "ZLPickerCollectionView.h"
#import "ZLPickerGroup.h"
#import "ZLPickerDatas.h"
#import "ZLPickerCollectionViewCell.h"
#import "ZLPickerFooterCollectionReusableView.h"
#import "ZLPickerBrowserViewController.h"
#import "UIView+Extension.h"
#import <AssetsLibrary/AssetsLibrary.h>

static NSString *const _cellIdentifier = @"cell";
static NSString *const _footerIdentifier = @"FooterView";
static NSString *const _identifier = @"toolBarThumbCollectionViewCell";
@interface ZLPickerAssetsViewController () <PickerCollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate,ZLPickerBrowserViewControllerDataSource,ZLPickerBrowserViewControllerDelegate>


// 相片View
@property (nonatomic , strong) ZLPickerCollectionView *collectionView;
// 底部CollectionView
@property (nonatomic , weak) UICollectionView *toolBarThumbCollectionView;

// 标记View
@property (nonatomic , weak) UILabel *makeView;
@property (nonatomic , weak) UIButton *doneBtn;
@property (nonatomic , weak) UIToolbar *toolBar;

// 数据源
@property (nonatomic , strong) NSMutableArray *assets;
// 记录选中的assets
@property (nonatomic , strong) NSMutableArray *selectAssets;


@end

@implementation ZLPickerAssetsViewController

#pragma mark - getter
- (UIButton *)doneBtn{
    if (!_doneBtn) {
        
        UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [rightBtn setTitleColor:[UIColor colorWithRed:0/255.0 green:91/255.0 blue:255/255.0 alpha:1.0] forState:UIControlStateNormal];
        [rightBtn setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        rightBtn.enabled = YES;
        //        rightBtn.translatesAutoresizingMaskIntoConstraints = NO;
        rightBtn.titleLabel.font = [UIFont systemFontOfSize:17];
        rightBtn.frame = CGRectMake(0, 0, 45, 45);
        [rightBtn setTitle:@"完成" forState:UIControlStateNormal];
        [rightBtn addTarget:self action:@selector(done) forControlEvents:UIControlEventTouchUpInside];
        [rightBtn addSubview:self.makeView];
        self.doneBtn = rightBtn;
    }
    
    return _doneBtn;
}
- (UICollectionView *)toolBarThumbCollectionView{
    if (!_toolBarThumbCollectionView) {
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.itemSize = CGSizeMake(40, 40);
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.minimumLineSpacing = 5;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        // CGRectMake(0, 22, 300, 44)
        UICollectionView *toolBarThumbCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        toolBarThumbCollectionView.backgroundColor = [UIColor clearColor];
        toolBarThumbCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
        toolBarThumbCollectionView.dataSource = self;
        toolBarThumbCollectionView.delegate = self;
        [toolBarThumbCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:_identifier];
        
        self.toolBarThumbCollectionView = toolBarThumbCollectionView;
        [self.toolBar addSubview:toolBarThumbCollectionView];
        
        NSDictionary *views = NSDictionaryOfVariableBindings(toolBarThumbCollectionView, self.doneBtn);
        NSString *widthVfl = @"H:|-10-[toolBarThumbCollectionView]-100-|";
        NSString *heightVfl = @"V:|-0-[toolBarThumbCollectionView]-0-|";
        
        
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:widthVfl options:0 metrics:nil views:views]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:heightVfl options:0 metrics:nil views:views]];
    }
    return _toolBarThumbCollectionView;
}
- (NSMutableArray *)selectAssets{
    if (!_selectAssets) {
        _selectAssets = [NSMutableArray array];
    }
    return _selectAssets;
}

#pragma mark collectionView
- (ZLPickerCollectionView *)collectionView{
    if (!_collectionView) {
        
        CGFloat cellW = (self.view.frame.size.width - CELL_MARGIN * CELL_ROW + 1) / CELL_ROW;
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(cellW, cellW);
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = CELL_LINE_MARGIN;
        layout.footerReferenceSize = CGSizeMake(self.view.frame.size.width, TOOLBAR_HEIGHT * 2);
        
        ZLPickerCollectionView *collectionView = [[ZLPickerCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        // 时间置顶
        collectionView.status = ZLPickerCollectionViewShowOrderStatusTimeDesc;
        collectionView.translatesAutoresizingMaskIntoConstraints = NO;
        [collectionView registerClass:[ZLPickerCollectionViewCell class] forCellWithReuseIdentifier:_cellIdentifier];
        // 底部的View
        [collectionView registerClass:[ZLPickerFooterCollectionReusableView class]  forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:_footerIdentifier];
        
        collectionView.contentInset = UIEdgeInsetsMake(5, 0,TOOLBAR_HEIGHT, 0);
        collectionView.collectionViewDelegate = self;
        [self.view insertSubview:collectionView belowSubview:self.toolBar];
        self.collectionView = collectionView;
        
        NSDictionary *views = NSDictionaryOfVariableBindings(collectionView);
        
        NSString *widthVfl = @"H:|-0-[collectionView]-0-|";
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:widthVfl options:0 metrics:nil views:views]];
        
        NSString *heightVfl = @"V:|-0-[collectionView]-0-|";
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:heightVfl options:0 metrics:nil views:views]];
        
    }
    return _collectionView;
}

#pragma mark -红点标记View
- (UILabel *)makeView{
    if (!_makeView) {
        UILabel *makeView = [[UILabel alloc] init];
        makeView.textColor = [UIColor whiteColor];
        makeView.textAlignment = NSTextAlignmentCenter;
        makeView.font = [UIFont systemFontOfSize:13];
        makeView.frame = CGRectMake(-5, -5, 20, 20);
        makeView.hidden = YES;
        makeView.layer.cornerRadius = makeView.frame.size.height / 2.0;
        makeView.clipsToBounds = YES;
        makeView.backgroundColor = [UIColor redColor];
        [self.view addSubview:makeView];
        self.makeView = makeView;
        
    }
    return _makeView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 初始化按钮
    [self setupButtons];
    
    // 初始化底部ToorBar
    [self setupToorBar];
}


#pragma mark - setter
#pragma mark 初始化按钮
- (void) setupButtons{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(back)];
}

#pragma mark 初始化所有的组
- (void) setupAssets{
    if (!self.assets) {
        self.assets = [NSMutableArray array];
    }
    
    __weak typeof(self) weakSelf = self;
    ZLPickerDatas *datas = [ZLPickerDatas defaultPicker];
    [datas getGroupPhotosWithGroup:self.assetsGroup finished:^(NSArray *assets) {
        
        weakSelf.collectionView.dataArray = assets;
    }];
    
}

#pragma mark -初始化底部ToorBar
- (void) setupToorBar{
    UIToolbar *toorBar = [[UIToolbar alloc] init];
    toorBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:toorBar];
    self.toolBar = toorBar;
    
    NSDictionary *views = NSDictionaryOfVariableBindings(toorBar);
    NSString *widthVfl =  @"H:|-0-[toorBar]-0-|";
    NSString *heightVfl = @"V:[toorBar(44)]-0-|";
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:widthVfl options:0 metrics:0 views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:heightVfl options:0 metrics:0 views:views]];
    
    // 左视图 中间距 右视图
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:self.doneBtn];
    UIBarButtonItem *fiexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:self.toolBarThumbCollectionView];
    
    toorBar.items = @[leftItem,fiexItem,rightItem];
    
}

#pragma mark - setter
-(void)setMinCount:(NSInteger)minCount{
    _minCount = minCount;
    self.collectionView.minCount = minCount;
}

- (void)setAssetsGroup:(ZLPickerGroup *)assetsGroup{
    if (!assetsGroup.groupName.length) return ;
    
    _assetsGroup = assetsGroup;
    
    self.title = assetsGroup.groupName;
    
    // 获取Assets
    [self setupAssets];
}


- (void)pickerCollectionViewDidSelected:(ZLPickerCollectionView *)pickerCollectionView{
    NSInteger count = pickerCollectionView.selectAsstes.count;
    self.makeView.hidden = !count;
    self.makeView.text = [NSString stringWithFormat:@"%ld",(long)count];
    self.doneBtn.enabled = (count > 0);
    
    
    self.selectAssets = pickerCollectionView.selectAsstes;
    [self.toolBarThumbCollectionView reloadData];
    
    //    if (count < self.buttons.count) {
    //        for (NSInteger i = self.buttons.count; i > count; i--) {
    //            [self.buttons[i-1] removeFromSuperview];
    //        }
    //    }
    
    // 刷新 toolBarThumbCollectionView
    
    //    // 创建btn
    //    for (int i = 0; i < count; i++) {
    //        ALAsset *asset = pickerCollectionView.selectAsstes[i];
    //
    //        UIButton *btn = nil;
    //        if (self.buttons.count <= i) {
    //            btn = [UIButton buttonWithType:UIButtonTypeCustom];
    //            [self.toolBar addSubview:btn];
    //            [self.buttons addObject:btn];
    //        }else if(self.buttons.count){
    //            btn = self.buttons[i];
    //            if (![btn.superview isKindOfClass:[self class]]) {
    //                [self.toolBar addSubview:btn];
    //            }
    //        }
    //
    //        CGFloat btnW = (self.view.frame.size.width - 80 - TOOLBAR_IMG_MARGIN * 10) / TOOLBAR_COUNT;
    //        CGFloat btnX = btnW * i + (i * TOOLBAR_IMG_MARGIN + TOOLBAR_IMG_MARGIN);
    //        CGFloat btnY = (self.toolBar.frame.size.height - btnW) / 2.0;
    //        [btn setImage:[UIImage imageWithCGImage:[asset thumbnail]] forState:UIControlStateNormal];
    //        btn.frame = CGRectMake(btnX, btnY, btnW, btnW);
    //
    //    }
}

#pragma mark -
#pragma mark - UICollectionViewDataSource
- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.selectAssets.count;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:_identifier forIndexPath:indexPath];
    
    if (self.selectAssets.count > indexPath.item) {
        UIImageView *imageView = [[cell.contentView subviews] lastObject];
        // 判断真实类型
        if (![imageView isKindOfClass:[UIImageView class]]) {
            imageView = [[UIImageView alloc] initWithFrame:cell.bounds];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            imageView.clipsToBounds = YES;
            [cell.contentView addSubview:imageView];
        }
        
        imageView.tag = indexPath.item;
        imageView.image = [UIImage imageWithCGImage:[self.selectAssets[indexPath.item] thumbnail]];
    }
    
    
    return cell;
}

#pragma mark -
#pragma makr UICollectionViewDelegate
- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    
    ZLPickerBrowserViewController *browserVc = [[ZLPickerBrowserViewController alloc] init];
//    browserVc.fromView = self.view;
    browserVc.toView = [cell.contentView.subviews lastObject];
    browserVc.currentPage = indexPath.item;
    browserVc.delegate = self;
    browserVc.dataSource = self;
    [self presentViewController:browserVc animated:NO completion:nil];
}

- (NSInteger) numberOfPhotosInPickerBrowser:(ZLPickerBrowserViewController *)pickerBrowser{
    return self.selectAssets.count;
}

- (ZLPickerBrowserPhoto *)photoBrowser:(ZLPickerBrowserViewController *)pickerBrowser photoAtIndex:(NSUInteger)index{
    ZLPickerBrowserPhoto *photo = [[ZLPickerBrowserPhoto alloc] init];
    photo.asset = self.selectAssets[index];
    return photo;
}

- (void)photoBrowser:(ZLPickerBrowserViewController *)photoBrowser removePhotoAtIndex:(NSUInteger)index{
    
    // 删除选中的照片
    ALAsset *asset = self.selectAssets[index];
    NSInteger currentPage = 0;
    for (NSInteger i = 0; i < self.collectionView.dataArray.count; i++) {
        ALAsset *photoAsset = self.collectionView.dataArray[i];
        if([[[[asset defaultRepresentation] url] absoluteString] isEqualToString:[[[photoAsset defaultRepresentation] url] absoluteString]]){
            currentPage = i;
            break;
        }
    }
    
    [self.selectAssets removeObjectAtIndex:index];
    [self.collectionView.selectsIndexPath removeObject:@(currentPage)];
    [self.toolBarThumbCollectionView reloadData];
    [self.collectionView reloadData];
    
    self.makeView.text = [NSString stringWithFormat:@"%d",self.selectAssets.count];
}

#pragma mark -<Navigation Actions>
#pragma mark -开启异步通知
- (void) back{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void) done{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:PICKER_TAKE_DONE object:nil userInfo:@{@"selectAssets":self.collectionView.selectAsstes}];
    });
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
