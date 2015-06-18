//
//  MessageLogModelClass.m
//  MyFamily
//
//  Created by 陆洋 on 15/6/5.
//  Copyright (c) 2015年 maili. All rights reserved.
//

#import "MessageLogModelClass.h"

@interface MessageLogModelClass()
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong)MyMessageBlock messageBlock;
//游标
@property (nonatomic, assign)NSInteger FetchOffset;
@end
@implementation MessageLogModelClass
- (instancetype)init
{
    self = [super init];
    if (self) {
        //通过上下文获取manager
        UIApplication *application = [UIApplication sharedApplication];
        id delegate = application.delegate;
        self.managedObjectContext = [delegate managedObjectContext];
        self.FetchOffset = 0;
    }
    return self;
}

-(void)setMyMessageBlock:(MyMessageBlock)block
{
    self.messageBlock = block;
}
-(void)saveMessage:(NSString *)body from:(NSString *)from to:(NSString *)to withTag:(BOOL)tab
{
    if (body) {
        HistoryMessageLog *message = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([HistoryMessageLog class]) inManagedObjectContext:self.managedObjectContext];
        message.body = body;
        message.tab = [NSNumber numberWithBool:tab];
        message.from = from;
        message.to = to;
        message.time = [NSDate date];
        
        self.messageBlock(message);
        //存储实体
        NSError *error = nil;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"保存出错%@", [error localizedDescription]);
        }

    }
}

-(NSArray *)queryMessageResult
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([HistoryMessageLog class])];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:NO];
    //把排序和分组规则添加到请求中
    [request setSortDescriptors:@[sortDescriptor]];
    
    /*NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"from =='%@'",self.jidStr]];
    [request setPredicate:predicate];*/    //查询需要from,to
    
    //把请求的结果转换成适合tableView显示的数据
    //[request setFetchBatchSize:100];
    [request setFetchLimit:10];
    [request setFetchOffset:self.FetchOffset];
    
    NSError *error;
    NSArray *messageArray = [[(id)[UIApplication sharedApplication].delegate managedObjectContext] executeFetchRequest:request error:&error];
    if ([messageArray count]) {
        self.FetchOffset += [messageArray count];
    }
    return messageArray;
    
}
-(void)updateFetchOffset
{
    self.FetchOffset += 1;
}


@end
