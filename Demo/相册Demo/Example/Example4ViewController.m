//
//  Example4ViewController.m
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 15-1-19.
//  Copyright (c) 2015年 com.zixue101.www. All rights reserved.
//

#import "Example4ViewController.h"
#import "Example1TableViewCell.h"
#import "UIImage+ZLPhotoLib.h"
#import "ZLPhoto.h"

@interface Example4ViewController()

@property (weak,nonatomic) UITableView *tableView;
@property (nonatomic , strong) NSMutableArray *assets;

@end

@implementation Example4ViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *headerView = [[UIButton alloc] init];
    headerView.frame = CGRectMake(100, 100, 50, 50);
    [headerView setImage:[UIImage ml_imageFromBundleNamed:@"example6.jpeg"] forState:UIControlStateNormal];
    [headerView addTarget:self action:@selector(showHeadPortrait:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:headerView];
}

#pragma mark 传入imageView放大
- (void)showHeadPortrait:(UIButton *)btn{
    ZLPhotoPickerBrowserViewController *browserVc = [[ZLPhotoPickerBrowserViewController alloc] init];
    [browserVc showHeadPortrait:btn.imageView originUrl:@"https://avatars0.githubusercontent.com/u/7121927?v=3&s=460"];
}
@end
