//
//  AudioSessionHelper.h
//  OrbitMerge
//
//  Created by Alan Lou on 9/23/18.
//  Copyright © 2018 Rawwr Studios. All rights reserved.
//

#ifndef AudioSessionHelper_h
#define AudioSessionHelper_h
#import <AVFoundation/AVFoundation.h>

@interface AudioSessionHelper: NSObject
+ (BOOL) setAudioSessionWithError:(NSError **) error;
@end

#endif /* AudioSessionHelper_h */
