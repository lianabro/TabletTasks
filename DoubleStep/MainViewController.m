//
//  MainViewController.m
//  DoubleStep
//
//  Created by David Hallin on 2014-04-11.
//  Copyright (c) 2014 Ferocia Solutions Inc. All rights reserved.
//

#import "MainViewController.h"
#import "dsdb.h"


@interface MainViewController ()

@end

@implementation MainViewController
@synthesize v1, v2, d, sliderLabel, subject;
@synthesize jumpTypeStatus, jumpTimer;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    d = [[dsdb alloc] init];
        [self getUpdated];
}

-(IBAction)Clear
{
    [d clearDB];
    [self getUpdated];
    [self getCount];
}

-(IBAction)getCount
{
    [v1 setText:[NSString stringWithFormat:@"%d",[d getRecordsCount]]];
}
-(IBAction)getUpdated
{
    NSLog(@"getUpdated Called");
    [v2 setText:[d getRecords]];
    NSLog(@"Finish Call");
    [jumpTypeStatus setText:[d getJumpType]];
    [jumpTimer setValue:[d getJumpTimer] animated:YES];
    [sliderLabel setText:[NSString stringWithFormat:@"%d ms", [d getJumpTimer]]];

}
-(IBAction)LoadNoJumps
{
    [d loadNoJumps];
        [self getUpdated];
        [self getCount];

}
-(IBAction)LoadJumps
{
    [d loadStops];
        [self getUpdated];
        [self getCount];

}
-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)BeginTrials
{
    [self performSegueWithIdentifier:@"pushTrial" sender:self];
}

-(IBAction)releaseToJump
{
        [d setJumpType:@"release"];
        [jumpTypeStatus setText:[d getJumpType]];
}

-(IBAction)appearToJump
{
    [d setJumpType:@"appear"];
        [jumpTypeStatus setText:[d getJumpType]];
}

-(IBAction)jumpTimerChanged
{
    [d setJumpTimer:round(jumpTimer.value)];
    
    [jumpTimer setValue:[d getJumpTimer] animated:YES];
    [sliderLabel setText:[NSString stringWithFormat:@"%d ms", [d getJumpTimer]]];

}
-(IBAction)exportData
{
    [d buildExportTable];
    [self getUpdated];
  
    NSString *HTMLBody = [[NSString alloc] initWithFormat:@"<table><tr><th>Appearance Time</th><th>ReleaseTime</th><th>Diff</th><th>Touch Time</th><th>Diff</th><th>X-Down</th><th>Y-Down</th><th>Did Jump</th><th>initialPlacement</th><th>finalPlacement</th><th>dx</th><th>dy1</th><th>dy2</th><th>absX</th><th>absY1</th><th>absY2</th><th>isStop</th></tr>"];
    
    HTMLBody = [HTMLBody stringByAppendingString:[d getRows]];
    HTMLBody = [HTMLBody stringByAppendingFormat:@"</table><br /><br /><br /><br />Subject: %@<br />Jump Type: %@ <br />Jump Timer:%d ms <br /><br />", subject.text, [d getJumpType], [d getJumpTimer]];
    
    HTMLBody = [HTMLBody stringByAppendingString:[d getAggData]];
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (mailClass != nil) {
        
        MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
        [controller setMessageBody:HTMLBody isHTML:YES];
        [controller setSubject:subject.text];
        if([mailClass canSendMail]) {
            [self presentViewController:controller animated:YES completion:nil];
        }
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	[self becomeFirstResponder];
    //	[self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
