//
//  PickerViewController.m
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 14-11-11.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//


#define PICKER_TAKE_DONE @"PICKER_TAKE_DONE"

#import "PickerViewController.h"
#import "PickerGroupViewController.h"

@interface PickerViewController ()

@property (nonatomic , weak) PickerGroupViewController *groupVc;

@end

@implementation PickerViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self createNavigationController];
    }
    return self;
}

- (void) createNavigationController{
    
    PickerGroupViewController *groupVc = [[PickerGroupViewController alloc] init];
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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self addNotification];
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
        if ([self.delegate respondsToSelector:@selector(pickerViewControllerDonePictures:)]) {
            [self.delegate pickerViewControllerDonePictures:selectArray];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setDelegate:(id<PickerViewControllerDelegate>)delegate{
    _delegate = delegate;
    
    self.groupVc.delegate = delegate;
}

@end
