//
//  KJAudioRecordManager.h
//  AudioRecord
//
//  Created by TigerHu on 2023/8/24.
//

#import <Foundation/Foundation.h>

@interface KJAudioRecordManager : NSObject

//开始录制AAC
- (void)startRecordAAC;

//结束录制AAC
- (void)stopRecordAAC;

//开始播放AAC
- (void)playRecordAAC;

//停止播放AAC
- (void)stopPlayRecordAAC;

@end

