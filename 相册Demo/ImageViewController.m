//
//  ImageViewController.m
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 14-11-14.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController ()

@property (nonatomic , weak) UIImageView *imageView;

@end

@implementation ImageViewController

- (UIImageView *)imageView{
    if (!_imageView) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.frame = self.view.bounds;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.view addSubview:imageView];
        self.imageView = imageView;
    }
    return _imageView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)setAsset:(ALAsset *)asset{
    _asset = asset;
    self.imageView.image = [UIImage imageWithCGImage: [[asset defaultRepresentation] fullScreenImage]];
    
    
}

@end
