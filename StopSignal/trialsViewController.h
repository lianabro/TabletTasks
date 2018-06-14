//
//  trialsViewController.h
//  StopSignal
//
//  Created by David Hallin on 2014-05-14.
//  Copyright (c) 2014 Ferocia Solutions Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Trial.h"
#import "ssdb.h"

@interface trialsViewController : UIViewController <UIAlertViewDelegate>
{
    Trial *currentTrial;
    IBOutlet UIButton *redButton;
    IBOutlet UIImageView *image;
    int redDown, trialStarted, trialCompleted;
    ssdb *db;
}

@property (nonatomic, retain) ssdb *db;
@property (nonatomic, retain) Trial *currentTrial;
@property (nonatomic, retain) IBOutlet UIButton *redButton;
@property (nonatomic, retain) IBOutlet UIImageView *image;
@property (nonatomic, assign) int redDown, trialStarted, trialCompleted;


-(IBAction)touchLeft;
-(IBAction)touchRight;
-(IBAction)buttonDown;
-(IBAction)buttonUp;
-(IBAction)Quit;

@end
