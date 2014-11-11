//
//  PickerViewController.m
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 14-11-11.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//


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
    nav.view.frame = self.view.frame;
    [self addChildViewController:nav];
    [self.view addSubview:nav.view];
    
    self.groupVc = groupVc;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
}

- (void)setDelegate:(id<PickerViewControllerDelegate>)delegate{
    _delegate = delegate;
    
    self.groupVc.delegate = delegate;
}

@end
