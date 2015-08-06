//
//  PublishViewController.h
//  Where_Beauty
//
//  Created by Transuner on 15-5-7.
//  Copyright (c) 2015年 广州酷炫信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

enum Tag_PublishText{
    
    title_Tag = 199,
    date_Tag,
    address_Tag,
};

@interface PublishViewController : UIViewController
<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) NSArray     * labels;

@property (nonatomic, strong) UITableView * tableView;

//标题
@property (nonatomic, strong) UILabel * titleLabel;

//时间
@property (nonatomic, strong) UILabel * dateLabel;

//地址
@property (nonatomic, strong) UILabel * addressLabel;



@end
