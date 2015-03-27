//
//  Example3ViewController.m
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 15-2-5.
//  Copyright (c) 2015年 com.zixue101.www. All rights reserved.
//

#import "Example3ViewController.h"
#import "Example1TableViewCell.h"
#import "ZLPhoto.h"

@interface Example3ViewController() <ZLPhotoPickerViewControllerDelegate,UITableViewDataSource,UITableViewDelegate,ZLPhotoPickerBrowserViewControllerDataSource,ZLPhotoPickerBrowserViewControllerDelegate>

@property (weak,nonatomic) UITableView *tableView;
@property (nonatomic , strong) NSMutableArray *assets;

@end

@implementation Example3ViewController

- (NSMutableArray *)assets{
    if (!_assets) {
        _assets = [NSMutableArray array];
    }
    return _assets;
}


- (UITableView *)tableView{
    if (!_tableView) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        tableView.backgroundColor = [UIColor whiteColor];
        tableView.dataSource = self;
        tableView.delegate = self;
        [self.view addSubview:tableView];
        self.tableView = tableView;
        
        tableView.translatesAutoresizingMaskIntoConstraints = NO;
        [tableView registerNib:[UINib nibWithNibName:@"Example1TableViewCell" bundle:nil] forCellReuseIdentifier:@"cell"];
        
        NSString *vfl = @"V:|-0-[tableView]-20-|";
        NSDictionary *views = NSDictionaryOfVariableBindings(tableView);
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl options:0 metrics:nil views:views]];
        NSString *vfl2 = @"H:|-0-[tableView]-0-|";
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl2 options:0 metrics:nil views:views]];
    }
    return _tableView;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupButtons];
    [self tableView];
}

- (void) setupButtons{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"选择照片" style:UIBarButtonItemStyleDone target:self action:@selector(selectPhotos)];
}

#pragma mark - select Photo Library
- (void)selectPhotos {
    // 创建控制器
    ZLPhotoPickerViewController *pickerVc = [[ZLPhotoPickerViewController alloc] init];
    // 默认显示相册里面的内容SavePhotos
    pickerVc.status = PickerViewShowStatusCameraRoll;
    pickerVc.selectPickers = self.assets;
    // 最多能选9张图片
    pickerVc.minCount = 9;
    pickerVc.delegate = self;
    [pickerVc show];
    /**
     *
     传值可以用代理，或者用block来接收，以下是block的传值
     __weak typeof(self) weakSelf = self;
     pickerVc.callBack = ^(NSArray *assets){
     weakSelf.assets = assets;
     [weakSelf.tableView reloadData];
     };
     */
}

- (void)pickerViewControllerDoneAsstes:(NSArray *)assets{
    self.assets = [NSMutableArray arrayWithArray:assets];
    [self.tableView reloadData];
}

#pragma mark - <UITableViewDataSource>
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.assets.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *ID = @"cell";
    Example1TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    ZLPhotoAssets *asset = self.assets[indexPath.row];
    if ([asset isKindOfClass:[ZLPhotoAssets class]]) {
        cell.imageview1.image = asset.thumbImage;
    }else if ([asset isKindOfClass:[NSString class]]){
        [cell.imageview1 sd_setImageWithURL:[NSURL URLWithString:(NSString *)asset] placeholderImage:[UIImage imageNamed:@"wallpaper_placeholder"]];
    }else if([asset isKindOfClass:[UIImage class]]){
        cell.imageview1.image = (UIImage *)asset;
    }
    return cell;
    
}


#pragma mark - <UITableViewDelegate>
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Example1TableViewCell *cell = (Example1TableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    [self setupPhotoBrowser:cell];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 95;
}

#pragma mark - setupCell click ZLPhotoPickerBrowserViewController
- (void) setupPhotoBrowser:(Example1TableViewCell *) cell{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    // 图片游览器
    ZLPhotoPickerBrowserViewController *pickerBrowser = [[ZLPhotoPickerBrowserViewController alloc] init];
    // 传入点击图片View的话，会有微信朋友圈照片的风格
    pickerBrowser.toView = cell.imageview1;
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

#pragma mark - 每个组展示什么图片,需要包装下ZLPhotoPickerBrowserPhoto
- (ZLPhotoPickerBrowserPhoto *) photoBrowser:(ZLPhotoPickerBrowserViewController *)pickerBrowser photoAtIndexPath:(NSIndexPath *)indexPath{
    ZLPhotoAssets *imageObj = [self.assets objectAtIndex:indexPath.row];
    // 包装下imageObj 成 ZLPhotoPickerBrowserPhoto 传给数据源
    ZLPhotoPickerBrowserPhoto *photo = [ZLPhotoPickerBrowserPhoto photoAnyImageObjWith:imageObj];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    photo.thumbImage = cell.imageView.image;
    return photo;
}

#pragma mark - <ZLPhotoPickerBrowserViewControllerDelegate>
#pragma mark 删除照片调用
- (void)photoBrowser:(ZLPhotoPickerBrowserViewController *)photoBrowser removePhotoAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row > [self.assets count]) return;
    [self.assets removeObjectAtIndex:indexPath.row];
    [self.tableView reloadData];
}

@end
