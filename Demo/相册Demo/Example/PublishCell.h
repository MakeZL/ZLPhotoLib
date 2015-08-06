//
//  PublishCell.h
//  Where_Beauty
//
//  Created by Transuner on 15-5-21.
//  Copyright (c) 2015年 广州酷炫信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PublishCell;

@protocol PublishCellPhotoSelectedDelegate <NSObject>

- (void) photoSelectedImage;

- (void) tapBrowser:(NSInteger )index IndexPath:(NSIndexPath *)indexPath imagws:(NSArray*)imgs;

@end
@interface PublishCell : UITableViewCell




- (id) initWithStyle:(UITableViewCellStyle)style
     reuseIdentifier:(NSString *)reuseIdentifier
           IndexPath:(NSIndexPath *) indexPath;


@property (nonatomic, strong) NSIndexPath * indexPath;

@property (nonatomic, strong) UIImageView * image;

@property (nonatomic, strong) NSMutableArray * imgs;


@property (nonatomic, weak) id <PublishCellPhotoSelectedDelegate>delegate;

@property (nonatomic, strong) NSArray * assets;

- (void) setData:(NSArray *)data;

@end
