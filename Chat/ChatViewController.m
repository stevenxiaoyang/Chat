//
//  ChatViewController.m
//  MyFamily
//
//  Created by 陆洋 on 15/6/3.
//  Copyright (c) 2015年 maili. All rights reserved.
//

#import "ChatViewController.h"
#import "ToolView.h"
#import "myTextCell.h"
#import "myImageCell.h"
#import "voiceCell.h"
#import "MessageLogModelClass.h"
typedef enum : NSUInteger {
    SendText,
    SendImage,
    SendVoice
    
} MySendContentType;
@interface ChatViewController()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITableViewDataSource,UITableViewDelegate>
//工具栏
@property (nonatomic,strong) ToolView *toolView;
//工具栏的高约束，用于当输入文字过多时改变工具栏的约束
@property (strong, nonatomic) NSLayoutConstraint *tooViewConstraintHeight;

//从相册获取图片
@property (strong, nonatomic) UIImagePickerController *imagePiceker;
//音量图片
@property (strong, nonatomic) UIImageView *volumeImageView;
@property (weak, nonatomic) IBOutlet UITableView *chatTableView;

//聊天的数据，一开始要从数据库中取出赋值
@property(nonatomic,strong)NSMutableArray *messageData;

@property (strong,nonatomic)MessageLogModelClass *messageLogMode;
//刷新
@property (assign,nonatomic)BOOL isRefresh;
@property (strong,nonatomic)UIActivityIndicatorView *activity;

@property (assign,nonatomic)BOOL youOrMe; //模拟数据用的，要删除
@property (strong,nonatomic)NSMutableArray *timeArray;
@end
@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"chatMemberName";
    self.youOrMe = YES;
    //选图片
    self.imagePiceker = [[UIImagePickerController alloc] init];
    self.imagePiceker.allowsEditing = YES;
    self.imagePiceker.delegate = self;
    
    //用于读取存储历史纪录
    self.messageLogMode = [[MessageLogModelClass alloc]init];
    //添加基本的子视图
    [self addMySubView];
    
    //给子视图添加约束
    [self addConstaint];
    
    //设置工具栏的回调
    [self setToolViewBlock];
    
    self.chatTableView.delegate = self;
    self.chatTableView.dataSource = self;
    //self.chatTableView.backgroundColor = [UIColor colorWithRed:244.0/255 green:244.0/255 blue:246.0/255 alpha:1];
    
    //初始化data,需要从数据库中取出聊天记录
    [self initData];
    
    //获取通知中心
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    //注册为被通知者
    [notificationCenter addObserver:self selector:@selector(keyChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    //注册tap手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyBoardDown:)];
    
    [self.chatTableView addGestureRecognizer:tap];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [self scrollBottom];
}
-(void)addMySubView
{
    //imageView实例化
    self.volumeImageView = [[UIImageView alloc] init];
    self.volumeImageView.hidden = YES;
    self.volumeImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.volumeImageView setImage:[UIImage imageNamed:@"record_animate_01.png"]];
    [self.view addSubview:self.volumeImageView];
    
    
    //工具栏
    self.toolView = [[ToolView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.toolView];
    
    
    self.automaticallyAdjustsScrollViewInsets = false;  //第一个cell和顶部有留白，scrollerview遗留下来的，用来取消它
    //刷新控件
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];
    self.activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activity.frame = CGRectMake(headerView.frame.size.width/2, 0, 20, 20);;
    [headerView addSubview:self.activity];
    self.chatTableView.tableHeaderView = headerView;
    headerView.hidden = YES;
}

