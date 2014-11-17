//
//  PickerWChatBrowserViewController.m
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 14-11-17.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import "PickerWChatBrowserViewController.h"
#import "UIView+Extension.h"
#import "PickerPhoto.h"

@interface PickerWChatBrowserViewController ()
@property (nonatomic,strong) UIImageView *currentImageView;

@end

@implementation PickerWChatBrowserViewController

- (UIImageView *)currentImageView{
    if (!_currentImageView) {
        _currentImageView = [[UIImageView alloc] init];
        _currentImageView.alpha = 0;
        _currentImageView.contentMode = UIViewContentModeScaleAspectFit;
        _currentImageView.clipsToBounds = YES;
        [self.tableView.superview.superview addSubview:_currentImageView];
    }
    return _currentImageView;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)setPhoto:(PickerPhoto *)photo{
    _photo = photo;
    
    [self setup];
}

- (void) setup{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    CGRect tempFrame = cell.frame;
    tempFrame.origin.y -= ( self.tableView.contentOffset.y - self.tableView.y);
    
    __unsafe_unretained typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.5 animations:^{
        weakSelf.currentImageView.alpha = 1;
        weakSelf.navigationController.navigationBarHidden = YES;
        weakSelf.currentImageView.hidden = NO;
        weakSelf.tableView.hidden = YES;
        
        CGFloat x = 10;
        CGFloat w = self.view.width - x * 2;
        weakSelf.currentImageView.frame = CGRectMake(x, 0, w, self.view.height);
        
    } completion:^(BOOL finished) {
        
        
        
        
    }];
    
    self.disMissBlock = ^(NSInteger page){
        NSIndexPath *selectIndexPath = [NSIndexPath indexPathForRow:page inSection:0];
        UITableViewCell *selectCell = [weakSelf.tableView cellForRowAtIndexPath:selectIndexPath];
        CGRect tempFrame = selectCell.frame;
        tempFrame.origin.y -= ( weakSelf.tableView.contentOffset.y - weakSelf.tableView.y);
        
        weakSelf.currentImageView.image = weakSelf.photo.photoImage;
        
        [UIView animateWithDuration:0.5 animations:^{
            weakSelf.currentImageView.hidden = NO;
            // 如果大于可展示的Cell的个数
            if (page >= [[weakSelf.tableView visibleCells] count]) {
                weakSelf.currentImageView.frame = tempFrame;
                weakSelf.currentImageView.y += CGRectGetHeight(cell.frame) * (page - [[weakSelf.tableView visibleCells] count]) + CGRectGetHeight(cell.frame);
            }else{
                weakSelf.currentImageView.frame = tempFrame;
            }
            weakSelf.currentImageView.x -= CGRectGetMaxX(cell.imageView.frame);
            weakSelf.currentImageView.alpha = 0;
        } completion:^(BOOL finished) {
            [weakSelf dismissViewControllerAnimated:NO completion:nil];
            weakSelf.tableView.superview.backgroundColor = [UIColor whiteColor];
            weakSelf.tableView.backgroundColor = [UIColor whiteColor];
            weakSelf.tableView.hidden = NO;
            weakSelf.currentImageView.hidden = YES;
            weakSelf.navigationController.navigationBarHidden = NO;
        }];
    };
}


@end
