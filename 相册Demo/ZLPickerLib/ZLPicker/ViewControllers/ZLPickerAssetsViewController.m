//
//  PickerAssetsViewController.m
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 14-11-12.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//


// CellFrame
#define CELL_ROW 4
#define CELL_MARGIN 2
#define CELL_LINE_MARGIN CELL_MARGIN

// 通知
#define PICKER_TAKE_DONE @"PICKER_TAKE_DONE"
// TOOLBAR 展示最大图片数
#define TOOLBAR_COUNT 9
// 间距
#define TOOLBAR_IMG_MARGIN 2

#define TOOLBAR_HEIGHT 44

#import "ZLPickerAssetsViewController.h"
#import "ZLPickerCollectionView.h"
#import "ZLPickerGroup.h"
#import "ZLPickerDatas.h"
#import "ZLPickerCollectionViewCell.h"
#import "ZLPickerFooterCollectionReusableView.h"
#import <AssetsLibrary/AssetsLibrary.h>

static NSString *const _cellIdentifier = @"cell";
static NSString *const _footerIdentifier = @"FooterView";

@interface ZLPickerAssetsViewController () <PickerCollectionViewDelegate>

@property (nonatomic , weak) ZLPickerCollectionView *collectionView;
@property (nonatomic , strong) NSMutableArray *assets;
/**
 *  标记View
 */
@property (nonatomic , weak) UILabel *makeView;
@property (nonatomic , weak) UIButton *doneBtn;
@property (nonatomic , weak) UIToolbar *toolBar;

@property (nonatomic , strong) NSMutableArray *buttons;


@end

@implementation ZLPickerAssetsViewController

#pragma mark - getter
- (NSMutableArray *)buttons{
    if (!_buttons) {
        _buttons = [NSMutableArray array];
    }
    return _buttons;
}

#pragma mark collectionView
- (ZLPickerCollectionView *)collectionView{
    if (!_collectionView) {
        
        CGFloat cellW = (self.view.frame.size.width - CELL_MARGIN * CELL_ROW + 1) / CELL_ROW;
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(cellW, cellW);
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = CELL_LINE_MARGIN;
        layout.footerReferenceSize = CGSizeMake(self.view.frame.size.width, TOOLBAR_HEIGHT * 2);
        
        ZLPickerCollectionView *collectionView = [[ZLPickerCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        collectionView.translatesAutoresizingMaskIntoConstraints = NO;
        [collectionView registerClass:[ZLPickerCollectionViewCell class] forCellWithReuseIdentifier:_cellIdentifier];
        // 底部的View
        [collectionView registerClass:[ZLPickerFooterCollectionReusableView class]  forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:_footerIdentifier];
        
        collectionView.contentInset = UIEdgeInsetsMake(5, 0,TOOLBAR_HEIGHT, 0);
        collectionView.collectionViewDelegate = self;
        [self.view insertSubview:collectionView belowSubview:self.toolBar];
        self.collectionView = collectionView;
        
        NSDictionary *views = NSDictionaryOfVariableBindings(collectionView);
        
        NSString *widthVfl = @"H:|-0-[collectionView]-0-|";
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:widthVfl options:0 metrics:nil views:views]];
        
        NSString *heightVfl = @"V:|-0-[collectionView]-0-|";
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:heightVfl options:0 metrics:nil views:views]];
        
    }
    return _collectionView;
}

#pragma mark -红点标记View
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

    // 初始化按钮
    [self setupButtons];
    
    // 初始化底部ToorBar
    [self setupToorBar];
}


#pragma mark - setter
#pragma mark 初始化按钮
- (void) setupButtons{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(back)];
}

#pragma mark 初始化所有的组
- (void) setupAssets{
    if (!self.assets) {
        self.assets = [NSMutableArray array];
    }
    
    ZLPickerDatas *datas = [ZLPickerDatas defaultPicker];
    [datas getGroupPhotosWithGroup:self.assetsGroup finished:^(NSArray *assets) {
        
        self.collectionView.dataArray = assets;
        [self.collectionView reloadData];
    }];
    
}

#pragma mark -初始化底部ToorBar
- (void) setupToorBar{
    UIToolbar *toorBar = [[UIToolbar alloc] init];
    toorBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:toorBar];
    self.toolBar = toorBar;
    
    NSDictionary *views = NSDictionaryOfVariableBindings(toorBar);
    NSString *widthVfl =  @"H:|-0-[toorBar]-0-|";
    NSString *heightVfl = @"V:[toorBar(44)]-0-|";
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:widthVfl options:0 metrics:0 views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:heightVfl options:0 metrics:0 views:views]];
    
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setTitleColor:[UIColor colorWithRed:0/255.0 green:91/255.0 blue:255/255.0 alpha:1.0] forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    rightBtn.enabled = YES;
    
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    rightBtn.frame = CGRectMake(0, 0, 45, 45);
    [rightBtn setTitle:@"完成" forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(done) forControlEvents:UIControlEventTouchUpInside];
    [rightBtn addSubview:self.makeView];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    
    UIBarButtonItem *fiexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    toorBar.items = @[fiexItem,rightItem];
    
    self.doneBtn = rightBtn;
}

#pragma mark - setter
- (void)setMaxCount:(NSInteger)maxCount{
    _maxCount = maxCount;
    
    self.collectionView.maxCount = self.maxCount;
}

- (void)setAssetsGroup:(ZLPickerGroup *)assetsGroup{
    if (!assetsGroup.groupName.length) return ;
    
    _assetsGroup = assetsGroup;
    
    self.title = assetsGroup.groupName;
    
    // 获取Assets
    [self setupAssets];
}


- (void)pickerCollectionViewDidSelected:(ZLPickerCollectionView *)pickerCollectionView{
    NSInteger count = pickerCollectionView.selectAsstes.count;
    self.makeView.hidden = !count;
    self.makeView.text = [NSString stringWithFormat:@"%ld",(long)count];
    self.doneBtn.enabled = (count > 0);
    
    if (count < self.buttons.count) {
        for (NSInteger i = self.buttons.count; i > count; i--) {
            [self.buttons[i-1] removeFromSuperview];
        }
    }
    
    // 创建btn
    for (int i = 0; i < count; i++) {
        ALAsset *asset = pickerCollectionView.selectAsstes[i];
        
        UIButton *btn = nil;
        if (self.buttons.count <= i) {
            btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [self.toolBar addSubview:btn];
            [self.buttons addObject:btn];
        }else if(self.buttons.count){
            btn = self.buttons[i];
            if (![btn.superview isKindOfClass:[self class]]) {
                [self.toolBar addSubview:btn];
            }
        }
        
        CGFloat btnW = (self.view.frame.size.width - 80 - TOOLBAR_IMG_MARGIN * 10) / TOOLBAR_COUNT;
        CGFloat btnX = btnW * i + (i * TOOLBAR_IMG_MARGIN + TOOLBAR_IMG_MARGIN);
        CGFloat btnY = (self.toolBar.frame.size.height - btnW) / 2.0;
        [btn setImage:[UIImage imageWithCGImage:[asset thumbnail]] forState:UIControlStateNormal];
        btn.frame = CGRectMake(btnX, btnY, btnW, btnW);
        
    }
}

#pragma mark -<Navigation Actions>
#pragma mark -开启异步通知
- (void) back{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void) done{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:PICKER_TAKE_DONE object:nil userInfo:@{@"selectAssets":self.collectionView.selectAsstes}];
    });
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