-(void) addConstaint
{
    
    //给volumeImageView进行约束
    _volumeImageView.translatesAutoresizingMaskIntoConstraints = NO;
    NSArray *imageViewConstrainH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-60-[_volumeImageView]-60-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_volumeImageView)];
    [self.view addConstraints:imageViewConstrainH];
    
    NSArray *imageViewConstaintV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-150-[_volumeImageView(150)]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_volumeImageView)];
    [self.view addConstraints:imageViewConstaintV];
    
    
    //toolView的约束
    _toolView.translatesAutoresizingMaskIntoConstraints = NO;
    NSArray *toolViewContraintH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_toolView]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_toolView)];
    [self.view addConstraints:toolViewContraintH];
    
    NSArray * tooViewConstraintV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_toolView(44)]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_toolView)];
    [self.view addConstraints:tooViewConstraintV];
    self.tooViewConstraintHeight = tooViewConstraintV[0];
}

-(void)initData
{
    //NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //[formatter setDateFormat : @"yyyy-M-d H:mm"];
    
    self.messageData = [[NSMutableArray alloc]init];
    NSArray *fetchArray = [self.messageLogMode queryMessageResult];
    NSInteger fetchCount = [fetchArray count];
    for (NSInteger i = fetchCount; i > 0; i--) {
        [self.messageData addObject:fetchArray[i - 1]];
        [self.timeArray addObject:((HistoryMessageLog *)fetchArray[i - 1]).time];  //time跟着messagedata走，不然后面逻辑容易混乱
        //NSLog(@"%@",[formatter stringFromDate:((HistoryMessageLog *)fetchArray[i - 1]).time]);
    }
}

-(void)setToolViewBlock
{
    __weak __block ChatViewController *copy_self = self;
    //回调输入框的contentSize,改变工具栏的高度
    [self.toolView setContentSizeBlock:^(CGSize contentSize) {
        [copy_self updateHeight:contentSize];
    }];
    //通过block回调接收到toolView中的text
    [self.toolView setMyTextBlock:^(NSString *myText) {
        NSLog(@"%@",myText);
        
        [copy_self sendMessage:SendText Content:myText];
    }];
    
    //扩展功能回调
    [self.toolView setExtendFunctionBlock:^(int buttonTag) {
        switch (buttonTag) {
            case 1:
                //从相册获取
                [copy_self presentViewController:copy_self.imagePiceker animated:YES completion:^{
                    
                }];
                break;
            case 2:
                //拍照
                break;
                
            default:
                break;
        }
    }];
    
    //获取录音声量，用于声音音量的提示
    [self.toolView setAudioVolumeBlock:^(CGFloat volume) {
        
        copy_self.volumeImageView.hidden = NO;
        int index = (int)(volume*100)%6+1;
        [copy_self.volumeImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"record_animate_%02d.png",index]]];
    }];
    
    //获取录音地址（用于录音播放方法）
    [self.toolView setAudioURLBlock:^(NSURL *audioURL) {
        copy_self.volumeImageView.hidden = YES;
        [copy_self sendMessage:SendVoice Content:audioURL];
    }];
    
    //录音取消（录音取消后，把音量图片进行隐藏）
    [self.toolView setCancelRecordBlock:^(int flag) {
        if (flag == 1) {
            copy_self.volumeImageView.hidden = YES;
        }
    }];
    
    [self.messageLogMode setMyMessageBlock:^(HistoryMessageLog *myMessage) {
        [copy_self.messageData addObject:myMessage];
        [copy_self.timeArray addObject:myMessage.time];
    }];
}


//懒加载
-(NSMutableArray *)timeArray
{
    if (!_timeArray) {
        _timeArray = [[NSMutableArray alloc]init];
    }
    return _timeArray;
}
-(void)keyBoardDown:(id)sender
{
    [self.toolView keyboardDown];
}


