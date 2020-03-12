//
//  ScaleTimeRangeViewController.m
//  AVFoundation
//
//  Created by Gaoyang on 2020/3/12.
//  Copyright © 2020 Goyaya. All rights reserved.
//

#import "ScaleTimeRangeViewController.h"

#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ScaleTimeRangeViewController ()

/// exporter
@property (nonatomic, readwrite, strong) AVAssetExportSession *exportSession;
@end

@implementation ScaleTimeRangeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (AVMutableComposition *)buildComposition {
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"inputfile" withExtension:@"mp4"];
    
    // resource
    AVAsset *videoAsset = [AVURLAsset URLAssetWithURL:url options:@{AVURLAssetPreferPreciseDurationAndTimingKey: @(YES)}];
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    
    // video track
    AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                        preferredTrackID:kCMPersistentTrackID_Invalid];
    
    NSError *error = nil;
    AVAssetTrack *assetVideoTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo]firstObject];
    
    [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, assetVideoTrack.asset.duration)
                        ofTrack:assetVideoTrack
                         atTime:kCMTimeZero error:&error];
    videoTrack.preferredTransform = assetVideoTrack.preferredTransform;
    
    // audio track
    AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    AVAssetTrack *assetAudioTrack = [[videoAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
    [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, assetAudioTrack.asset.duration) ofTrack:assetAudioTrack atTime:kCMTimeZero error:nil];
    audioTrack.preferredVolume = assetAudioTrack.preferredVolume;
    
    // MARK: attention here
    // the real duration is 7s
    [mixComposition scaleTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration) toDuration:CMTimeMakeWithSeconds(4, 600)];
    
    return mixComposition;
}

- (IBAction)play:(UIButton *)sender {
    
    AVMutableComposition *mixComposition = [self buildComposition];
    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithAsset:mixComposition];
    
    [self playItem:playerItem];
}

- (IBAction)exportAndPlay:(UIButton *)sender {
    sender.enabled = NO;
    
    AVMutableComposition *mixComposition = [self buildComposition];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *outPutFileName = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    NSString *myPathDocs =  [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov",outPutFileName]];
    NSURL* outPutVideoUrl = [NSURL fileURLWithPath:myPathDocs];
    NSLog(@"output file url: %@", outPutVideoUrl);
    
    AVAssetExportSession* exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition
                                                                      presetName:AVAssetExportPresetHighestQuality];
    self.exportSession = exporter;
    
    exporter.outputURL=outPutVideoUrl;
    exporter.outputFileType = AVFileTypeMPEG4;
    exporter.shouldOptimizeForNetworkUse = YES;
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        NSLog(@"done with error: %@", exporter.error);
        dispatch_async(dispatch_get_main_queue(), ^{

            sender.enabled = YES;
            
            AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:outPutVideoUrl];
            [self playItem:playerItem];
        });
    }];
}

- (void)playItem:(AVPlayerItem *)item {

    AVPlayerViewController *controller = [[AVPlayerViewController alloc] init];
    AVPlayer *player = [AVPlayer playerWithPlayerItem:item];
    controller.player = player;
    [self presentViewController:controller animated:YES completion:nil];
}

@end
