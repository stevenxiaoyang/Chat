//
//  MessageLogModelClass.h
//  MyFamily
//
//  Created by 陆洋 on 15/6/5.
//  Copyright (c) 2015年 maili. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "HistoryMessageLog.h"
#import <UIKit/UIKit.h>
//把要存储的message添加到datasource里
typedef void (^MyMessageBlock) (HistoryMessageLog *myMessage);

@interface MessageLogModelClass : NSObject
//保存数据
-(void)saveMessage:(NSString *)body from:(NSString *)from to:(NSString *)to withTag:(BOOL)tab;
//查询聊天记录，已时间排序，每刷新一下，取一定的条数,返回controller
-(NSArray *)queryMessageResult;
-(void) setMyMessageBlock:(MyMessageBlock)block;
-(void)updateFetchOffset;  //每次发送添加数据的时候都要更新下游标
@end
