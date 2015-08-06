//
//  PublishViewController.m
//  Where_Beauty
//
//  Created by Transuner on 15-5-7.
//  Copyright (c) 2015年 广州酷炫信息科技有限公司. All rights reserved.
//

#import "PublishViewController.h"
#import "PublishCell.h"
#import "ZLPhoto.h"

static NSString *const PublishIdentifierCell = @"Cell";


@interface PublishViewController ()<PublishCellPhotoSelectedDelegate,ZLPhotoPickerBrowserViewControllerDataSource,ZLPhotoPickerBrowserViewControllerDelegate>
{
    float autoHeight;
}

@property (nonatomic ,strong) NSMutableArray * dataArray;
@property (nonatomic,strong) NSMutableArray  * imgs;
@property (nonatomic, strong) NSIndexPath    * indexShow;
@end

@implementation PublishViewController
- (void) addTableViews
{
//    self.view.backgroundColor =  R_UIColorFromRGB(0xeeeeee);
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"发布消息";
    
//    UIBarButtonItem * leftItem = [[UIBarButtonItem alloc]initWithImage:R_IMAGE(@"back") style:UIBarButtonItemStylePlain target:self action:@selector(popViewController)];
//    self.navigationItem.leftBarButtonItem = leftItem;
//    
//    autoHeight = AUTOY;
}
- (NSMutableArray *)imgs
{
    if (!_imgs) {
        _imgs = [[NSMutableArray alloc]init];
    }
    return _imgs;
}
- (void) popViewController
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addTableViews];
    [self tableView];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self photoSelectedImage];
    });
//    [self.tableView setNoFooterLine];
//    [self.tableView setSeparatorInsetline];
}

- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];//[[NSMutableArray alloc]init];
    }
    return _dataArray;
}

- (UITableView *) tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height-64) style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate   = self;
        [self.view addSubview:_tableView];
    }
    return _tableView;
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (long) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
//    return 2;
}

