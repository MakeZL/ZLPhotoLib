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
#import <AssetsLibrary/AssetsLibrary.h>

@interface PickerGroupViewController () <UITableViewDataSource,UITableViewDelegate>
@property (nonatomic , weak) PickerCollectionView *collectionView;
@property (nonatomic , weak) UITableView *tableView;
@property (nonatomic , strong) NSArray *groups;

@end

@implementation PickerGroupViewController

- (UITableView *)tableView{
    if (!_tableView) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64) style:UITableViewStylePlain];
        tableView.delegate = self;
        tableView.dataSource = self;
        [self.view addSubview:tableView];
        self.tableView = tableView;
    }
    return _tableView;
}

#pragma mark -getter
- (PickerCollectionView *)collectionView{
    if (!_collectionView) {
        
        CGFloat cellW = (self.view.frame.size.width - CELL_MARGIN * CELL_ROW + 1) / CELL_ROW;
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(cellW, cellW);
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = CELL_LINE_MARGIN;
        
        PickerCollectionView *collectionView = [[PickerCollectionView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64) collectionViewLayout:layout];
        [self.view addSubview:collectionView];
        self.collectionView = collectionView;
        
    }
    return _collectionView;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.backgroundColor = [UIColor redColor];
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.backgroundColor = [UIColor grayColor];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setTitle:@"back" forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
//    [self.view addSubview:leftBtn];
    
    UIButton *customBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    customBtn.backgroundColor = [UIColor grayColor];
    customBtn.frame = CGRectMake(280, 0, 40, 40);
    [customBtn setTitle:@"完成" forState:UIControlStateNormal];
    [customBtn addTarget:self action:@selector(done) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:customBtn];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:customBtn];
    
    // 获取图片
    [self getImgs];
}

#pragma mark - <UITableViewDataSource>
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.groups.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *ID = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ID];
    }
    
    PickerGroup *group = self.groups[indexPath.row];
    cell.textLabel.text = group.groupName;
    cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    cell.imageView.image = [group.groups lastObject];
    
    return cell;
    
}

#pragma mark -<UITableViewDelegate>
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

#pragma mark -<Images Datas>

-(void)getImgs{
    
    PickerDatas *datas = [PickerDatas defaultPicker];
    
    // 获取所有的图片URLs
    [datas getAllGroupWithPhotos:^(id obj) {
        NSLog(@"%@",obj);
        self.groups = obj;
        
        [self.tableView reloadData];
//        self.collectionView.dataArray = obj;
    }];
}


#pragma mark -<Navigation Actions>
- (void) back{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) done{
    if ([self.delegate respondsToSelector:@selector(pickerViewControllerDonePictures:)]) {
        
        [self.delegate pickerViewControllerDonePictures:self.collectionView.selectPictureArray];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"%@",self.collectionView.selectPictureArray);
}



@end
