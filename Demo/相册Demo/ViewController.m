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
             @"Example0 相册多选",
             @"Example1 图片游览器",
             @"Example2 自定义拍照",
             @"Example3 选择视频",
             @"Example4 放大查看头像",
             @"Example5 图片游览器 -- push方式",
             @" --------- (>v<) ---------- ",
             @"感谢您的App使用ZLPhotoLib",
             @"我是MakeZL,会不断维护,谢谢您的使用.",
             @"关于你的App名字，可以告诉我 :)"
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
    
    self.title = @"MakeZL";
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
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
    
}

#pragma mark - <UITableViewDelegate>
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row < 11) {
        NSString *exampleVc = [NSString stringWithFormat:@"Example%ldViewController",indexPath.row];
        UIViewController *vc = [[NSClassFromString(exampleVc) alloc] init];
        vc.title = self.examples[indexPath.row];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
