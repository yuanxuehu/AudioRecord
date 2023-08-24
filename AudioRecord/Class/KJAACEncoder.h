//
//  KJAACEncoder.h
//  AudioRecord
//
//  Created by TigerHu on 2023/8/24.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface KJAACEncoder : NSObject

- (void) encodeSampleBuffer:(CMSampleBufferRef)sampleBuffer completionBlock:(void (^)(NSData *encodedData, NSError* error))completionBlock;

@end
