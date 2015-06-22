//
//  MemberViewController.m
//  MyFamily
//
//  Created by 陆洋 on 15/6/2.
//  Copyright (c) 2015年 maili. All rights reserved.
//

#import "MemberViewController.h"
#import "ChatViewController.h"
#import "UIImage+ReSize.h"
#import "UITableView+Improve.h"
@interface MemberViewController ()<UITableViewDataSource,UITableViewDelegate>

//存放家庭和成员的数据
@property (strong,nonatomic)NSArray *memberData;
@end

@implementation MemberViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //navigation bar设置背景色,字体色
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0/255 green:149.0/255 blue:135.0/255 alpha:1];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    [self.tableView improveTableView];
    //添加邀请家庭成员栏
    [self addMemberBar];
    
    //模拟从数据库取出的数据
    [self initData];
}

-(void)initData
{
    //存放的是从数据库取出的数据类型，在根据人去message里查，以时间排序,直接在数据库里排，这个要考虑
    self.memberData = [[NSArray alloc]initWithObjects:@"自己",@"叔叔",@"哥哥",@"姐姐",@"妈妈",@"爸爸",@"爷爷",@"奶奶",@"外公", nil];
}

#define addIconWidht 20
#define addIconHeight 20
#define textFieldHeight 30
#define padding 10
#define screenWidth [UIScreen mainScreen].bounds.size.width
#define screenHeight [UIScreen mainScreen].bounds.size.height
-(void)addMemberBar
{
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    UITextField *textfield = [[UITextField alloc]initWithFrame:CGRectMake(padding, padding, screenWidth-2*padding, textFieldHeight)];
    [textfield setBorderStyle:UITextBorderStyleRoundedRect]; //外框类型
    textfield.userInteractionEnabled = NO;
    [headerView addSubview:textfield];
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(2*padding, padding + 5, addIconWidht, addIconHeight)];
    imageView.image = [UIImage imageNamed:@"麦粒-app-20"];
    [headerView addSubview:imageView];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(3*padding + addIconWidht, padding + 5, screenWidth - 2*padding, addIconHeight)];
    [label setFont:[UIFont fontWithName:@"Helvetica" size:10.0]];
    label.textColor = [UIColor grayColor];
    label.text = @" 邀请家庭成员";
    [headerView addSubview:label];
    
    //邀请好友消息通知
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth-3*padding, padding - 1, 15, 15)];
    [button setBackgroundImage:[UIImage imageNamed:@"麦粒-app-27"] forState:UIControlStateNormal];
    button.hidden = NO;
    /*if () {      // 做判断，如果没有消息，则不显示
        button.hidden = YES;
    }*/
    [button setTitle:@"4" forState:UIControlStateNormal];  //显示消息条数
    [headerView addSubview:button];
    
    headerView.backgroundColor = [UIColor colorWithRed:246.0/255 green:247.0/255 blue:247.0/255 alpha:1];
    self.tableView.tableHeaderView = headerView;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.memberData count];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MemberCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MemberCell"];
    }
    //不用自定义cell，但是可以设置cell的imageview中image的大小
    UIImage *headIcon = [UIImage imageNamed:@"麦粒-app-28"];
    cell.imageView.image = [headIcon reSizeImagetoSize:CGSizeMake(40, 40)];
    cell.textLabel.text = self.memberData[indexPath.row];
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
