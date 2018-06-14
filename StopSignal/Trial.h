//
//  Trial.h
//  StopSignal
//
//  Created by David Hallin on 2014-05-14.
//  Copyright (c) 2014 Ferocia Solutions Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Trial : NSObject
{
    int trialNumber, side, isStop, correct;
    NSDate *appearanceTime, *releaseTime, *touchTime, *stopTime;
    float appearTimer, stopTimer;
}

@property (nonatomic, assign) int trialNumber, side, isStop, correct;
@property (nonatomic, retain) NSDate *appearanceTime, *releaseTime, *touchTime, *stopTime;
@property (nonatomic, assign) float appearTimer, stopTimer;

@end
