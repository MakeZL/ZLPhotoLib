//
//  Example5ViewController.m
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 15-3-25.
//  Copyright (c) 2015年 com.zixue101.www. All rights reserved.
//

#import "Example3ViewController.h"
#import "ZLPhoto.h"
#import "Example1TableViewCell.h"
#import <MediaPlayer/MediaPlayer.h>
#import "UIImageView+WebCache.h"

@interface Example3ViewController () <ZLPhotoPickerViewControllerDelegate,UITableViewDataSource,UITableViewDelegate>

@property (weak,nonatomic) UITableView *tableView;
@property (nonatomic , strong) NSMutableArray *assets;
@property (strong, nonatomic) MPMoviePlayerController *moviePlayer;

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
        
        [tableView registerNib:[UINib nibWithNibName:@"Example1TableViewCell" bundle:nil] forCellReuseIdentifier:@"cell"];
        
        tableView.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSString *vfl = @"V:|-0-[tableView]-20-|";
        NSDictionary *views = NSDictionaryOfVariableBindings(tableView);
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl options:0 metrics:nil views:views]];
        NSString *vfl2 = @"H:|-0-[tableView]-0-|";
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl2 options:0 metrics:nil views:views]];
    }
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupButtons];
    [self tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setupButtons{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"选择视频" style:UIBarButtonItemStyleDone target:self action:@selector(selectPhotos)];
}


#pragma mark - select Photo Library
- (void)selectPhotos {
    // 创建控制器
    ZLPhotoPickerViewController *pickerVc = [[ZLPhotoPickerViewController alloc] init];
    // 默认显示相册里面的内容SavePhotos
    // 最多能选9张图片
    pickerVc.maxCount = 9;
    pickerVc.status = PickerViewShowStatusCameraRoll;
    pickerVc.photoStatus = PickerPhotoStatusVideos;
    pickerVc.delegate = self;
    [pickerVc showPickerVc:self];
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
    self.assets = assets.mutableCopy;
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
        cell.imageview1.image = asset.originImage;
    }else if ([asset isKindOfClass:[NSString class]]){
        [cell.imageview1 sd_setImageWithURL:[NSURL URLWithString:(NSString *)asset] placeholderImage:[UIImage imageNamed:@"pc_circle_placeholder"]];
    }else if([asset isKindOfClass:[UIImage class]]){
        cell.imageview1.image = (UIImage *)asset;
    }
    
    return cell;
}


#pragma mark - <UITableViewDelegate>
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ZLPhotoAssets *asset = self.assets[indexPath.row];
    if ([asset isKindOfClass:[ZLPhotoAssets class]]){
        // 设置视频播放器
        self.moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:asset.assetURL];
        
        self.moviePlayer.allowsAirPlay = YES;
        [self.moviePlayer.view setFrame:self.view.frame];
        
        // 将moviePlayer的视图添加到当前视图中
        [self.view addSubview:self.moviePlayer.view];
        // 播放完视频之后，MPMoviePlayerController 将发送
        // MPMoviePlayerPlaybackDidFinishNotification 消息
        // 登记该通知，接到该通知后，调用playVideoFinished:方法
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playVideoFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:self.moviePlayer];
        
        [self.moviePlayer play];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 95;
}

- (void)playVideoFinished:(NSNotification *)theNotification{
    // 取消监听
    [[NSNotificationCenter defaultCenter]
     removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:self.moviePlayer];
    // 将视频视图从父视图中删除
    [self.moviePlayer.view removeFromSuperview];
}

@end
