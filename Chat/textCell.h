//
//  textCell.h
//  MyFamily
//
//  Created by 陆洋 on 15/6/3.
//  Copyright (c) 2015年 maili. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface textCell : UITableViewCell
+(instancetype)cellWithTableView:(UITableView *)tableView;
-(void)setCellValue:(NSMutableAttributedString *) str andTimeDict:(NSDictionary *)timeDict;
@end