//发送消息
-(void)sendMessage:(MySendContentType) sendType Content:(id)content
{
    NSDictionary *bodyDic;
    
    
    if ([content isKindOfClass:[NSURL class]]) {
        
        bodyDic = @{@"type":@(sendType),
                    @"content":[NSString stringWithFormat:@"%@",content]};
    }
    else
    {
        bodyDic = @{@"type":@(sendType),
                    @"content":content};
        
    }
    
    
    //把bodyDic转换成data类型
    NSError *error = nil;
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:bodyDic options:NSJSONWritingPrettyPrinted error:&error];
    if (error)
    {
        NSLog(@"解析错误%@", [error localizedDescription]);
    }
    
    //把data转成字符串进行发送
    NSString *bodyString = [[NSString alloc] initWithData:bodyData encoding:NSUTF8StringEncoding];
    
    //保存到数据库
    [self.messageLogMode saveMessage:bodyString from:@"test" to:@"test" withTag:self.youOrMe];
    self.youOrMe = !self.youOrMe;
    [self.messageLogMode updateFetchOffset];
    /*HistoryMessageLog *message = [[HistoryMessageLog alloc]init];
     message.body = bodyString;
     message.from = @"test";
     message.to = @"test";
     message.tab = [NSNumber numberWithBool:1];
     message.time = [NSDate date];*/
    //发送数据给服务器
    
    //添加到数组里，刷新
    //[self.messageData addObject:message];
    //NSIndexPath *indexPath = [NSIndexPath indexPathForRow:([self.messageData count]-1) inSection:0];  //nsindexpath初始化方法
    //[self.chatTableView reloadRowsAtIndexPaths:@[indexPath]withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.chatTableView reloadData];
    
}

//获取图片后要做的方法
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *pickerImage = info[UIImagePickerControllerEditedImage];
    
    //保存进沙盒，得到nsurl，保存
    NSString *strUrl = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *imageURL = [strUrl stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld.png", (long)[[NSDate date] timeIntervalSince1970]]];
    
    [UIImagePNGRepresentation(pickerImage) writeToFile:imageURL atomically:YES];
    [self sendMessage:SendImage Content:imageURL];
    [self dismissViewControllerAnimated:YES completion:^{}];
    
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    //在ImagePickerView中点击取消时回到原来的界面
    [self dismissViewControllerAnimated:YES completion:^{}];
    
}


//更新toolView的高度约束
-(void)updateHeight:(CGSize)contentSize
{
    float height = contentSize.height + 18;
    if (height <= 80) {
        [self.view removeConstraint:self.tooViewConstraintHeight];
        
        NSString *string = [NSString stringWithFormat:@"V:[_toolView(%f)]", height];
        
        NSArray * tooViewConstraintV = [NSLayoutConstraint constraintsWithVisualFormat:string options:0 metrics:0 views:NSDictionaryOfVariableBindings(_toolView)];
        self.tooViewConstraintHeight = tooViewConstraintV[0];
        [self.view addConstraint:self.tooViewConstraintHeight];
    }
}

