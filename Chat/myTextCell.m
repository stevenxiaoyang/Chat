//
//  myTextCell.m
//  MyFamily
//
//  Created by 陆洋 on 15/6/3.
//  Copyright (c) 2015年 maili. All rights reserved.
//

#import "myTextCell.h"
@interface myTextCell()
@property (weak, nonatomic) IBOutlet UIImageView *headView;
@property (weak, nonatomic) IBOutlet UIImageView *bgView;


@end
@implementation myTextCell

+(instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *identifier = @"myselfTextCell";
    
    //缓存中取
    myTextCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    //创建
    if (!cell)
    {
        cell = [[myTextCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    //cell.userInteractionEnabled = NO;  //不让用户点击
    
    return cell;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */
-(void)setCellValue:(NSMutableAttributedString *)str andTimeDict:(NSDictionary *)timeDict
{
    [super setCellValue:str andTimeDict:timeDict];
    
    UIImage *image = [UIImage imageNamed:@"chatto_bg_normal.png"];
    image = [image resizableImageWithCapInsets:(UIEdgeInsetsMake(image.size.height * 0.6, image.size.width * 0.4, image.size.height * 0.3, image.size.width * 0.4))];
    
    [self.bgView setImage:image];
    [self.headView setImage:[UIImage imageNamed:@"麦粒-app-29"]];
}

@end
