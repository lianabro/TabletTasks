//
//  TrialViewController.m
//  DoubleStep
//
//  Created by David Hallin on 2014-04-11.
//  Copyright (c) 2014 Ferocia Solutions Inc. All rights reserved.
//

#import "TrialViewController.h"
#import "dsdb.h"
@interface TrialViewController ()

@end

@implementation TrialViewController
@synthesize grey1, grey2, grey3, grey4, grey5, redButton, red;
@synthesize trialBegan, redDown, trialComplete, currentTrial, jumpTimer, jumpType, d;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)newTrial
{
    if (currentTrial.trialNumber < 0)
    {
        [self exit];
    } else
    {
    currentTrial = [d getNextRecord];
    trialBegan = false;
    redDown = false;
    trialComplete = false;
    
    [redButton setEnabled:YES];
    [redButton setAlpha:1.0f];
    [self setGrey:0];
    }
}

-(void)saveTrial {

    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"HH:mm:ss.SSS"];
    
    [d insertQuery:[NSString stringWithFormat:@"UPDATE doubleStep set xDown = %d, yDown = %d, appearanceTime = '%@', releaseTime = '%@', touchTime = '%@' where trialNumber = %d",
                     currentTrial.xDown,
                     currentTrial.yDown,
                     [df stringFromDate:currentTrial.appearanceTime], [df stringFromDate:currentTrial.releaseTime], [df stringFromDate:currentTrial.touchTime],
                     currentTrial.trialNumber
                     ]];
    NSLog(@"Saving Trial: %@", [NSString stringWithFormat:@"UPDATE doubleStep set xDown = %d, yDown = %d, appearanceTime = '%@', releaseTime = '%@', touchTime = '%@' where trialNumber = %d",
                                currentTrial.xDown,
                                currentTrial.yDown,
                                [df  stringFromDate:currentTrial.appearanceTime],
                                [df  stringFromDate:currentTrial.releaseTime],
                                [df  stringFromDate:currentTrial.touchTime],
                                currentTrial.trialNumber
                                ]);
}

-(void)setGrey:(int)var
{
        [grey1 setAlpha:0.0f];
        [grey2 setAlpha:0.0f];
        [grey3 setAlpha:0.0f];
        [grey4 setAlpha:0.0f];
        [grey5 setAlpha:0.0f];
        [red setAlpha:0.0f];
    if (var == 1)
    {
        [grey1 setAlpha:1.0f];
    } else if (var == 2)
    {
        [grey2 setAlpha:1.0f];
    } else if (var == 3)
    {
        [grey3 setAlpha:1.0f];
    } else if (var == 4)
    {
        [grey4 setAlpha:1.0f];
    } else if (var == 5)
    {
        [grey5 setAlpha:1.0f];
    } else if (var == -1)
    {
        [red setAlpha:1.0f];
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
        //create the buttons to press
        d = [[dsdb alloc] init];
        jumpType = [d getJumpType];
        jumpTimer = ([d getJumpTimer]/1000);
        for (int ypos = 0; ypos < 80; ypos++)
        {
            for (int pos = 0; pos < 59; pos++) {
                UIButton *but = [UIButton buttonWithType:UIButtonTypeCustom];
                [but setFrame:CGRectMake(89+(pos*10), 0+(ypos*10), 10, 10)];
                [but addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
                [self.view addSubview:but];
            }
        }
    [self newTrial];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(IBAction)exit
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(IBAction)touchDown:(id)sender
{
     if (trialBegan)
    {
          trialComplete = true;
        NSDate *Todaysdate = [NSDate date];
        
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"HH:mm:ss.SSS"];
        
        UIButton *but = (UIButton *)sender;
    
        NSLog(@"Touch Down! - X: %2.2f, y:%2.2f-Time of Touch: %@", but.frame.origin.x + 5, but.frame.origin.y + 5, [df stringFromDate:Todaysdate]);
        currentTrial.touchTime = Todaysdate;
        
        NSLog(@"Trial Complete - X: %2.2f, y:%2.2f- Time of Appearance: %@, Time of Release: %@, Time of Touch: %@", but.frame.origin.x + 5, but.frame.origin.y + 5, [df stringFromDate:currentTrial.appearanceTime], [df stringFromDate:currentTrial.releaseTime], [df stringFromDate:currentTrial.touchTime]);
        
        currentTrial.xDown = but.frame.origin.x +5;
        currentTrial.yDown = 1024 - (but.frame.origin.y +5);

        [self saveTrial];
    }
    
    [self newTrial];
}

-(void)endTrial
{
    if (trialComplete == false)
    {
        trialComplete = true;
        [self saveTrial];
        [self newTrial];
    }
}

-(IBAction)buttonDown
{
    redDown = TRUE;
    NSLog(@"button down");
    //Pause before executing the trial
    if (!trialBegan)
    {
        
        int minimum=1;
        int maximum=4;
        int randomTime=(arc4random()%(maximum-minimum))+minimum;
        [self performSelector:@selector(beginTrial) withObject:nil afterDelay:randomTime];
    }

}

-(IBAction)buttonUp
{
    redDown = FALSE;
    NSLog(@"Button Up");
    if (trialBegan)
    {
        
        currentTrial.releaseTime = [[NSDate alloc] init];
        currentTrial.releaseTime = [NSDate date];
        
        NSLog(@"Hide button");
        [redButton setAlpha:0.0f];
        [redButton setEnabled:NO];
        
        if ([jumpType isEqualToString:@"release"])
        {
            [self performSelector:@selector(jump) withObject:nil afterDelay:jumpTimer];
        }
    }
    
}

-(void)jump
{
    if (currentTrial.startPoint != currentTrial.endPoint)
    {
        [self setGrey:currentTrial.endPoint];
    }
    
    if (currentTrial.isStop > 0)
    {
        [self setGrey:-1];
        [self performSelector:@selector(endTrial) withObject:nil afterDelay:3];
    }
}

-(void)beginTrial
{
    if (redDown)
    {
        trialBegan = TRUE;
        [self setGrey:currentTrial.startPoint];
        currentTrial.appearanceTime = [[NSDate alloc] init];
        currentTrial.appearanceTime = [NSDate date];
        
        if ([jumpType isEqualToString:@"appear"])
        {
            [self performSelector:@selector(jump) withObject:nil afterDelay:jumpTimer];
        }
    }
}

@end
