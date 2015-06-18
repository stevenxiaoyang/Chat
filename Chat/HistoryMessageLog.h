//
//  HistoryMessageLog.h
//  MyFamily
//
//  Created by 陆洋 on 15/6/5.
//  Copyright (c) 2015年 maili. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface HistoryMessageLog : NSManagedObject

@property (nonatomic, retain) NSString * body;
@property (nonatomic, retain) NSNumber * tab;
@property (nonatomic, retain) NSDate * time;
@property (nonatomic, retain) NSString * from;
@property (nonatomic, retain) NSString * to;

@end
