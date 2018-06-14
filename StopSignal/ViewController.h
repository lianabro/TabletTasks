//
//  ViewController.h
//  StopSignal
//
//  Created by David Hallin on 2014-05-14.
//  Copyright (c) 2014 Ferocia Solutions Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ssdb.h"
#import <MessageUI/MessageUI.h>

@interface ViewController : UIViewController <MFMailComposeViewControllerDelegate>
{
    IBOutlet UITextField *subjectName;
    IBOutlet UITextView *trialsView;
    ssdb *db;
}

@property (nonatomic, retain) IBOutlet UITextField *subjectName;
@property (nonatomic, retain) IBOutlet UITextView *trialsView;
@property (nonatomic, retain) ssdb *db;
-(IBAction)Empty;
-(IBAction)LoadTrials;
-(IBAction)ExportResults;
-(IBAction)BeginTrials;


@end
