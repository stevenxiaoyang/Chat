//
//  myImageCell.m
//  MyFamily
//
//  Created by 陆洋 on 15/6/4.
//  Copyright (c) 2015年 maili. All rights reserved.
//

#import "myImageCell.h"
@interface myImageCell()
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;


@end
@implementation myImageCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+(instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *identifier = @"myselfImageCell";
    
    //缓存中取
    myImageCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    //创建
    if (!cell)
    {
        cell = [[myImageCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    //cell.userInteractionEnabled = NO;  //不让用户点击
    return cell;
}

-(void)setCellValue:(UIImage *)sendImage
{
    [super setCellValue:sendImage];
    
    UIImage *image = [UIImage imageNamed:@"chatto_bg_normal.png"];
    image = [image resizableImageWithCapInsets:(UIEdgeInsetsMake(image.size.height * 0.6, image.size.width * 0.4, image.size.height * 0.3, image.size.width * 0.4))];
    
    self.headImageView.image = [UIImage imageNamed:@"麦粒-app-29"];
    self.bgImageView.image = image;
}


@end
