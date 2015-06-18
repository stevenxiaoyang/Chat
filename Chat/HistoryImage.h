//
//  HistoryImage.h
//  MyFamily
//
//  Created by 陆洋 on 15/6/3.
//  Copyright (c) 2015年 maili. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface HistoryImage : NSManagedObject

@property (nonatomic, retain) NSData * headerImage;
@property (nonatomic, retain) NSString * imageText;
@property (nonatomic, retain) NSDate * time;

@end
