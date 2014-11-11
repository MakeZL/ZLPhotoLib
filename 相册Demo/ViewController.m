//
//  ViewController.m
//  相册Demo
//
//  Created by 张磊 on 14-11-11.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import "ViewController.h"
#import "PickerViewController.h"

@interface ViewController () <UITableViewDataSource,UITableViewDelegate,PickerViewControllerDelegate>

- (IBAction)selectPhotos;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic , strong) NSArray *images;

@end

@implementation ViewController

- (void)viewDidLoad{
    [super viewDidLoad];
}

- (IBAction)selectPhotos {
    PickerViewController *pickerVc = [[PickerViewController alloc] init];
    pickerVc.delegate = self;
    [self presentViewController:pickerVc animated:YES completion:nil];
    
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.images.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *ID = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    
    cell.imageView.image = self.images[indexPath.row];
    return cell;
    
}

- (void)pickerViewControllerDonePictures:(NSArray *)images{
    self.images = images;
    [self.tableView reloadData];
}

@end
