//
//  imageCell.m
//  MyFamily
//
//  Created by 陆洋 on 15/6/4.
//  Copyright (c) 2015年 maili. All rights reserved.
//

#import "imageCell.h"
#import "UIImage+ReSize.h"
@interface imageCell()
@property (weak, nonatomic) IBOutlet UIImageView *headImage;

@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet UIImageView *sendImageView;

@end
@implementation imageCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setCellValue:(UIImage *)sendImage
{
    UIImage *image = [UIImage imageNamed:@"chatfrom_bg_normal.png"];
    image = [image resizableImageWithCapInsets:(UIEdgeInsetsMake(image.size.height * 0.6, image.size.width * 0.4, image.size.height * 0.3, image.size.width * 0.4))];
    [self.bgImageView setImage:image];
    
    self.headImage.image = [UIImage imageNamed:@"麦粒-app-28"];
    self.sendImageView.image = [sendImage reSizeImagetoSize:CGSizeMake(60, 80)];
    CALayer *layer = [self.sendImageView layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:6.0];
}

+(instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *identifier = @"imageCell";
    
    //缓存中取
    imageCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    //创建
    if (!cell)
    {
        cell = [[imageCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    //cell.userInteractionEnabled = NO;  //不让用户点击
    return cell;
}

@end
