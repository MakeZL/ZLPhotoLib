//
//  ViewController.m
//  相册Demo
//
//  Created by 张磊 on 14-11-11.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import "ViewController.h"
#import "ZLPhoto.h"

@interface ViewController () <UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) UITableView *tableView;
@property (strong,nonatomic) NSArray *examples;

@end

@implementation ViewController

#pragma mark - getter
- (NSArray *)examples{
    return @[
             @"相片多选 + 图片游览器 >>> TableView",
             @"相片连拍/多选 + 图片游览器 >>> UICollectionView",
             @"相片多选/支持不重复选择照片 >>> UICollectionView",
             @"图片游览器 -> 自定义UIView >>> UIView",
             @"视频选择 + 视频游览器 >>>",
             @"查看当个图片（头像） >>>",
             @"添加图片的情况下 >>> UIScrollView",
            ];
}

- (UITableView *)tableView{
    if (!_tableView) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        tableView.backgroundColor = [UIColor whiteColor];
        tableView.dataSource = self;
        tableView.delegate = self;
        [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
        [self.view addSubview:tableView];
        self.tableView = tableView;
        
        tableView.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSString *vfl = @"V:|-0-[tableView]-20-|";
        NSDictionary *views = NSDictionaryOfVariableBindings(tableView);
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl options:0 metrics:nil views:views]];
        NSString *vfl2 = @"H:|-0-[tableView]-0-|";
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl2 options:0 metrics:nil views:views]];
    }
    return _tableView;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = @"ZLPickerLib";
    [self tableView];
    
}

#pragma mark - <UITableViewDataSource>
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.examples.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.text = self.examples[indexPath.row];
    
    return cell;
    
}

#pragma mark - <UITableViewDelegate>
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
//    NSString *exampleVc = [NSString stringWithFormat:@"Example%ldViewController",indexPath.row + 1];
    NSString *exampleVc = [NSString stringWithFormat:@"PublishViewController"];
    UIViewController *vc = [[NSClassFromString(exampleVc) alloc] init];
    vc.title = self.examples[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