//键盘出来的时候调整tooView的位置
-(void) keyChange:(NSNotification *) notify
{
    NSDictionary *dic = notify.userInfo;
    
    
    CGRect endKey = [dic[@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    //坐标系的转换
    CGRect endKeySwap = [self.view convertRect:endKey fromView:self.view.window];
    //运动时间
    [UIView animateWithDuration:[dic[UIKeyboardAnimationDurationUserInfoKey] floatValue] animations:^{
        
        [UIView setAnimationCurve:[dic[UIKeyboardAnimationCurveUserInfoKey] doubleValue]];
        CGRect frame = self.view.frame;
        
        frame.size.height = endKeySwap.origin.y;
        
        self.view.frame = frame;
        [self.view layoutIfNeeded];
        [self scrollBottom];
    }];
}

//显示表情,用属性字符串显示表情
-(NSMutableAttributedString *)showFace:(NSString *)str
{
    if (str != nil) {
        //加载plist文件中的数据
        NSBundle *bundle = [NSBundle mainBundle];
        //寻找资源的路径
        NSString *path = [bundle pathForResource:@"emoticons" ofType:@"plist"];
        //获取plist中的数据
        NSArray *face = [[NSArray alloc] initWithContentsOfFile:path];
        
        //创建一个可变的属性字符串
        
        NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:str];
        
        UIFont *baseFont = [UIFont systemFontOfSize:17];
        [attributeString addAttribute:NSFontAttributeName value:baseFont
                                range:NSMakeRange(0, str.length)];
        
        //正则匹配要替换的文字的范围
        //正则表达式
        NSString * pattern = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";
        NSError *error = nil;
        NSRegularExpression * re = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
        
        if (!re) {
            NSLog(@"%@", [error localizedDescription]);
        }
        
        //通过正则表达式来匹配字符串
        NSArray *resultArray = [re matchesInString:str options:0 range:NSMakeRange(0, str.length)];
        
        
        //用来存放字典，字典中存储的是图片和图片对应的位置
        NSMutableArray *imageArray = [NSMutableArray arrayWithCapacity:resultArray.count];
        
        //根据匹配范围来用图片进行相应的替换
        for(NSTextCheckingResult *match in resultArray) {
            //获取数组元素中得到range
            NSRange range = [match range];
            
            //获取原字符串中对应的值
            NSString *subStr = [str substringWithRange:range];
            
            for (int i = 0; i < face.count; i ++)
            {
                if ([face[i][@"chs"] isEqualToString:subStr])
                {
                    
                    //face[i][@"gif"]就是我们要加载的图片
                    //新建文字附件来存放我们的图片
                    NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
                    
                    //给附件添加图片
                    textAttachment.image = [UIImage imageNamed:face[i][@"png"]];
                    
                    //把附件转换成可变字符串，用于替换掉源字符串中的表情文字
                    NSAttributedString *imageStr = [NSAttributedString attributedStringWithAttachment:textAttachment];
                    
                    //把图片和图片对应的位置存入字典中
                    NSMutableDictionary *imageDic = [NSMutableDictionary dictionaryWithCapacity:2];
                    [imageDic setObject:imageStr forKey:@"image"];
                    [imageDic setObject:[NSValue valueWithRange:range] forKey:@"range"];
                    
                    //把字典存入数组中
                    [imageArray addObject:imageDic];
                    
                }
            }
        }
        
        //从后往前替换
        for (int i = (int)imageArray.count -1; i >= 0; i--)
        {
            NSRange range;
            [imageArray[i][@"range"] getValue:&range];
            //进行替换
            [attributeString replaceCharactersInRange:range withAttributedString:imageArray[i][@"image"]];
            
        }
        
        return  attributeString;
        
    }
    
    return nil;
    
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.messageData count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HistoryMessageLog *message = [self.messageData objectAtIndex:indexPath.row];
    NSDictionary *timeDict = [self timeOperate:(NSInteger)indexPath.row];
    NSString *bodyStr = message.body;
    NSData * bodyData = [bodyStr dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:bodyData options:NSJSONReadingAllowFragments error:nil];
    MySendContentType contentType = [[dic objectForKey:@"type"] integerValue];
    switch (contentType) {
        case SendText:
        {
            if ([message.tab boolValue]) {
                myTextCell *cell = [myTextCell cellWithTableView:tableView];
                NSMutableAttributedString *contentText = [self showFace:dic[@"content"]];
                [cell setCellValue:contentText andTimeDict:timeDict];
                return cell;
            }
            else
            {
                textCell *cell = [textCell cellWithTableView:tableView];
                NSMutableAttributedString *contentText = [self showFace:dic[@"content"]];
                [cell setCellValue:contentText andTimeDict:timeDict];
                return cell;
            }
        }
            
            break;
        case SendImage:
            if ([message.tab boolValue]) {
                myImageCell *cell = [myImageCell cellWithTableView:tableView];
                [cell setCellValue:dic[@"content"]];
                return cell;
            }
            else
            {
                imageCell *cell = [imageCell cellWithTableView:tableView];
                [cell setCellValue:dic[@"content"]];
                return cell;
            }
            
            break;
        case SendVoice:
            if ([message.tab boolValue]) {
                voiceCell *cell = [voiceCell cellWithTableView:tableView];
                NSURL *voiceURL = [NSURL URLWithString: dic[@"content"]];
                [cell setCellValue:voiceURL];
                return cell;
            }
            else
            {
                voiceCell *cell = [voiceCell cellWithTableView:tableView];
                NSURL *voiceURL = [NSURL URLWithString: dic[@"content"]];
                [cell setCellValue:voiceURL];
                return cell;
            }
            
            break;
            
        default:
            break;
    }
    UITableViewCell *cell = [[UITableViewCell alloc]init];
    return cell;
}

-(NSDictionary *)timeOperate:(NSInteger)row
{
    BOOL isShow = YES;
    NSString *showTime = [[NSString alloc]init];
    NSInteger count = [self.timeArray count];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat : @"yyyy-M-d HH:mm"];
    
    NSLog(@"%ld",(long)row);
    
    if (count == 1 || row == 0) {    //当只有一条的时候必须显示时间
        //NSLog(@"%@",[formatter stringFromDate:[self.timeArray objectAtIndex:row]]);
        isShow = YES;
        showTime = [formatter stringFromDate:[self.timeArray objectAtIndex:row]];
    }
    else
    {
        //NSLog(@"%@",[formatter stringFromDate:[self.timeArray objectAtIndex:row]]);
        //NSLog(@"%@",[formatter stringFromDate:[self.timeArray objectAtIndex:row - 1]]);
        NSTimeInterval secondsInterval= [[self.timeArray objectAtIndex:(row)] timeIntervalSinceDate:[self.timeArray objectAtIndex:row - 1]];
        if (secondsInterval <= 60) {
            isShow = NO;
        }
        else
        {
            showTime = [formatter stringFromDate:[self.timeArray objectAtIndex:row]];
            isShow = YES;
        }
    }
    /*NSLog(@"%@",time);
     NSLog(@"%ld + %ld + %ld +%ld",(long)[components day],(long)[components hour],(long)[components minute],(long)[components second]);*/
    NSDictionary *timeDict = @{@"isShow":[NSNumber numberWithBool:isShow],@"showTime":showTime};
    return timeDict;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HistoryMessageLog *message = [self.messageData objectAtIndex:indexPath.row];
    
    NSString * bodyStr = message.body;
    NSData * bodyData = [bodyStr dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:bodyData options:NSJSONReadingAllowFragments error:nil];
    
    
    //根据文字计算cell的高度
    if ([dic[@"type"] isEqualToNumber:@(SendText)]) {
        NSMutableAttributedString *contentText = [self showFace:dic[@"content"]];
        
        CGRect textBound = [contentText boundingRectWithSize:CGSizeMake(220, 1000) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        
        float height = textBound.size.height + 60;
        return height;
    }
    if ([dic[@"type"] isEqualToNumber:@(SendVoice)])
    {
        return 73;
    }
    
    if ([dic[@"type"] isEqualToNumber:@(SendImage)])
    {
        return 110;
    }
    
    return 100;
    
}

-(void) scrollBottom
{
    if ([self.messageData count]) {
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:self.messageData.count-1 inSection:0];
        [self.chatTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y < 0  && _isRefresh==NO)
    {
        [self loadMoreHistoryData];
    }
}

-(void)loadMoreHistoryData
{
    NSArray *fetchArray = [self.messageLogMode queryMessageResult];
    NSInteger fetchCount = [fetchArray count];
    //NSMutableArray *reloadIndexPathArray = [[NSMutableArray alloc]init];
    if (fetchCount != 0) {  //数据加载完成
        self.chatTableView.tableHeaderView.hidden = NO;
        [self.activity startAnimating];
        self.isRefresh = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            for (NSInteger i = 0; i < fetchCount; i ++) {
                [self.messageData insertObject:fetchArray[i] atIndex:0];
                [self.timeArray insertObject:((HistoryMessageLog *)fetchArray[i]).time atIndex:0];
                //NSIndexPath *tmp=[NSIndexPath indexPathForRow:i inSection:0];
                //[reloadIndexPathArray addObject:tmp];
            }
            //[self.chatTableView reloadRowsAtIndexPaths:reloadIndexPathArray withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.chatTableView reloadData];
            [self.activity stopAnimating];
            self.chatTableView.tableHeaderView.hidden = YES;
            self.isRefresh = NO;
        });
        
    }
}

@end
