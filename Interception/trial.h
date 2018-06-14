//
//  trial.h
//  Interception
//
//  Created by David Hallin on 2014-05-10.
//  Copyright (c) 2014 Ferocia Solutions Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface trial : NSObject
{
    
    int trialNumber, acc, vel, hit;
    NSDate *timeOfStart, *timeOfTouch;
}

@property (nonatomic, assign) int trialNumber, acc, vel, hit;
@property (nonatomic, retain) NSDate *timeOfStart, *timeOfTouch;

@end
