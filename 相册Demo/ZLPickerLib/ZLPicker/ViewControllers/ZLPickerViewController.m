//
//  PickerViewController.m
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 14-11-11.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//


#define PICKER_TAKE_DONE @"PICKER_TAKE_DONE"

#import "ZLPickerViewController.h"
#import "ZLPickerGroupViewController.h"
#import "ZLPickerDatas.h"

@interface ZLPickerViewController ()

@property (nonatomic , weak) ZLPickerGroupViewController *groupVc;

@end

@implementation ZLPickerViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self createNavigationController];
    }
    return self;
}

#pragma mark 初始化导航控制器
- (void) createNavigationController{
    ZLPickerGroupViewController *groupVc = [[ZLPickerGroupViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:groupVc];
    nav.view.frame = self.view.bounds;
    [self addChildViewController:nav];
    [self.view addSubview:nav.view];
    self.groupVc = groupVc;
    
}

- (void)setStatus:(PickerViewShowStatus)status{
    _status = status;
    self.groupVc.status = status;
}

- (void)setMinCount:(NSInteger)minCount{
    if (minCount <= 0) return;
    _minCount = minCount;
    self.groupVc.minCount = minCount;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self addNotification];
}

#pragma mark - 展示控制器
- (void)show{
    [[[[UIApplication sharedApplication].windows firstObject] rootViewController] presentViewController:self animated:YES completion:nil];
}

- (void) addNotification{
    // 监听异步done通知
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(done:) name:PICKER_TAKE_DONE object:nil];
    });
}

- (void) done:(NSNotification *)note{
    NSArray *selectArray =  note.userInfo[@"selectAssets"];
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(pickerViewControllerDoneAsstes:)]) {
            [self.delegate pickerViewControllerDoneAsstes:selectArray];
        }else if (self.callBack){
            self.callBack(selectArray);
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setDelegate:(id<ZLPickerViewControllerDelegate>)delegate{
    _delegate = delegate;
    self.groupVc.delegate = delegate;
}
#pragma mark - 通过传入一个图片对象（ALAsset、URL）获取一张缩略图
- (UIImage *) getImageWithImageObj:(id)imageObj{
    
    return [[ZLPickerDatas defaultPicker] getImageWithImageObj:imageObj];
}
@end
