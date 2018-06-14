//
//  trialsViewController.m
//  StopSignal
//
//  Created by David Hallin on 2014-05-14.
//  Copyright (c) 2014 Ferocia Solutions Inc. All rights reserved.
//

#import "trialsViewController.h"

@interface trialsViewController ()

@end

@implementation trialsViewController
@synthesize currentTrial, redButton, image, redDown, trialStarted, db, trialCompleted;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(void)save
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"HH:mm:ss.SSS"];
    
    [db insertQuery:[NSString stringWithFormat:@"UPDATE trials set appearanceTime = '%@', releaseTime = '%@', touchTime = '%@', stopTime = '%@', correct = %d where trialNumber = %d", [df stringFromDate:currentTrial.appearanceTime], [df stringFromDate:currentTrial.releaseTime], [df stringFromDate:currentTrial.touchTime], [df stringFromDate:currentTrial.stopTime], currentTrial.correct, currentTrial.trialNumber]];
    
    [self loadNewTrial];
}

-(void)loadNewTrial
{
    currentTrial = [db getNextRecord];
    trialCompleted= 0;
    trialStarted = 0;
    redDown = 0;
    
    [image setAlpha:0.0f];
    [redButton setAlpha:1.0f];
    [redButton setEnabled:YES];
    
    if (currentTrial.trialNumber == -1)
    {
        [self Quit];
    }
}

-(void)endTrial:(NSNumber *)trialN
{
    int trialNum = [trialN integerValue];
    
    NSLog(@"END TRIAL CALLED with trialstarted = %d and trialcompleted = %d", trialStarted, trialCompleted);
    if ((trialStarted > 0) && (trialCompleted == 0) && (trialNum == currentTrial.trialNumber))
    {
        if ((currentTrial.isStop == 1) && ([[NSDate date] timeIntervalSinceDate:currentTrial.stopTime] > 0))
        {
            currentTrial.correct = 1;
        } else
        {
            currentTrial.correct = 0;
        }
        
        [self save];
    }
}

-(void)beginTrial
{
    if (redDown  == 1)
    {
        trialStarted = 1;
        currentTrial.appearanceTime = [NSDate date];
        
        if (currentTrial.side == -1)
        {   //LEFT
            [image setImage:[UIImage imageNamed:@"GreenCircle.png"]];
            [image setAlpha:1.0f];
        } else
        {   //RIGHT
            [image setImage:[UIImage imageNamed:@"BlueCircle.png"]];
            [image setAlpha:1.0f];
        }
        NSNumber *passedValue = [NSNumber numberWithInt:currentTrial.trialNumber];
        [self performSelector:@selector(endTrial:) withObject:passedValue afterDelay:3];
    }
}

-(void)stopTrial:(NSNumber *)trialN
{
    int trialNum = [trialN integerValue];
    
    if ((redDown + trialStarted > 0) && (trialNum == currentTrial.trialNumber) && (currentTrial.isStop == 1))
    {
        currentTrial.stopTime = [NSDate date];
        [image setImage:[UIImage imageNamed:@"RedCircle.png"]];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    db = [[ssdb alloc] init];
    
    if ([db getRecordsCount] > 0)
    {
        NSLog(@"Number of Trials: %d", [db getRecordsCount]);
        [self loadNewTrial];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Notice" message: @"Touch the Red button until a dot appears at the top, if the dot is blue, tap the right side of the screen.  If the dot is green tap the left side of the screen.  And if the dot turns red, don't touch anything" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    } else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Notice" message: @"There are no trials, Please load some through the configuration, then try again" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([db getRecordsCount]  < 1)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)touchLeft
{
    if (trialStarted == 1)
    {
        NSLog(@"LEFT TOUCH STARTED");
        currentTrial.touchTime = [NSDate date];
        trialCompleted = 1;
        if (currentTrial.isStop  == 0)
        {
            if (currentTrial.side == -1)
            {
                currentTrial.correct = 1;
            } else
            {
                currentTrial.correct = 0;
            }
        } else {
            currentTrial.correct = 0;
        }
        [self save];
    }
}

-(IBAction)touchRight
{
    if (trialStarted == 1)
    {
       NSLog(@"RIGHT TOUCH STARTED");
                currentTrial.touchTime = [NSDate date];
        trialCompleted = 1;
        if (currentTrial.isStop  == 0)
        {
            if (currentTrial.side == 1)
            {
                currentTrial.correct = 1;
            } else
            {
                currentTrial.correct = 0;
            }
        } else {
            
            currentTrial.correct = 0;
        }
        [self save];
        
    }
}

-(IBAction)buttonDown
{
    if (trialStarted == 0)
    {
        NSNumber *trialNum = [NSNumber numberWithInt:currentTrial.trialNumber];
        
        redDown = 1;
        [self performSelector:@selector(beginTrial) withObject:nil afterDelay:currentTrial.appearTimer];
        [self performSelector:@selector(stopTrial:) withObject:trialNum afterDelay:currentTrial.stopTimer];
    }
}

-(IBAction)buttonUp
{
    if (trialStarted == 1)
    {
        currentTrial.releaseTime = [NSDate date];
        [redButton setAlpha:0];
        [redButton setEnabled:NO];
    }
    redDown = 0;
}

-(IBAction)Quit
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
