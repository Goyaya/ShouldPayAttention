//
//  ViewController.m
//  AVFoundation-AudioMix
//
//  Created by Gaoyang on 2020/2/28.
//  Copyright © 2020 Goyaya. All rights reserved.
//

#import "ViewController.h"

#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)exportAndPlay:(UIButton *)sender {
    sender.enabled = NO;
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"inputfile" withExtension:@"mp4"];
    
    // resource
    AVAsset *videoAsset = [AVURLAsset URLAssetWithURL:url options:@{AVURLAssetPreferPreciseDurationAndTimingKey: @(YES)}];
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    
    // video track
    AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                        preferredTrackID:kCMPersistentTrackID_Invalid];
    NSError *errorVideo = nil;
    AVAssetTrack *assetVideoTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo]firstObject];
    CMTime endTime = assetVideoTrack.asset.duration;
    [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, assetVideoTrack.asset.duration)
                        ofTrack:assetVideoTrack
                         atTime:kCMTimeZero error:&errorVideo];
    videoTrack.preferredTransform = assetVideoTrack.preferredTransform;
    
    // audio track
    AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    AVAssetTrack *assetAudioTrack = [[videoAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
    [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, assetAudioTrack.asset.duration) ofTrack:assetAudioTrack atTime:kCMTimeZero error:nil];
    
    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
    AVMutableAudioMixInputParameters *mixInputParameters =
    [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:audioTrack];
    audioMix.inputParameters = @[mixInputParameters];
    
    // MARK: attention here
    [mixInputParameters setVolume:0 atTime:CMTimeMakeWithSeconds(0, 600)];
    [mixInputParameters setVolume:1 atTime:CMTimeMakeWithSeconds(5, 600)];
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *outPutFileName = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    NSString *myPathDocs =  [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov",outPutFileName]];
    NSURL* outPutVideoUrl = [NSURL fileURLWithPath:myPathDocs];
    NSLog(@"output file url: %@", outPutVideoUrl);
    
    AVMutableVideoComposition* videoComp = [AVMutableVideoComposition videoComposition];
    videoComp.renderSize = CGSizeMake(1080, 720);
    videoComp.frameDuration = CMTimeMake(1, 30);
    AVMutableVideoCompositionInstruction* instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, endTime);
    AVMutableVideoCompositionLayerInstruction* layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    instruction.layerInstructions = [NSArray arrayWithObjects:layerInstruction, nil];
    videoComp.instructions = [NSArray arrayWithObject: instruction];
    
    
    AVAssetExportSession* exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition
                                                                      presetName:AVAssetExportPresetHighestQuality];
    exporter.outputURL=outPutVideoUrl;
    exporter.outputFileType = AVFileTypeMPEG4;
    exporter.shouldOptimizeForNetworkUse = YES;
    exporter.videoComposition = videoComp;
    exporter.audioMix = audioMix;
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        NSLog(@"done with error: %@", exporter.error);
        dispatch_async(dispatch_get_main_queue(), ^{

            sender.enabled = YES;
            
            AVPlayerViewController *controller = [[AVPlayerViewController alloc] init];
            AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:outPutVideoUrl];
            AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
            controller.player = player;
            [self presentViewController:controller animated:YES completion:nil];
        });
    }];
}

@end
