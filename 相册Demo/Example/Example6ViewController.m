//
//  Example6ViewController.m
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 15-1-19.
//  Copyright (c) 2015年 com.zixue101.www. All rights reserved.
//

#import "Example6ViewController.h"
#import "Example1TableViewCell.h"
#import "ZLPhoto.h"

@interface Example6ViewController()

@property (weak,nonatomic) UITableView *tableView;
@property (nonatomic , strong) NSMutableArray *assets;

@end

@implementation Example6ViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *headerView = [[UIButton alloc] init];
    headerView.frame = CGRectMake(100, 100, 50, 50);
    [headerView setImage:[UIImage imageNamed:@"example6.jpeg"] forState:UIControlStateNormal];
    [headerView addTarget:self action:@selector(showHeadPortrait:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:headerView];
}

#pragma mark 传入imageView放大
- (void)showHeadPortrait:(UIButton *)btn{
    ZLPhotoPickerBrowserViewController *browserVc = [[ZLPhotoPickerBrowserViewController alloc] init];
    [browserVc showHeadPortrait:btn.imageView];
}
@end
