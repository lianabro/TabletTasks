//
//  Trial.h
//  DoubleStep
//
//  Created by David Hallin on 2014-04-11.
//  Copyright (c) 2014 Ferocia Solutions Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Trial : NSObject
{
    int trialNumber, xDown, yDown, startPoint, endPoint, isStop;
    NSDate *appearanceTime, *releaseTime, *touchTime;
}

@property (nonatomic, assign) int trialNumber, xDown, yDown, startPoint, endPoint, isStop;
@property (nonatomic, retain) NSDate *appearanceTime, *releaseTime, *touchTime;


@end
