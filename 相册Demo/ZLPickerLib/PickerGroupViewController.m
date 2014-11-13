//
//  PickerGroupViewController.m
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 14-11-11.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#define CELL_ROW 4
#define CELL_MARGIN 5
#define CELL_LINE_MARGIN 5


#import "PickerGroupViewController.h"
#import "PickerCollectionView.h"
#import "PickerDatas.h"
#import "PickerGroupViewController.h"
#import "PickerGroup.h"
#import "PickerGroupTableViewCell.h"
#import "PickerAssetsViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface PickerGroupViewController () <UITableViewDataSource,UITableViewDelegate>
@property (nonatomic , weak) PickerAssetsViewController *collectionVc;
@property (nonatomic , weak) UITableView *tableView;
@property (nonatomic , strong) NSArray *groups;

@end

@implementation PickerGroupViewController

- (UITableView *)tableView{
    if (!_tableView) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.delegate = self;
        tableView.dataSource = self;
        [self.view addSubview:tableView];
        self.tableView = tableView;
    }
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置按钮
    [self setupButtons];
    
    // 获取图片
    [self getImgs];
    
    self.title = @"选择相册";
}

- (void) setupButtons{
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStyleDone target:self action:@selector(back)];
    
    self.navigationItem.rightBarButtonItem = barItem;
}

#pragma mark - <UITableViewDataSource>
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.groups.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    PickerGroupTableViewCell *cell = [PickerGroupTableViewCell instanceCell];
    
    cell.group = self.groups[indexPath.row];
    
    return cell;
    
}

- (void)setGroups:(NSArray *)groups{
    _groups = groups;
    
    if (self.status) {
        [self jump2StatusVc];
    }
}

#pragma mark 跳转到控制器里面的内容
- (void) jump2StatusVc{
    
    // 如果是相册
    PickerGroup *gp = nil;
    for (PickerGroup *group in self.groups) {
        if ([group.type isEqualToString:@"Saved Photos"]) {
            gp = group;
            break;
        }
    }
    
    PickerAssetsViewController *assetsVc = [[PickerAssetsViewController alloc] init];
    assetsVc.group = gp;
    [self.navigationController pushViewController:assetsVc animated:NO];
}

#pragma mark -<UITableViewDelegate>
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PickerGroup *group = self.groups[indexPath.row];
    PickerAssetsViewController *assetsVc = [[PickerAssetsViewController alloc] init];
    assetsVc.group = group;
    [self.navigationController pushViewController:assetsVc animated:YES];
}

#pragma mark -<Images Datas>

-(void)getImgs{
    
    PickerDatas *datas = [PickerDatas defaultPicker];
    
    // 获取所有的图片URLs
    [datas getAllGroupWithPhotos:^(id obj) {
        self.groups = obj;
        [self.tableView reloadData];
    }];
}


#pragma mark -<Navigation Actions>
- (void) back{
    [self dismissViewControllerAnimated:YES completion:nil];
}




@end
