//
//  TrialViewController.m
//  Interception
//
//  Created by David Hallin on 2014-05-10.
//  Copyright (c) 2014 Ferocia Solutions Inc. All rights reserved.
//

#import "TrialViewController.h"

@interface TrialViewController ()

@end

@implementation TrialViewController
@synthesize trialCompleted, trialStarted, currentTrial, EndOfTrialView, goldfish, db;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)quit
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(IBAction)tap
{
    if ((trialStarted > 0) && (trialCompleted < 1))
    {
        NSLog(@"Goldfish is currently at: %2.2f", goldfish.frame.origin.x);
        
    
        if (([self getPosition] > 665) && ([self getPosition] < 903))
        {
            currentTrial.hit = 1;
            currentTrial.timeOfTouch = [NSDate date];
        } else
        {
            currentTrial.hit = 0;
            currentTrial.timeOfTouch = [NSDate date];
        }

        [self showFish];
        trialCompleted = 1;
    }
    
    NSLog(@"Current Trial: %d is a hit : %d", currentTrial.trialNumber, currentTrial.hit);
}
-(void)beginTrial
{
    trialCompleted = 0;
    trialStarted = 1;
    [self moveFish];
    currentTrial.timeOfStart = [NSDate date];
}

-(float)getPosition
{
    float t = [[NSDate date] timeIntervalSinceDate:currentTrial.timeOfStart];
    return (currentTrial.vel * t) + (0.5*currentTrial.acc)*(t*t);
}

-(void)viewDidAppear:(BOOL)animated
{
    db = [[idb alloc] init];
    currentTrial = [db getNextRecord];
    
    [[[UIAlertView alloc] initWithTitle:@"Alert" message:@"Click Ok When you are ready to begin" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self performSelector:@selector(beginTrial) withObject:nil afterDelay:2];
}


-(void)showFish
{
    EndOfTrialView = [[UIImageView alloc] init];
    if (currentTrial.hit == 1) {
        [EndOfTrialView setImage:[UIImage imageNamed:@"SuccessfulHit.png"]];
    } else {
        [EndOfTrialView setImage:[UIImage imageNamed:@"UnsuccessfulHit.png"]];
    }
    
    [EndOfTrialView setFrame:CGRectMake(412, 284, 200, 200)];
    [self.view addSubview:EndOfTrialView];
    
    [self performSelector:@selector(clearFish) withObject:nil afterDelay:3];
}

-(void)clearFish
{
    [EndOfTrialView removeFromSuperview];
    [self saveAndLoadNext];
}

-(void)moveFish
{
    if ((trialStarted > 0) && (trialCompleted < 1))
    {
        //    NSLog(@"MoveFish Called with x = %2.0f", goldfish.frame.origin.x);
        int x = 0;
        double timeInt = [[NSDate date] timeIntervalSinceDate:currentTrial.timeOfStart];
        
        x = (currentTrial.vel * timeInt) + ((0.5*currentTrial.acc)*timeInt*timeInt) + 25;
        [goldfish setFrame:CGRectMake(x, goldfish.frame.origin.y, goldfish.frame.size.width, goldfish.frame.size.height)];
        if (goldfish.frame.origin.x < self.view.bounds.size.width)
        {
            [self performSelector:@selector(moveFish) withObject:nil afterDelay:0.01];
        }
    }
}

-(void)saveAndLoadNext
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"HH:mm:ss.SSS"];
    
    [db insertQuery:[NSString stringWithFormat:@"UPDATE trials set hit = %d, timeOfStart='%@', timeOfTouch='%@' where trialNumber = %d", currentTrial.hit, [df stringFromDate:currentTrial.timeOfStart], [df stringFromDate:currentTrial.timeOfTouch], currentTrial.trialNumber]];
    
    currentTrial = [db getNextRecord];
    
    if ((currentTrial.trialNumber > 0))
    {
        [self beginTrial];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
