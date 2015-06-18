//
//  voiceCell.m
//  MyFamily
//
//  Created by 陆洋 on 15/6/4.
//  Copyright (c) 2015年 maili. All rights reserved.
//

#import "voiceCell.h"
#import <AVFoundation/AVFoundation.h>
@interface voiceCell()
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (strong,nonatomic)NSURL *playURL;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@end
@implementation voiceCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)tapVoiceButton {
    [self httpGetVoice];
}

//网络请求声音
-(void)httpGetVoice
{
    NSData *data = [NSData dataWithContentsOfURL:_playURL];
    NSError *error = nil;
    AVAudioPlayer *player = [[AVAudioPlayer alloc]initWithData:data error:&error];
    if (error) {
        NSLog(@"播放错误：%@",[error description]);
    }
    self.audioPlayer = player;
    [self.audioPlayer play];
    NSLog(@"%@", _playURL);
    
    
}

-(void)setCellValue:(NSURL *)audioURL
{
    _playURL = audioURL;
    self.headImageView.image = [UIImage imageNamed:@"麦粒-app-28"];
}

+(instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *identifier = @"voiceCell";
    
    //缓存中取
    voiceCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    //创建
    if (!cell)
    {
        cell = [[voiceCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    //cell.userInteractionEnabled = NO;  //不让用户点击
    return cell;
}

@end
