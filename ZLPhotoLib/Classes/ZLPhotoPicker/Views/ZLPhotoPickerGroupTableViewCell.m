//
//  PickerGroupTableViewCell.m
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 14-11-13.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import "ZLPhotoPickerGroupTableViewCell.h"
#import "ZLPhotoPickerGroup.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface ZLPhotoPickerGroupTableViewCell ()
@property (weak, nonatomic) UIImageView *groupImageView;
@property (weak, nonatomic) UILabel *groupNameLabel;
@property (weak, nonatomic) UILabel *groupPicCountLabel;
@end

@implementation ZLPhotoPickerGroupTableViewCell

- (UIImageView *)groupImageView{
    if (!_groupImageView) {
        UIImageView *groupImageView = [[UIImageView alloc] init];
        groupImageView.frame = CGRectMake(0, 0, 60, 60);
        groupImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:_groupImageView = groupImageView];
    }
    return _groupImageView;
}

- (UILabel *)groupNameLabel{
    if (!_groupNameLabel) {
        UILabel *groupNameLabel = [[UILabel alloc] init];
        groupNameLabel.frame = CGRectMake(75, 20, self.frame.size.width - 75, 20);
        [self.contentView addSubview:_groupNameLabel = groupNameLabel];
    }
    return _groupNameLabel;
}

- (UILabel *)groupPicCountLabel{
    if (!_groupPicCountLabel) {
        UILabel *groupPicCountLabel = [[UILabel alloc] init];
        groupPicCountLabel.textColor = [UIColor lightGrayColor];
        groupPicCountLabel.frame = CGRectMake(CGRectGetWidth(_groupNameLabel.frame) + 85, 20, self.frame.size.width - 85 - CGRectGetWidth(_groupNameLabel.frame), 20);
        [self.contentView addSubview:_groupPicCountLabel = groupPicCountLabel];
    }
    return _groupPicCountLabel;
}

- (void)setGroup:(ZLPhotoPickerGroup *)group{
    _group = group;
    
    self.groupNameLabel.text = group.groupName;
    [_groupNameLabel sizeToFit];
    self.groupImageView.image = group.thumbImage;
    self.groupPicCountLabel.text = [NSString stringWithFormat:@"(%ld)",group.assetsCount];
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

@end
