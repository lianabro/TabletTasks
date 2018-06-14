//
//  ViewController.m
//  StopSignal
//
//  Created by David Hallin on 2014-05-14.
//  Copyright (c) 2014 Ferocia Solutions Inc. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize  db, subjectName, trialsView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    db = [[ssdb alloc] init];
        [trialsView setText:[db getRecords]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)Empty
{
    [db clearDB];
    [trialsView setText:[db getRecords]];
}
-(IBAction)LoadTrials
{
    [db loadTrials];
    [trialsView setText:[db getRecords]];
}
-(IBAction)ExportResults
{
    //Nothing yhet
    [trialsView setText:[db getRecords]];
    
    NSString *HTMLBody = [db getRows];
    HTMLBody = [HTMLBody stringByAppendingString:[db getOtherData]];
    HTMLBody = [HTMLBody stringByAppendingString:[NSString stringWithFormat:@"<br /><b>Subject Name:</b> %@", subjectName.text]];
    
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (mailClass != nil) {
        
        MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
        [controller setMessageBody:HTMLBody isHTML:YES];
        [controller setSubject:subjectName.text];
        if([mailClass canSendMail]) {
            [self presentViewController:controller animated:YES completion:nil];
        }
    }
}
-(IBAction)BeginTrials
{
//    nothing yet
    [self performSegueWithIdentifier:@"beginTrials" sender:self];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	[self becomeFirstResponder];
    //	[self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
