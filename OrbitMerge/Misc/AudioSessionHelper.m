//
//  AudioSessionHelper.m
//  OrbitMerge
//
//  Created by Alan Lou on 9/23/18.
//  Copyright © 2018 Rawwr Studios. All rights reserved.
//

#import "AudioSessionHelper.h"
#import <Foundation/Foundation.h>

@implementation AudioSessionHelper: NSObject

+ (BOOL) setAudioSessionWithError:(NSError **) error {
    BOOL success = [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:error];
    if (!success && error) {
        return false;
    } else {
        return true;
    }
}
@end
