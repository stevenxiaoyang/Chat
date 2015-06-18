//
//  myTextCell.h
//  MyFamily
//
//  Created by 陆洋 on 15/6/3.
//  Copyright (c) 2015年 maili. All rights reserved.
//

#import "textCell.h"

@interface myTextCell : textCell
+(instancetype)cellWithTableView:(UITableView *)tableView;
-(void)setCellValue:(NSMutableAttributedString *) str andTimeDict:(NSDictionary *)timeDict;
@end