- (long) tableView:(UITableView *)tableView numberOfRowsInSection:(long)section
{
//    return self.dataArray.count;
    if (section == 0) {
        return 4;
    }
    return 1;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
//    if (indexPath.section == 0)
//    {
//        if (indexPath.row == 3)
//        {
//            CGFloat heigtht = 10 * autoHeight;
//            
//            if (self.dataArray.count > 0 && self.dataArray.count < 3)
//            {
//                heigtht += 90 * autoHeight;
//            }
//            else if (self.dataArray.count >=3)
//            {
//                heigtht += 175 * autoHeight;
//            }
//            else
//            {
//                heigtht+= 90 * autoHeight;
//            }
//            
//            return heigtht;
//            
//        }
//    }
//    return 60 * autoHeight;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(long)section
{
    if (section == 0) {
        return 0;
    }
    return 30 * autoHeight;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(long)section
{
//    if (section == 1) {
//        
//        CustomLabel * text = [[CustomLabel alloc]initWithFrame:AutoCGRectMake(0, 0, 320, 30)
//                                                          Font:[UIFont fontWithName:THE_FONTS size:15]
//                                                       BGColor:R_UIColorFromRGB(0xeeeeee)
//                                                    TitleColor:R_UIColorFromRGB(0x424243)
//                                                     LabelText:@"   内容"
//                                                 TextAlignment:0
//                                                           Tag:30];
//        return text;
//    }
    return nil;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PublishCell * cell = (PublishCell*)[tableView dequeueReusableCellWithIdentifier:PublishIdentifierCell];
    
    if (!cell) {
        cell = [[PublishCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:PublishIdentifierCell IndexPath:indexPath];
    }
    cell.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    cell.textLabel.text = [self textLabel:indexPath];
    
    if (indexPath.section == 0)
    {
//        cell.textLabel.font = [UIFont fontWithName:THE_FONTS size:15];
//        cell.textLabel.textColor = R_UIColorFromRGB(0x424243);
//        
        if (indexPath.row !=3)
        {
            
//            [cell.contentView addSubview:self.labels[indexPath.row]];
        }
        else if (indexPath.row == 3)
        {
            [cell setData:self.dataArray];
        }
    }
    else if (indexPath.section == 1)
    {
//        cell.textLabel.font = [UIFont fontWithName:THE_FONTS size:13];
//        cell.textLabel.textColor = R_UIColorFromRGB(0xc7c7c7);
    }
    
    return cell;
}

- (NSString *) textLabel:(NSIndexPath *)indexPath
{
    NSArray * __autoreleasing texts = @[@[@"标题",@"时间",@"地址",@"图片"],@[@"详细描述内容,限200个字符"]];
    return texts[indexPath.section][indexPath.row];
}

- (NSArray *)labels
{
    if (!_labels) {
        _labels = @[self.titleLabel,self.dateLabel,self.addressLabel];
    }
    return _labels;
}
//标题
//- (CustomLabel *) titleLabel
//{
//    if (!_titleLabel) {
//        _titleLabel = [[CustomLabel alloc]initWithFrame:AutoCGRectMake(60, 0, 250, 60)
//                                                   Font:[UIFont fontWithName:THE_FONTS size:14]
//                                                BGColor:[UIColor clearColor]
//                                             TitleColor:R_UIColorFromRGB(0x424243)
//                                              LabelText:@"海南四天三夜游,有兴趣的走起"
//                                          TextAlignment:2
//                                                    Tag:title_Tag];
//    }
//    return _titleLabel;
//}
//时间
//- (CustomLabel *) dateLabel
//{
//    if (!_dateLabel) {
//        _dateLabel = [[CustomLabel alloc]initWithFrame:AutoCGRectMake(60, 0, 250, 60)
//                                                  Font:[UIFont fontWithName:THE_FONTS size:14]
//                                               BGColor:[UIColor clearColor]
//                                            TitleColor:R_UIColorFromRGB(0x424243)
//                                             LabelText:@"2015.05.01-2015.05.03"
//                                         TextAlignment:2
//                                                   Tag:date_Tag];
//    }
//    return _dateLabel;
//}
////地址
//- (CustomLabel *) addressLabel
//{
//    if (!_addressLabel) {
//        _addressLabel = [[CustomLabel alloc]initWithFrame:AutoCGRectMake(60, 0, 250, 60)
//                                                     Font:[UIFont fontWithName:THE_FONTS size:14]
//                                                  BGColor:[UIColor clearColor]
//                                               TitleColor:R_UIColorFromRGB(0xc7c7c7)
//                                                LabelText:@"详细填写地址,限20个字"
//                                            TextAlignment:2
//                                                      Tag:address_Tag];
//    }
//    return _addressLabel;
//}
//从cell里面用代理方法传过来选图片
- (void) photoSelectedImage
{
    NSLog(@"photoSelectedImage");
    ZLPhotoPickerViewController *pickerVc = [[ZLPhotoPickerViewController alloc] init];
    pickerVc.maxCount = 6 - self.dataArray.count;
    pickerVc.status = PickerViewShowStatusCameraRoll;
    pickerVc.callBack = ^(NSArray *status){
        [self.dataArray addObjectsFromArray:status];
        [self.tableView reloadData];
    };
    
    [self presentViewController:pickerVc animated:YES completion:^{
        
    }];
    
}

- (void)tapBrowser:(long)index IndexPath:(NSIndexPath *)indexPath imagws:(NSArray *)imgs
{
    self.indexShow = indexPath;
    NSLog(@"index__%ld",index);
    [self.imgs removeAllObjects];
    [self.imgs addObjectsFromArray:imgs];
//    [self.imgs addObjectsFromArray:imgs];
    NSIndexPath *indexPaths = [NSIndexPath indexPathForRow:index inSection:0];
    // 图片游览器
    ZLPhotoPickerBrowserViewController *pickerBrowser = [[ZLPhotoPickerBrowserViewController alloc] init];
    // 淡入淡出效果
    // pickerBrowser.status = UIViewAnimationAnimationStatusFade;
    //    pickerBrowser.toView = btn;
    // 数据源/delegate
    pickerBrowser.delegate = self;
    pickerBrowser.dataSource = self;
    // 当前选中的值
    pickerBrowser.currentIndexPath = [NSIndexPath indexPathForItem:index inSection:0];
    // 展示控制器
    [self presentViewController:pickerBrowser animated:NO completion:^{
        
    }];
}
#pragma mark - <ZLPhotoPickerBrowserViewControllerDataSource>
- (long)numberOfSectionInPhotosInPickerBrowser:(ZLPhotoPickerBrowserViewController *)pickerBrowser{
    return 1;
}
- (long)photoBrowser:(ZLPhotoPickerBrowserViewController *)photoBrowser numberOfItemsInSection:(NSUInteger)section{
    return self.dataArray.count;
}

#pragma mark - 每个组展示什么图片,需要包装下ZLPhotoPickerBrowserPhoto
- (ZLPhotoPickerBrowserPhoto *) photoBrowser:(ZLPhotoPickerBrowserViewController *)pickerBrowser photoAtIndexPath:(NSIndexPath *)indexPath{
    ZLPhotoAssets *imageObj = [self.dataArray objectAtIndex:indexPath.row];
    // 包装下imageObj 成 ZLPhotoPickerBrowserPhoto 传给数据源
    ZLPhotoPickerBrowserPhoto *photo = [ZLPhotoPickerBrowserPhoto photoAnyImageObjWith:imageObj];
    
    UIImageView * image = nil;
    
    PublishCell * cell = (PublishCell *)[self.tableView cellForRowAtIndexPath:self.indexShow];

//    cell.image = self.imgs[indexPath.row];
    photo.toView = self.imgs[indexPath.row];
    photo.thumbImage = [self.dataArray[indexPath.row] originImage];
    // 缩略图
//    photo.thumbImage = [self.imgs[indexPath.row] image];
    
    return photo;
}
@end
