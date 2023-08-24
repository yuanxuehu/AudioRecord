//
//  ViewController.m
//  AudioRecord
//
//  Created by TigerHu on 2023/8/24.
//

#import "ViewController.h"
#import <Masonry/Masonry.h>
#import <AVFoundation/AVFoundation.h>
#import "KJAudioRecordManager.h"
#import "KJVoiceAnimatedView.h"

@interface ViewController ()

@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIButton *recordButton;
@property (nonatomic, strong) UIButton *playBtn;

@property (nonatomic, strong) NSDate *lastDate;//开始录制时间
@property (nonatomic, assign) BOOL hasRecordPermission;//麦克风权限
@property (nonatomic, strong) dispatch_source_t timer;

@property (nonatomic, strong) KJVoiceAnimatedView *animatedView;
@property (nonatomic, strong) KJAudioRecordManager *manager;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.whiteColor;
    self.title = @"AudioRecord";
    
    [self setupUI];
}

- (void)setupUI
{
    [self.view addSubview:self.timeLabel];
    [self.view addSubview:self.recordButton];
    [self.view addSubview:self.animatedView];
    [self.view addSubview:self.playBtn];

    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_offset(245);
        make.centerX.equalTo(self.view.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(60, 20));
    }];
    [self.recordButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.timeLabel.mas_bottom).offset(25);
        make.centerX.equalTo(self.view.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(100, 100));
    }];
    [self.animatedView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.bottom.equalTo(self.timeLabel.mas_top).offset(-50);
        make.size.mas_equalTo(CGSizeMake(85, 85));
    }];
    
    [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.bottom.equalTo(self.view.mas_bottom).offset(-130);
        make.size.mas_equalTo(CGSizeMake(120.0, 40.0));
    }];
    
}

#pragma mark - Event Handle

- (void)startRecord
{
    //开始录制⏺
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    switch (audioSession.recordPermission) {
        case AVAudioSessionRecordPermissionUndetermined: //用户还未选择马克风权限
        {//弹出权限选择
            if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
                [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
                    
                }];
            }
        }
            break;
        case AVAudioSessionRecordPermissionDenied: //用户禁止麦克风权限
        {//提示用户跳转设置打开权限
            self.hasRecordPermission = NO;
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"没有权限" message:@"请打开麦克风🎤权限" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }]];
            [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if ([[UIApplication sharedApplication] canOpenURL:url]) {
                    [[UIApplication sharedApplication] openURL:url options:nil completionHandler:nil];
                }
            }]];
            [self presentViewController:alert animated:YES completion:nil];
        }
            break;
        case AVAudioSessionRecordPermissionGranted://用户允许麦克风权限
        {
            self.hasRecordPermission = YES;
            
            self.animatedView.hidden = NO;
            [self.animatedView startAniamted];
            
            [self.manager startRecordAAC];
        
            self.lastDate = [NSDate date];
            
            //计时
            __block int second = 0;
            self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));
            dispatch_source_set_timer(self.timer, DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC, 0);
            dispatch_source_set_event_handler(self.timer, ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (second < 10) {
                        self.timeLabel.text = [NSString stringWithFormat:@"00:0%d", second];
                    } else {
                        self.timeLabel.text = [NSString stringWithFormat:@"00:%d", second];
                    }
                    second++;
                });
            });
            dispatch_resume(_timer);
        }
            break;
            
        default:
            break;
    }
}

- (void)endRecord{
    if (self.hasRecordPermission) {
        
        [self.manager stopRecordAAC];
        
        //注销计时器
        if (_timer) {
            dispatch_source_cancel(_timer);
            _timer = nil;
        }
        
        // UI
        NSInteger timeDistance = [[NSDate date] timeIntervalSinceDate:self.lastDate];
        if (timeDistance < 3) {
            NSLog(@"录音少于3s");
//            [self.finishBtn setEnabled:NO];
//            [self.finishBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
//            [MBProgressHUD showMessage:[NSString ja_deviceSetting_time_too_short_prompt] forView:self];
        } else if (timeDistance > 10) {
            NSLog(@"录音超过10s");
//            [self.finishBtn setEnabled:NO];
//            [self.finishBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
//            [MBProgressHUD showMessage:[NSString ja_deviceSetting_time_too_long_prompt] forView:self];
        } else {
//            [self.finishBtn setEnabled:YES];
//            [self.finishBtn setTitleColor:[UIColor theme_Color] forState:UIControlStateNormal];
        }
        
        self.animatedView.hidden = YES;
        [self.animatedView stopAnimated];
        
        [self.playBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [self.playBtn setEnabled:YES];
        
    }
}

- (void)playAction
{
    [self.playBtn setBackgroundColor:[UIColor clearColor]];
    [self.manager playRecordAAC];
}

- (void)touchDownPlayAction
{
    [self.playBtn setBackgroundColor:[UIColor blueColor]];
}

#pragma mark - Lazy Load

- (UILabel *)timeLabel
{
    if (!_timeLabel) {
        _timeLabel = [UILabel new];
        _timeLabel.text = @"00:00";
        _timeLabel.numberOfLines = 0;
        _timeLabel.font = [UIFont systemFontOfSize:12];
        _timeLabel.textColor = [UIColor blackColor];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _timeLabel;
}

- (UIButton *)recordButton
{
    if (!_recordButton) {
        _recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_recordButton setImage:[UIImage imageNamed:@"icon_voice_record"] forState:UIControlStateNormal];
        [_recordButton addTarget:self action:@selector(startRecord) forControlEvents:UIControlEventTouchDown];
        [_recordButton addTarget:self action:@selector(endRecord) forControlEvents:UIControlEventTouchUpInside];
        [_recordButton addTarget:self action:@selector(endRecord) forControlEvents:UIControlEventTouchCancel];
        [_recordButton addTarget:self action:@selector(endRecord) forControlEvents:UIControlEventTouchUpOutside];
    }
    return _recordButton;
}

- (UIButton *)playBtn {
    if (!_playBtn) {
        _playBtn = [UIButton new];
        [_playBtn.layer setBorderColor:[UIColor grayColor].CGColor];
        [_playBtn.layer setBorderWidth:0.5];
        [_playBtn setTitle:@"播放" forState:UIControlStateNormal];
        [_playBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_playBtn setTitleColor:[UIColor greenColor] forState:UIControlStateSelected];
        [_playBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [_playBtn addTarget:self action:@selector(playAction) forControlEvents:UIControlEventTouchUpInside];
        [_playBtn addTarget:self action:@selector(touchDownPlayAction) forControlEvents:UIControlEventTouchDown];
        [_playBtn setEnabled:NO];
        
        _playBtn.layer.cornerRadius = 3;
        _playBtn.clipsToBounds = YES;
    }
    return _playBtn;
}

- (KJVoiceAnimatedView *)animatedView
{
    if (!_animatedView) {
        _animatedView = [KJVoiceAnimatedView new];
        _animatedView.layer.cornerRadius = 6.18;
        _animatedView.hidden = YES;
    }
    return _animatedView;
}

- (KJAudioRecordManager *)manager {
    if (!_manager) {
        _manager = [[KJAudioRecordManager alloc] init];
    }
    return _manager;
}

@end
