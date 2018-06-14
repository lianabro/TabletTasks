//
//  ViewController.h
//  Interception
//
//  Created by David Hallin on 2014-05-10.
//  Copyright (c) 2014 Ferocia Solutions Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "idb.h"
#import <MessageUI/MessageUI.h>

@interface ViewController : UIViewController <MFMailComposeViewControllerDelegate>
{
    IBOutlet UILabel *AccLabel, *VelLabel;
    IBOutlet UISlider *AccSlider, *VelSlider;
    IBOutlet UITextField *subjectName;
    IBOutlet UITextView *resultSet;
    idb *db;
}

@property (nonatomic, retain)     idb *db;
@property (nonatomic, retain) IBOutlet UILabel *AccLabel, *VelLabel;
@property (nonatomic, retain) IBOutlet UISlider *AccSlider, *VelSlider;
@property (nonatomic, retain) IBOutlet UITextField *subjectName;
@property (nonatomic, retain) IBOutlet UITextView *resultSet;


-(IBAction)velSliderChange;
-(IBAction)accSliderChange;

-(IBAction)load5;
-(IBAction)load10;
-(IBAction)empty;
-(IBAction)refresh;
-(IBAction)exportData;
-(IBAction)beginTrials;

@end
