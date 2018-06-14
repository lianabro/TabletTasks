//
//  TrialViewController.h
//  Interception
//
//  Created by David Hallin on 2014-05-10.
//  Copyright (c) 2014 Ferocia Solutions Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "trial.h"
#import "idb.h"

@interface TrialViewController : UIViewController <UIAlertViewDelegate>
{
    IBOutlet UIImageView *goldfish;
    int trialStarted, trialCompleted;
    UIImageView *EndOfTrialView;
    trial *currentTrial;
    idb *db;
}

@property (nonatomic, retain) IBOutlet UIImageView *goldfish;
@property (nonatomic, retain) UIImageView *EndOfTrialView;
@property (nonatomic, assign) int trialStarted, trialCompleted;
@property (nonatomic, retain) trial *currentTrial;
@property (nonatomic, retain)     idb *db;

-(IBAction)quit;
-(IBAction)tap;


-(void)saveAndLoadNext;
-(void)moveFish;
-(void)showFish;
-(void)clearFish;
-(void)beginTrial;

@end
