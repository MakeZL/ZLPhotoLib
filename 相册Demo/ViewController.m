//
//  ViewController.m
//  相册Demo
//
//  Created by 张磊 on 14-11-11.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import "ViewController.h"
#import "ZLPickerViewController.h"
#import "UIView+Extension.h"
#import "ZLPickerBrowserViewController.h"
#import "ZLPickerCommon.h"
#import "ZLBaseAnimationImageView.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface ViewController () <UITableViewDataSource,UITableViewDelegate,PickerViewControllerDelegate,ZLPickerBrowserViewControllerDataSource,ZLPickerBrowserViewControllerDelegate>

- (void)selectPhotos;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic , strong) NSMutableArray *assets;
@property (nonatomic , weak) UILabel *zixueLabel;

@property (nonatomic,strong) UIImageView *currentImageView;
@property (nonatomic , strong) ZLPickerBrowserViewController *pickerBrowser;
@property (nonatomic , assign) CGRect tempFrame;
@property (nonatomic , strong) NSMutableDictionary *params;

@end

@implementation ViewController

#pragma mark -getter
- (UIImageView *)currentImageView{
    if (!_currentImageView) {
        _currentImageView = [[UIImageView alloc] init];
        _currentImageView.alpha = 0;
        [self.view.superview addSubview:_currentImageView];
    }
    return _currentImageView;
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
        
        NSString *vfl = @"V:|-topPadding-[tableView]-padding-|";
        NSDictionary *views = NSDictionaryOfVariableBindings(tableView);
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl options:0 metrics:self.params views:views]];
        NSString *vfl2 = @"H:|-padding-[tableView]-padding-|";
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl2 options:0 metrics:self.params views:views]];
    }
    return _tableView;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    // 设置AutoLayout参数
    [self setAutoLayoutParams];
    
    [self setupButtons];
}

#pragma mark -setter
#pragma mark 设置AutoLayout参数
- (void) setAutoLayoutParams{
    self.params = [NSMutableDictionary dictionary];
    self.params[@"padding"] = @"20";
    self.params[@"topPadding"] = @"0";
}
- (void) setupButtons{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"选择照片" style:UIBarButtonItemStyleDone target:self action:@selector(selectPhotos)];
}


- (void)selectPhotos {
    // 创建控制器
    ZLPickerViewController *pickerVc = [[ZLPickerViewController alloc] init];
    // 默认显示相册里面的内容SavePhotos
    pickerVc.status = PickerViewShowStatusCameraRoll;
    // 选择图片的最大数
    // pickerVc.maxCount = 4;

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
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    [self setupPhotoBrowser:cell];
}

#pragma mark 设置当前的缩放View符image
- (void) setupCurrentImageViewPhotoAtIndex:(NSInteger)index{
    ZLPickerBrowserPhoto *photo = [self photoBrowser:self.pickerBrowser photoAtIndex:index];
    self.currentImageView.image = photo.photoImage;
}

- (void) setupPhotoBrowser:(UITableViewCell *) cell{
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    // 图片游览器
    ZLPickerBrowserViewController *pickerBrowser = [[ZLPickerBrowserViewController alloc] init];
    // 默认拉伸 ： 淡入淡出 ZLPickerBrowserAnimationStatusFade
    pickerBrowser.animationStatus = ZLPickerBrowserAnimationStatusFade;
    pickerBrowser.toView = cell.imageView;
    pickerBrowser.fromView = self.view;
    pickerBrowser.delegate = self;
    pickerBrowser.dataSource = self;
    pickerBrowser.editing = YES;
    // 当前选中的值
    pickerBrowser.currentPage = indexPath.row;
    self.pickerBrowser = pickerBrowser;
    [self presentViewController:pickerBrowser animated:NO completion:nil];
}


#pragma mark <ZLPickerBrowserViewControllerDataSource>
- (NSInteger) numberOfPhotosInPickerBrowser:(ZLPickerBrowserViewController *)pickerBrowser{
    return self.assets.count;
}

- (ZLPickerBrowserPhoto *) photoBrowser:(ZLPickerBrowserViewController *)pickerBrowser photoAtIndex:(NSUInteger)index{
    
    id imageObj = [self.assets objectAtIndex:index];
    ZLPickerBrowserPhoto *photo = [[ZLPickerBrowserPhoto alloc] init];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    photo.thumbImage = cell.imageView.image;
    
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

#pragma mark <ZLPickerBrowserViewControllerDelegate>
- (void)photoBrowser:(ZLPickerBrowserViewController *)photoBrowser removePhotoAtIndex:(NSUInteger)index{
    if (index > self.assets.count) return;
    [self.assets removeObjectAtIndex:index];
    [self.tableView reloadData];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *ID = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        cell.backgroundColor = [UIColor clearColor];
    }
    
    ALAsset *asset = self.assets[indexPath.row];
    if ([asset isKindOfClass:[ALAsset class]]) {
        cell.imageView.image = [UIImage imageWithCGImage:[asset thumbnail]];
    }
    return cell;
    
}

// 代理回调方法
- (void)pickerViewControllerDoneAsstes:(NSArray *)assets{
    if (!self.assets) {
        self.assets = [NSMutableArray array];
    }
    [self.assets addObjectsFromArray:assets];
//    self.assets = [NSMutableArray arrayWithArray:assets];
    [self.tableView reloadData];
}



//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
//    
//    UIView *boxView = [[UIView alloc] init];
//    
//    NSValue *startV = [NSValue valueWithCGRect:CGRectMake(50, 50, 100, 100)];
//    NSValue *endV = [NSValue valueWithCGRect:CGRectMake(100, 100, 200, 200)];
//    NSNumber *duration = [NSNumber numberWithFloat:2.5];
//    
//    NSDictionary *options = @{
//                              UIViewAnimationStartFrame:startV,
//                              UIViewAnimationEndFrame:endV,
//                              UIViewAnimationDuration:duration,
//                              UIViewAnimationInView:self.view,                            UIViewAnimationBackGroundColor:[UIColor yellowColor]
//                              };
//    
//    [BaseAnimationView animationViewWithOptions:options completion:^(BaseAnimationView *baseView) {
//        baseView.backgroundColor = [UIColor redColor];
//        [baseView viewformIdentity:^(BaseAnimationView *baseView) {
//            NSLog(@" 结束了！！");
//        }];
//    }];
//    [self.view addSubview:boxView];
//}

@end
