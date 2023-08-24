//
//  KJAudioRecordManager.m
//  AudioRecord
//
//  Created by TigerHu on 2023/8/24.
//

#import "KJAudioRecordManager.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "KJAACEncoder.h"
#import "KJAACDecoder.h"

@interface KJAudioRecordManager()
<AVAudioPlayerDelegate,
AVCaptureAudioDataOutputSampleBufferDelegate
>

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) NSMutableData *audioData;

//AAC
@property (nonatomic , strong) KJAACEncoder              *aacEncoder;
@property (nonatomic , strong) KJAACDecoder              *aacPlayer;
@property (nonatomic , strong) dispatch_queue_t          AudioQueue;
@property (nonatomic , strong) AVCaptureSession          *session;
@property (nonatomic , strong) AVCaptureConnection       *audioConnection;
@property (nonatomic , strong) NSFileHandle              *audioFileHandle;

@end

@implementation KJAudioRecordManager

- (void)dealloc {
    
    [self.audioFileHandle closeFile];
}


//开始录制AAC
- (void)startRecordAAC
{
    [self createFileToDocument];
    
    if (self.session == nil) {
        [self setupAudioCapture];
        [self.session commitConfiguration];
    }
    [self.session startRunning];
}

//结束录制AAC
- (void)stopRecordAAC
{
    [self.session stopRunning];
}

//播放AAC
- (void)playRecordAAC
{
    self.aacPlayer = [[KJAACDecoder alloc] init];
    [self.aacPlayer play];
}

//停止播放AAC
- (void)stopPlayRecordAAC
{
    [self.aacPlayer stop];
}

#pragma mark 创建文件夹句柄
- (void)createFileToDocument
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.audioData resetBytesInRange:NSMakeRange(0, self.audioData.length)];
        [self.audioData setLength:0];
        
    });
    
    NSString *audioFile = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"audioRecord.aac"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:audioFile]) {
        // 有就移除掉
        [[NSFileManager defaultManager] removeItemAtPath:audioFile error:nil];
    }
    // 移除之后再创建
    [[NSFileManager defaultManager] createFileAtPath:audioFile contents:nil attributes:nil];
    self.audioFileHandle = [NSFileHandle fileHandleForWritingAtPath:audioFile];
}

#pragma mark - 设置音频
- (void)setupAudioCapture
{
    self.aacEncoder = [[KJAACEncoder alloc] init];
    self.session = [[AVCaptureSession alloc] init];
    
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    
    NSError *error = nil;
    AVCaptureDeviceInput *audioInput = [[AVCaptureDeviceInput alloc]initWithDevice:audioDevice error:&error];
    if (error) {
        NSLog(@"Error getting audio input device:%@",error.description);
    }
    
    if ([self.session canAddInput:audioInput]) {
        [self.session addInput:audioInput];
    }
    
    self.AudioQueue = dispatch_queue_create("Audio Capture Queue", DISPATCH_QUEUE_SERIAL);
    
    AVCaptureAudioDataOutput *audioOutput = [AVCaptureAudioDataOutput new];
    [audioOutput setSampleBufferDelegate:self queue:self.AudioQueue];
    
    if ([self.session canAddOutput:audioOutput]) {
        [self.session addOutput:audioOutput];
    }
    
    self.audioConnection = [audioOutput connectionWithMediaType:AVMediaTypeAudio];
}

#pragma mark - 实现 AVCaptureOutputDelegate：
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    if (connection == self.audioConnection) {
        // 音频
        [self.aacEncoder encodeSampleBuffer:sampleBuffer completionBlock:^(NSData *encodedData, NSError *error) {
            if (encodedData) {
                NSLog(@"Audio data (%lu):%@", (unsigned long)encodedData.length,encodedData.description);
                
                [self.audioData appendData:encodedData];
                [self.audioFileHandle writeData:encodedData];
            } else {
                NSLog(@"Error encoding AAC: %@", error);
            }
        }];
    } else {
        // 视频
        
    }
}

#pragma mark - Lazy Load

- (NSMutableData *)audioData{
    if (!_audioData) {
        _audioData = [[NSMutableData alloc] init];
    }
    return _audioData;
}

@end
