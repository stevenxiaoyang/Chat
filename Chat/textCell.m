//
//  textCell.m
//  MyFamily
//
//  Created by 陆洋 on 15/6/3.
//  Copyright (c) 2015年 maili. All rights reserved.
//

#import "textCell.h"
#import "HeaderContent.h"
@interface textCell()
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet UITextView *textView;


@property (strong, nonatomic) NSMutableAttributedString *attrString;
@property (weak ,nonatomic)UIButton *timeButton;
@end
@implementation textCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

#define kTimeFont [UIFont systemFontOfSize:10] //时间字体
-(void)setCellValue:(NSMutableAttributedString *)str andTimeDict:(NSDictionary *)timeDict
{
    self.attrString = str;
    BOOL isShow = [[timeDict objectForKey:@"isShow"] boolValue];
    NSString *showTime = [timeDict objectForKey:@"showTime"];
    //显示时间
    [self removeOldImage];
    if (isShow) {
        UIButton *timeButton = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth/2 - 50, 0, 100, 14)];
        [timeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        timeButton.titleLabel.font = kTimeFont;
        timeButton.enabled = NO;
        [timeButton setBackgroundImage:[UIImage imageNamed:@"chat_timeline_bg.png"] forState:UIControlStateNormal];
        [timeButton setTitle:showTime forState:UIControlStateNormal];
        self.timeButton = timeButton;
        [self.contentView addSubview:self.timeButton];
        
    }
    CGRect bound = [self.attrString boundingRectWithSize:CGSizeMake(220, 1000) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    
    NSArray *bgImageconstrains = self.bgImageView.constraints;
    NSArray *textconstrains = self.textView.constraints;
    for (NSLayoutConstraint* constraint in bgImageconstrains) {
        if (constraint.firstAttribute == NSLayoutAttributeWidth) {
            constraint.constant = bound.size.width+45;
        }
    }
    for (NSLayoutConstraint* constraint in textconstrains) {
        if (constraint.firstAttribute == NSLayoutAttributeWidth) {
            constraint.constant = bound.size.width+14;
        }
    }
    
    
    //设置图片
    UIImage *image = [UIImage imageNamed:@"chatfrom_bg_normal.png"];
    image = [image resizableImageWithCapInsets:(UIEdgeInsetsMake(image.size.height * 0.6, image.size.width * 0.4, image.size.height * 0.3, image.size.width * 0.4))];
    //头像，也是要传进来的
    self.headImageView.image = [UIImage imageNamed:@"麦粒-app-28"];
    [self.bgImageView setImage:image];
    self.textView.attributedText = str;
    
}

-(void)removeOldImage   //防止cell复用重叠
{
    self.timeButton.hidden = YES;
}

+(instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *identifier = @"textCell";
    
    //缓存中取
    textCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    //创建
    if (!cell)
    {
        cell = [[textCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    //cell.userInteractionEnabled = NO;  //不让用户点击
    return cell;
}

@end
