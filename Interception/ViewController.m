//
//  ViewController.m
//  Interception
//
//  Created by David Hallin on 2014-05-10.
//  Copyright (c) 2014 Ferocia Solutions Inc. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize AccLabel, VelLabel, AccSlider, VelSlider, subjectName, resultSet, db;


-(IBAction)velSliderChange
{
    [VelSlider setValue:round(VelSlider.value)];
    [VelLabel setText:[NSString stringWithFormat:@"%2.0f pixels/s", round(VelSlider.value)]];
}
-(IBAction)accSliderChange
{
    [AccSlider setValue:round(AccSlider.value)];
    [AccLabel setText:[NSString stringWithFormat:@"%2.0f pixels/s/s", round(AccSlider.value)]];
}

-(IBAction)load5
{
    [db loadFive:(int)VelSlider.value andAccel:(int)AccSlider.value];
    [self refresh];
}
-(IBAction)load10
{
    [db loadTen:(int)VelSlider.value andAccel:(int)AccSlider.value];
    [self refresh];
}
-(IBAction)empty
{
    [db clearDB];
    [self refresh];
}
-(IBAction)refresh
{
    [resultSet setText:[db getRecords]];
}
-(IBAction)exportData
{
    NSLog(@"Export Data Called");
    [db buildExportTable];
    
    NSString *HTMLBody = [NSString stringWithFormat:@"%@", [db getRows]];

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

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	[self becomeFirstResponder];
    //	[self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(IBAction)beginTrials
{
    [self performSegueWithIdentifier:@"beginTrials" sender:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    db = [[idb alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
