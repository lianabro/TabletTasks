//
//  TrialViewController.h
//  DoubleStep
//
//  Created by David Hallin on 2014-04-11.
//  Copyright (c) 2014 Ferocia Solutions Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Trial.h"
#import "dsdb.h"
@interface TrialViewController : UIViewController
{
    IBOutlet UIImageView *grey1, *grey2, *grey3, *grey4, *grey5, *red;
    IBOutlet UIButton *redButton;
    BOOL trialBegan, redDown, trialComplete;
    Trial *currentTrial;
    NSString *jumpType;
    float jumpTimer;
    dsdb *d;
}
@property (nonatomic, retain) IBOutlet UIImageView *grey1, *grey2, *grey3, *grey4, *grey5, *red;
@property    (nonatomic, retain) IBOutlet UIButton *redButton;
@property (nonatomic, assign) BOOL trialBegan, redDown, trialComplete;
@property (nonatomic, retain) Trial *currentTrial;
@property (nonatomic, retain) NSString *jumpType;
@property (nonatomic, assign) float jumpTimer;
@property (nonatomic, retain) dsdb *d;

-(IBAction)exit;
-(IBAction)touchDown:(id)sender;
-(IBAction)buttonDown;
-(IBAction)buttonUp;

@end
