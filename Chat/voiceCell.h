//
//  voiceCell.h
//  MyFamily
//
//  Created by 陆洋 on 15/6/4.
//  Copyright (c) 2015年 maili. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface voiceCell : UITableViewCell
-(void)setCellValue:(NSURL *)audioURL;
+(instancetype)cellWithTableView:(UITableView *)tableView;
@end
