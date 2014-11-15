//
//  ViewController.m
//  相册Demo
//
//  Created by 张磊 on 14-11-11.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import "ViewController.h"
#import "PickerViewController.h"
#import "PickerBrowserViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface ViewController () <UITableViewDataSource,UITableViewDelegate,PickerViewControllerDelegate,PickerBrowserViewControllerDataSource,PickerBrowserViewControllerDelegate>

- (void)selectPhotos;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic , strong) NSMutableArray *assets;
@property (nonatomic , weak) UILabel *zixueLabel;

@property (nonatomic , weak) UIImageView *imageView;

@end

@implementation ViewController

#pragma mark -getter
- (UITableView *)tableView{
    if (!_tableView) {
        CGFloat w = 300;
        CGFloat x = (self.view.frame.size.width - w ) / 2.0;
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(x, 100, w, w) style:UITableViewStylePlain];
        tableView.dataSource = self;
        tableView.delegate = self;
        [self.view addSubview:tableView];
        self.tableView = tableView;
    }
    return _tableView;
}

- (UIImageView *)imageView{
    if (!_imageView) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
//        imageView.hidden = YES;
        [self.view addSubview:imageView];
        self.imageView = imageView;
    }
    return _imageView;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupButtons];
    [self setupUI];
}

- (void) setupButtons{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"选择照片" style:UIBarButtonItemStyleDone target:self action:@selector(selectPhotos)];
}

- (void) setupUI{
    
    UILabel *zixueLabel = [[UILabel alloc] init];
    zixueLabel.textAlignment = NSTextAlignmentCenter;
    zixueLabel.numberOfLines = 0;
    zixueLabel.frame = CGRectMake(0, self.view.frame.size.height - 100, self.view.frame.size.width, 100);
    zixueLabel.text = @"有任何好的建议或者代码改进请联系我的QQ：120886865\n我的自学网站：www.zixue101.com";
    [self.view addSubview:zixueLabel];
    self.zixueLabel = zixueLabel;
}



- (void)selectPhotos {
    // 创建控制器
    PickerViewController *pickerVc = [[PickerViewController alloc] init];
    // 默认显示相册里面的内容SavePhotos
    pickerVc.status = PickerViewShowStatusSavePhotos;
    // 选择图片的最大数
//    pickerVc.maxCount = 4;

    pickerVc.delegate = self;
    [self presentViewController:pickerVc animated:YES completion:nil];
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

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.assets.count;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    PickerBrowserViewController *pickerBrowser = [[PickerBrowserViewController alloc] init];
    pickerBrowser.delegate = self;
    // 开启编辑模式，能删除照片
    pickerBrowser.editing = YES;
    pickerBrowser.dataSource = self;
    // 当前选中的值
    pickerBrowser.currentPage = indexPath.row;
    [pickerBrowser reloadData];
    [self presentViewController:pickerBrowser animated:YES completion:nil];
}


#pragma mark <PickerBrowserViewControllerDataSource>
- (NSInteger) numberOfPhotosInPickerBrowser:(PickerBrowserViewController *)pickerBrowser{
    return self.assets.count;
}

- (PickerPhoto *) photoBrowser:(PickerBrowserViewController *)pickerBrowser photoAtIndex:(NSUInteger)index{
    
    id imageObj = [self.assets objectAtIndex:index];
    PickerPhoto *photo = [[PickerPhoto alloc] init];
    if ([imageObj isKindOfClass:[ALAsset class]]) {
        ALAsset *asset = (ALAsset *)imageObj;
        photo.thumbImage = [UIImage imageWithCGImage:[asset thumbnail]];
        photo.photoImage = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
    }else if ([imageObj isKindOfClass:[NSURL class]]){
        photo.photoURL = imageObj;
    }else if ([imageObj isKindOfClass:[UIImage class]]){
        photo.photoImage = imageObj;
    }

    return photo;
}

#pragma mark <PickerBrowserViewControllerDelegate>
- (void)photoBrowser:(PickerBrowserViewController *)photoBrowser removePhotoAtIndex:(NSUInteger)index{
    if (index > self.assets.count) return;
    [self.assets removeObjectAtIndex:index];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *ID = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    
    ALAsset *asset = self.assets[indexPath.row];
    if ([asset isKindOfClass:[ALAsset class]]) {
        cell.imageView.image = [UIImage imageWithCGImage:[asset thumbnail]];
    }
    return cell;
    
}

// 代理回调方法
- (void)pickerViewControllerDoneAsstes:(NSArray *)assets{
    self.assets = [NSMutableArray arrayWithArray:assets];
    [self.tableView reloadData];
}

@end
