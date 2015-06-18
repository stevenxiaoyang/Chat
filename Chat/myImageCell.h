//
//  myImageCell.h
//  MyFamily
//
//  Created by 陆洋 on 15/6/4.
//  Copyright (c) 2015年 maili. All rights reserved.
//

#import "imageCell.h"
@interface myImageCell : imageCell
-(void)setCellValue:(UIImage *)sendImage;
+(instancetype)cellWithTableView:(UITableView *)tableView;
@end
