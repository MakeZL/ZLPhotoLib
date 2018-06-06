//
//  ViewController.m
//  相册Demo
//
//  Created by 张磊 on 14-11-11.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import "ViewController.h"
#import "ZLPhoto.h"

@interface MLCellInfo : NSObject
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *vcName;
@end

@implementation MLCellInfo @end

@interface ViewController () <UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) UITableView *tableView;
@property (strong,nonatomic) NSArray *examples;

@end

@implementation ViewController

#pragma mark - getter
- (NSArray *)examples{
    
    MLCellInfo *cellInfo0 = [[MLCellInfo alloc] init];
    cellInfo0.name = @"Example0 相册多选";
    cellInfo0.vcName = @"Example0ViewController";
    
    MLCellInfo *cellInfo1 = [[MLCellInfo alloc] init];
    cellInfo1.name = @"Example1 图片浏览器";
    cellInfo1.vcName = @"Example1ViewController";
    
    MLCellInfo *cellInfo2 = [[MLCellInfo alloc] init];
    cellInfo2.name = @"Example3 选择视频";
    cellInfo2.vcName = @"Example3ViewController";
    
    MLCellInfo *cellInfo3 = [[MLCellInfo alloc] init];
    cellInfo3.name = @"Example4 放大查看头像";
    cellInfo3.vcName = @"Example4ViewController";
    
    MLCellInfo *cellInfo4 = [[MLCellInfo alloc] init];
    cellInfo4.name = @"Example5 图片游览器 -- push方式";
    cellInfo4.vcName = @"Example5ViewController";
    
    MLCellInfo *cellInfo5 = [[MLCellInfo alloc] init];
    cellInfo5.name = @"----- 感谢使用ZLPhotoLib -----";

    MLCellInfo *cellInfo6 = [[MLCellInfo alloc] init];
    cellInfo6.name = @"我是MakeZL,会不断维护,谢谢您的使用";
    
    return @[
             cellInfo0,
             cellInfo1,
             cellInfo2,
             cellInfo3,
             cellInfo4,
             cellInfo5,
             cellInfo6
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
    
    MLCellInfo *cellInfo = self.examples[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.text = cellInfo.name;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
    
}

#pragma mark - <UITableViewDelegate>
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MLCellInfo *cellInfo = self.examples[indexPath.row];
    if ([cellInfo.vcName length]) {
        UIViewController *vc = [[NSClassFromString(cellInfo.vcName) alloc] init];
        vc.title = cellInfo.name;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
