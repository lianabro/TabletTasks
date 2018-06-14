//
//  MainViewController.h
//  DoubleStep
//
//  Created by David Hallin on 2014-04-11.
//  Copyright (c) 2014 Ferocia Solutions Inc. All rights reserved.
//
#import "dsdb.h"
#import <MessageUI/MessageUI.h>
@interface MainViewController : UIViewController <MFMailComposeViewControllerDelegate>
{
    dsdb *d;
    IBOutlet UITextField *v1, *subject;
    IBOutlet UITextView *v2;
    IBOutlet UILabel *jumpTypeStatus, *sliderLabel;
    IBOutlet UISlider *jumpTimer;

}
@property (nonatomic, retain) dsdb *d;
@property (nonatomic, retain) IBOutlet UITextField *v1, *subject;
@property (nonatomic, retain) IBOutlet UITextView *v2;
@property (nonatomic, retain) IBOutlet UILabel *jumpTypeStatus, *sliderLabel;
@property (nonatomic, retain) IBOutlet UISlider *jumpTimer;

-(IBAction)getCount;
-(IBAction)getUpdated;
-(IBAction)LoadNoJumps;
-(IBAction)LoadJumps;
-(IBAction)BeginTrials;
-(IBAction)Clear;

-(IBAction)exportData;

-(IBAction)jumpTimerChanged;

-(IBAction)releaseToJump;
-(IBAction)appearToJump;
@end
