//
//  PickerAssetsViewController.m
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 14-11-12.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//


#define CELL_ROW 4
#define CELL_MARGIN 5
#define CELL_LINE_MARGIN 5

#define PICKER_TAKE_DONE @"PICKER_TAKE_DONE"


#import "PickerAssetsViewController.h"
#import "PickerCollectionView.h"
#import "PickerGroup.h"
#import "PickerDatas.h"

@interface PickerAssetsViewController () <PickerCollectionViewDelegate>

@property (nonatomic , weak) PickerCollectionView *collectionView;
@property (nonatomic , strong) NSArray *assets;
/**
 *  标记View
 */
@property (nonatomic , weak) UILabel *makeView;

@property (nonatomic , weak) UIButton *rightBtn;

@end

@implementation PickerAssetsViewController

#pragma mark -getter
- (PickerCollectionView *)collectionView{
    if (!_collectionView) {
        
        CGFloat cellW = (self.view.frame.size.width - CELL_MARGIN * CELL_ROW + 1) / CELL_ROW;
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(cellW, cellW);
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = CELL_LINE_MARGIN;
        
        PickerCollectionView *collectionView = [[PickerCollectionView alloc] initWithFrame:CGRectMake(0, 5, self.view.frame.size.width, self.view.frame.size.height - 5) collectionViewLayout:layout];
        collectionView.collectionViewDelegate = self;
        [self.view addSubview:collectionView];
        self.collectionView = collectionView;
        
    }
    return _collectionView;
}

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
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    
    [self setupButtons];
}

- (void)pickerCollectionView:(PickerCollectionView *)pickerCollectionView didSelctedPicturesCount:(NSInteger)count{
    
    self.makeView.hidden = !count;
    self.makeView.text = [NSString stringWithFormat:@"%d",count];
    self.navigationItem.rightBarButtonItem.enabled = count;
    self.rightBtn.enabled = count;
    
}

- (void) setupButtons{
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setTitleColor:[UIColor colorWithRed:0/255.0 green:91/255.0 blue:255/255.0 alpha:1.0] forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    rightBtn.frame = CGRectMake(0, 0, 45, 45);
    [rightBtn setTitle:@"done" forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(done) forControlEvents:UIControlEventTouchUpInside];
    
    [rightBtn addSubview:self.makeView];
    
    
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = barItem;
    
    rightBtn.enabled = (self.collectionView.selectPictureArray.count > 0);
    self.navigationItem.rightBarButtonItem.enabled = (self.collectionView.selectPictureArray.count > 0);
    
    self.rightBtn = rightBtn;
}

- (void)setAssets:(NSArray *)assets{
    _assets = assets;
    
    self.collectionView.dataArray = assets;
}

- (void)setGroup:(PickerGroup *)group{
    _group = group;
    
    PickerDatas *datas = [PickerDatas defaultPicker];
    
    __weak typeof(self) weakSelf = self;
    [datas getGroupPhotosWithGroup:group finished:^(PickerGroup *group) {
        weakSelf.assets = group.assets;
    }];
}

#pragma mark -<Navigation Actions>
#pragma mark -开启异步通知
- (void) done{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:PICKER_TAKE_DONE object:nil userInfo:@{@"selectAssets":self.collectionView.selectPictureArray}];
    });
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
