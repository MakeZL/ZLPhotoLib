//
//  ViewController.m
//  相册Demo
//
//  Created by 张磊 on 14-11-11.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import "ViewController.h"
#import "PickerViewController.h"
#import "UIView+Extension.h"
#import "PickerBrowserViewController.h"
//#import "BaseAnimationView.h"
#import "BaseAnimationImageView.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface ViewController () <UITableViewDataSource,UITableViewDelegate,PickerViewControllerDelegate,PickerBrowserViewControllerDataSource,PickerBrowserViewControllerDelegate>

- (void)selectPhotos;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic , strong) NSMutableArray *assets;
@property (nonatomic , weak) UILabel *zixueLabel;

@property (nonatomic,strong) UIImageView *currentImageView;
@property (nonatomic , strong) PickerBrowserViewController *pickerBrowser;
@property (nonatomic , assign) CGRect tempFrame;

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
//
- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupButtons];
    [self setupUI];
}
//
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
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    [self setupPhotoBrowser:cell];
}

#pragma mark 设置当前的缩放View符image
- (void) setupCurrentImageViewPhotoAtIndex:(NSInteger)index{
    PickerPhoto *photo = [self photoBrowser:self.pickerBrowser photoAtIndex:index];
    self.currentImageView.image = photo.photoImage;
}

- (void) setupPhotoBrowser:(UITableViewCell *) cell{
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];

    // 起始位置、结束位置、动画时间、图片参数
    // 如果不设起始位置、则会去判断类型、如果没有类型就按0,0点
    NSValue *descFrame = [NSValue valueWithCGRect:CGRectMake(10, 0, self.view.width - 20, self.view.height)];
    
    NSNumber *duration = [NSNumber numberWithFloat:.5];
    
    // 参数
    NSDictionary *options = @{
                              UIViewAnimationEndFrame:descFrame,
                              UIViewAnimationTypeViewWithIndexPath:indexPath,
                              UIViewAnimationDuration:duration,
                              UIViewAnimationInView:self.view,
                              UIViewAnimationTypeView:self.tableView,
                              UIViewAnimationImages:self.assets,
                              UIViewAnimationNavigation:self.navigationController
                              };
    
    __unsafe_unretained typeof(self) weakSelf = self;
    // 动画结束调用
    [BaseAnimationImageView animationViewWithOptions:options completion:^(BaseAnimationView *baseView) {
        // 图片游览器
        PickerBrowserViewController *pickerBrowser = [[PickerBrowserViewController alloc] init];
        pickerBrowser.delegate = self;
        pickerBrowser.dataSource = self;
        // 当前选中的值
        pickerBrowser.currentPage = indexPath.row;
        // disMiss后调用
        pickerBrowser.disMissBlock = ^(NSInteger page){
            baseView.currentPage = page;
            [baseView viewformIdentity:^(BaseAnimationView *baseView) {
                [weakSelf.pickerBrowser dismissViewControllerAnimated:NO completion:nil];
            }];
        };
        weakSelf.pickerBrowser = pickerBrowser;
        [weakSelf presentViewController:pickerBrowser animated:NO completion:nil];
    }];
    
//    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
//
//    self.currentImageView.frame = tempFrame;
//    
//    // 给当前的缩放View符image
//    [self setupCurrentImageViewPhotoAtIndex:indexPath.row];
//    
//    // 模仿微信朋友圈的点击图片风格
//    __unsafe_unretained typeof(self) weakSelf = self;
//    self.view.backgroundColor = [UIColor blackColor];
//    self.tableView.backgroundColor = [UIColor blackColor];
//    weakSelf.navigationController.navigationBarHidden = YES;
//    weakSelf.currentImageView.hidden = NO;
//    
//    CGFloat x = 10;
//    CGFloat w = self.view.width - x * 2;
//    
//    [UIView animateWithDuration:0.5 animations:^{
//        weakSelf.currentImageView.alpha = 1;
//        weakSelf.tableView.hidden = YES;
//        
//        weakSelf.currentImageView.frame = CGRectMake(x, 0, w, self.view.height);
//
//    } completion:^(BOOL finished) {
//        
//        PickerBrowserViewController *pickerBrowser = [[PickerBrowserViewController alloc] init];
//        // 销毁时调用
//        pickerBrowser.disMissBlock = ^(NSInteger page){
//            
//            // 给图片赋值当前的Cell的Frame属性
//            NSIndexPath *selectIndexPath = [NSIndexPath indexPathForRow:page inSection:0];
//            UITableViewCell *selectCell = [weakSelf.tableView cellForRowAtIndexPath:selectIndexPath];
//            CGRect tempFrame = selectCell.frame;
//            tempFrame.origin.y -= ( weakSelf.tableView.contentOffset.y - self.tableView.y);
//
//            // 设置图片
//            [self setupCurrentImageViewPhotoAtIndex:indexPath.row];
//            
//            [UIView animateWithDuration:0.5 animations:^{
//                weakSelf.currentImageView.hidden = NO;
//                // 如果大于可展示的Cell的个数
//                if (page >= [[weakSelf.tableView visibleCells] count]) {
//                    weakSelf.currentImageView.frame = tempFrame;
//                    weakSelf.currentImageView.y += CGRectGetHeight(cell.frame) * (page - [[weakSelf.tableView visibleCells] count]) + CGRectGetHeight(cell.frame);
//                }else{
//                    weakSelf.currentImageView.frame = tempFrame;
//                }
//                weakSelf.currentImageView.x -= CGRectGetMaxX(cell.imageView.frame);
//                weakSelf.currentImageView.alpha = 0;
//            } completion:^(BOOL finished) {
//                [weakSelf.pickerBrowser dismissViewControllerAnimated:NO completion:nil];
//            }];
//            
//        };
//        pickerBrowser.delegate = self;
//        // 开启编辑模式，能删除照片
//        //        pickerBrowser.editing = YES;
//        pickerBrowser.dataSource = self;
//        // 当前选中的值
//        pickerBrowser.currentPage = indexPath.row;
//        [self presentViewController:pickerBrowser animated:NO completion:^{
//            weakSelf.view.backgroundColor = [UIColor whiteColor];
//            weakSelf.tableView.backgroundColor = [UIColor whiteColor];
//            weakSelf.tableView.hidden = NO;
//            weakSelf.currentImageView.hidden = YES;
//            weakSelf.navigationController.navigationBarHidden = NO;
//        }];
//        
//        self.pickerBrowser = pickerBrowser;
//    }];
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

@end
