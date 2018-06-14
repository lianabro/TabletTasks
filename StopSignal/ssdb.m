//
//  ssdb.m
//  StopSignal
//
//  Created by David Hallin on 2014-05-14.
//  Copyright (c) 2014 Ferocia Solutions Inc. All rights reserved.
//

#import "ssdb.h"
#import "Trial.h"
@implementation ssdb
@synthesize databaseName, databasePath;
static  ssdb *_database;

+(ssdb*)database {
    if (_database == nil)
    {
        _database = [[ssdb alloc] init];
    }
    return _database;
}

-(id)init {
    if ((self = [super init])) {
        [self checkAndCreateDatabase];
        
        if (sqlite3_open([databasePath UTF8String], &_database) != SQLITE_OK)
        {
            NSLog(@"Failed To Open Database");
        }
        
    }
    return self;
    
}

-(void)checkAndCreateDatabase
{
    databaseName = @"db.sqlite";
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [documentPaths objectAtIndex:0];
    
    databasePath = [documentsDir stringByAppendingPathComponent:databaseName];
    
    BOOL success;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    success = [fileManager fileExistsAtPath:databasePath];
    
    if (success) return;
    
    NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:databaseName];
    [fileManager copyItemAtPath:databasePathFromApp toPath:databasePath error:nil];
}

- (Trial *)getNextRecord {
    Trial *retVal = [[Trial alloc] init];
    NSString *query = @"Select * from trials where appearanceTime IS NULL ORDER BY RANDOM() LIMIT 1;";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil)
        == SQLITE_OK) {
        if (sqlite3_step(statement) == SQLITE_ROW) {
            retVal.trialNumber = sqlite3_column_int(statement, 0);
            retVal.side = sqlite3_column_int(statement, 1);
            retVal.isStop = sqlite3_column_int(statement, 2);
            //APPEARANCE TIME
            //Release TIME
            //TOUCHTIME
            //STop Time
            //This field should not be loaded by this function - retVal.correct = sqlite3_column_int(statement, 7);
            retVal.appearTimer = sqlite3_column_double(statement, 8);
            retVal.stopTimer = sqlite3_column_double(statement, 9);
        } else
        {
            retVal.trialNumber = -1;
        }
        sqlite3_finalize(statement);
    }
    return retVal;
}



-(void)insertQuery:(NSString *)stringQuery
{
    NSLog(@"%@", stringQuery);
    sqlite3_stmt *statement;
    if(sqlite3_prepare_v2(_database, [stringQuery UTF8String], -1, &statement, nil) == SQLITE_OK) {
        if (sqlite3_step(statement))
        {
            NSLog(@"Successfully inserted/updated");
        }
        sqlite3_finalize(statement);
    }
}

-(void)loadTrials
{
  
    NSArray *vars = [NSArray arrayWithObjects:  [NSNumber numberWithFloat:0.05f],
                     [NSNumber numberWithFloat:0.10f],
                     [NSNumber numberWithFloat:0.15f],
                     [NSNumber numberWithFloat:0.2f],
                     nil];
    for (int i = 0; i < 8; i++)
    {
        [self insertQuery:[NSString stringWithFormat:@"INSERT INTO trials (side, isStop, appearTimer, stopTimer) VALUES (-1, 0, %2.3f, 0)", ((arc4random()% 20))/10.0f]];
        [self insertQuery:[NSString stringWithFormat:@"INSERT INTO trials (side, isStop, appearTimer, stopTimer) VALUES (1, 0, %2.3f, 0)", ((arc4random()% 20))/10.0f]];
    }
    
    
    for (int i = 0; i<2; i++)
    {
        float appearTimer1 =((arc4random()% 20))/10.0f;
        float appearTimer2 =((arc4random()% 20))/10.0f;
        
        [self insertQuery:[NSString stringWithFormat:@"INSERT INTO trials (side, isStop, appearTimer, stopTimer) VALUES (-1, 1, %2.3f, %2.3f)", appearTimer1, appearTimer1 + [[vars objectAtIndex:i] floatValue]]];
        [self insertQuery:[NSString stringWithFormat:@"INSERT INTO trials (side, isStop, appearTimer, stopTimer) VALUES (1, 1, %2.3f, %2.3f)", appearTimer2, appearTimer2 + [[vars objectAtIndex:i+1] floatValue]]];
    }
    
    if ([self getRecordsCount] < 9)
    {
        [self insertQuery:@"drop table trials"];
        [self insertQuery:@"CREATE TABLE trials (trialNumber INTEGER PRIMARY KEY, side INTEGER, isStop INTEGER, appearanceTime TEXT, releaseTime TEXT, touchTime TEXT, stopTime TEXT, correct INTEGER, appearTimer REAL, stopTimer REAL)"];
        [self loadTrials];
    }
}

-(int)getRecordsCount {
    int retVal;
    NSString *query = @"Select COUNT(*) from trials;";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil)
        == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            retVal = sqlite3_column_int(statement, 0);
        }
        sqlite3_finalize(statement);
    }
    return retVal;
}

-(int)getStopCount {
    int retVal;
    NSString *query = @"Select SUM(isStop) from trials;";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil)
        == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            retVal = sqlite3_column_int(statement, 0);
        }
        sqlite3_finalize(statement);
    }
    return retVal;
}


-(float)getCorrectAverage {
    float retVal;
    NSString *query = @"Select AVG(correct) from trials;";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil)
        == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            retVal = sqlite3_column_double(statement, 0);
        }
        sqlite3_finalize(statement);
    }
    return retVal*100;
}

-(float)getAverageReactionTime
{
    float retVal;
    int CNT = 0;
    float sumDiff = 0;
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"HH:mm:ss.SSS"];
    
    
    NSString *query = @"SELECT appearanceTime, releaseTime from trials;";
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil)
        == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            NSString *relTimeString = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
            NSString *appearTimeString = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
            
            
            if (([appearTimeString length] > 7) && ([relTimeString length] > 7))
            {
                NSDate *relTime = [df dateFromString:relTimeString];
                NSDate *appearTime = [df dateFromString:appearTimeString];
                
                CNT = CNT + 1;
                
                float diff = [relTime timeIntervalSinceDate:appearTime];
                sumDiff = sumDiff + diff;
            }
        }
        sqlite3_finalize(statement);
    }
    
    retVal = (sumDiff/CNT);
    return retVal;
}

-(float)getAverageMovementTime
{
    float retVal;
    int CNT = 0;
    float sumDiff = 0;
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"HH:mm:ss.SSS"];
    
    
    NSString *query = @"SELECT releaseTime, touchTime from trials;";
    sqlite3_stmt *statement;

    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil)
        == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            NSString *relTimeString = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
            NSString *touchTimeString = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
            
            
            if ([touchTimeString length] > 7)
            {
                NSDate *relTime = [df dateFromString:relTimeString];
                NSDate *touchTime = [df dateFromString:touchTimeString];
                
                CNT = CNT + 1;
                
                float diff = [touchTime timeIntervalSinceDate:relTime];
                sumDiff = sumDiff + diff;
            }
        }
        sqlite3_finalize(statement);
    }

    retVal = (sumDiff/CNT);
    return retVal;
}

-(NSString *)getOtherData
{
    NSString *retVal = [[NSString alloc] init];
    
    retVal = [NSString stringWithFormat:@"<br /><br /><b>Correct Average:</b> %2.2f %% <br />", [self getCorrectAverage]];
    retVal = [retVal stringByAppendingString:[NSString stringWithFormat:@"<b>Average Time between Release and Touch:</b> %2.3f <br />", [self getAverageMovementTime]]];
    retVal = [retVal stringByAppendingString:[NSString stringWithFormat:@"<b>Average Time between Appearance and Release:</b> %2.3f<br />", [self getAverageReactionTime]]];
    retVal = [retVal stringByAppendingString:[NSString stringWithFormat:@"<b>Number of Trials:</b> %d <br />", [self getRecordsCount]]];
    retVal = [retVal stringByAppendingString:[NSString stringWithFormat:@"<b>Number of Stops:</b> %d <br />", [self getStopCount]]];
    
    return retVal;
}


///Correct AVerage
//Average time between appearance and release
//average time between release and touch
//num trials
//num stops
//subject name


-(NSString *)getRecords {
    NSString *retVal = [[NSString alloc] init];
    NSString *query = @"Select trialNumber, side, isStop, IFNULL(appearanceTime, ''), IFNULL(releaseTime, ''), IFNULL(touchTime, ''), IFNULL(stopTime, ''), correct, appearTimer, stopTimer from trials ";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil)
        == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            NSString *var = [NSString stringWithFormat:@"T: %d - Side: %d, isStop: %d, appearTime: %@, releaseTime: %@, touchTime: %@, stopTime: %@, correct: %d, appearTimer: %2.3f, stopTimer %2.3f", sqlite3_column_int(statement, 0), sqlite3_column_int(statement, 1), sqlite3_column_int(statement, 2), [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)], [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)], [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 5)], [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 6)], sqlite3_column_int(statement, 7),  sqlite3_column_double(statement, 8), sqlite3_column_double(statement, 9)];
            NSLog(@"%@", var);
            retVal = [NSString stringWithFormat:@"%@ \n %@", retVal, var];
        }
        sqlite3_finalize(statement);
    }
    return retVal;
}

-(void)clearDB {
    [self insertQuery:@"DELETE FROM trials"];
}

-(void)dealloc {
    sqlite3_close(_database);
}


/*
- (Trial *)exportNext {
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"HH:mm:ss.SSS"];
    
    Trial *retVal = [[Trial alloc] init];
    NSString *query = @"Select trialNumber, xDown, yDown, startPoint, endPoint, appearanceTime, releaseTime, IFNULL(touchTime, '0'), isStop from doubleStep ORDER BY appearanceTime ASC LIMIT 1;";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil)
        == SQLITE_OK) {
        if (sqlite3_step(statement) == SQLITE_ROW) {
            retVal.trialNumber = sqlite3_column_int(statement, 0);
            retVal.xDown = sqlite3_column_int(statement, 1);
            retVal.yDown = sqlite3_column_int(statement, 2);
            retVal.startPoint = sqlite3_column_int(statement, 3);
            retVal.endPoint = sqlite3_column_int(statement, 4);
            retVal.appearanceTime = [df dateFromString:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 5)]];
            retVal.releaseTime = [df dateFromString:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 6)]];
            NSString *touchTimeString =[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 7)];
            retVal.isStop = sqlite3_column_int(statement, 8);
            if (([touchTimeString isEqualToString:@"0"]) && (retVal.isStop == 1))
            {
                
            } else
            {
                retVal.touchTime = [df dateFromString:touchTimeString];
            }
            
            [self insertQuery:[NSString stringWithFormat:@"Delete from doubleStep where trialNumber = %d", retVal.trialNumber]];
        } else {
            retVal.trialNumber = -1;
        }
        sqlite3_finalize(statement);
    }
    return retVal;
}*/

/*-(NSString *)getRows
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"HH:mm:ss.SSS"];
    
    NSString *retVal = [[NSString alloc] init];
    NSString *query = @"Select * from exportTable";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            retVal = [retVal stringByAppendingFormat:@"<tr><td>%@</td><td>%@</td><td>%2.3f</td><td>%@</td><td>%2.3f</td><td>%d</td><td>%d</td><td>%d</td><td>%d</td><td>%d</td><td>%d</td><td>%d</td><td>%d</td><td>%d</td><td>%d</td><td>%d</td><td>%d</td></tr>",
                      [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)],//0                      appearanceTime TEXT
                      [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)],//1                      releaseTime TEXT
                      sqlite3_column_double(statement, 2),//2                     reactionTime real
                      [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)],//3                      touchTime TEXT
                      sqlite3_column_double(statement, 4),                            //4                      movementTime real
                      sqlite3_column_int(statement, 5),//5                      xDown INTEGER
                      sqlite3_column_int(statement, 6),//6                      yDown INTEGER
                      sqlite3_column_int(statement, 7),//7                      didJump INTEGER
                      sqlite3_column_int(statement, 8),//8                      initialPlacement INTEGER
                      sqlite3_column_int(statement, 9),//9                      finalPlacement INTEGER
                      sqlite3_column_int(statement, 10),//10                      dx INTEGER
                      sqlite3_column_int(statement, 11),//11                      dy1 INTEGER
                      sqlite3_column_int(statement, 12),//12                      dy2 INTEGER
                      sqlite3_column_int(statement, 13),//13                      absX INTEGER
                      sqlite3_column_int(statement, 14),//14                      absY1 INTEGER
                      sqlite3_column_int(statement, 15),//15                      absY2 INTEGER
                      sqlite3_column_int(statement, 16)//16                      isStop INTEGER
                      ];
        }
        sqlite3_finalize(statement);
    }
    return retVal;
}*/

-(NSString *)getRows
{
    [self insertQuery:@"DELETE from trials where appearanceTime IS NULL"];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"HH:mm:ss.SSS"];
    
    NSString *retVal = [[NSString alloc] initWithFormat:@"<center><table cellpadding=\"10\"><thead><tr><th>Side</th><th>Correct</th><th>Stop</th><th>Appearance</th><th>Release</th><th>Touch</th><th>Stop</th><th>Reaction Time</th><th>Movement Time</th><th>Stop To Touch</th></tr></thead><tbody>"];
    
    NSString *query = @"Select * from trials order by appearanceTime ASC";

    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {

            NSString *sideString = [[NSString alloc] init];
            if (sqlite3_column_int(statement, 1) == 1)
            {
                sideString = [NSString stringWithFormat:@"R"];
            } else
            {
                sideString = [NSString stringWithFormat:@"L"];
            }
            
            NSString *stopString = [[NSString alloc] init];
            if (sqlite3_column_int(statement, 2) == 1)
            {
                stopString = [NSString stringWithFormat:@"Y"];
            } else
            {
                stopString = [NSString stringWithFormat:@"N"];
            }
            
            
            NSString *correctString = [[NSString alloc] init];
            if (sqlite3_column_int(statement, 7) == 1)
            {
                correctString = [NSString stringWithFormat:@"Y"];
            } else
            {
                correctString = [NSString stringWithFormat:@"N"];
            }
            
            
            NSString *appearTimeString = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
            NSString *releaseTimeString = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)];

            
            NSString *touchTimeString = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 5)];
            NSString *stopTimeString = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 6)];
            
            if ([touchTimeString isEqualToString:@"(null)"])
            {
                touchTimeString = [NSString stringWithFormat:@""];
            }
            
            if ([stopTimeString isEqualToString:@"(null)"])
            {
                stopTimeString = [NSString stringWithFormat:@""];
            }
            
            NSDate *appearTime = [df dateFromString:appearTimeString];
            NSDate *releaseTime = [df dateFromString:releaseTimeString];

            //These two are conditional...
            NSDate *touchTime, *stopTime;
            
            float overshoot, movementTime;
            
            if ([touchTimeString length] > 1)
            {
              touchTime  = [df dateFromString:touchTimeString];
              movementTime = [touchTime timeIntervalSinceDate:releaseTime];
            } else
            {
                movementTime = 0.00;
            }
            
            if ([stopTimeString length] > 1)
            {
                stopTime = [df dateFromString:stopTimeString];
            }

            if (([stopTimeString length] > 1) && ([touchTimeString length] > 1))
            {
            overshoot = [touchTime timeIntervalSinceDate:stopTime];
            } else
            {
                overshoot = 0.00;
            }
            float reactionTime = [releaseTime timeIntervalSinceDate:appearTime];
     
            
            retVal = [retVal stringByAppendingFormat:@"<tr><td>%@</td><td>%@</td><td>%@</td><td>%@</td><td>%@</td><td>%@</td><td>%@</td><td>%2.3f</td><td>%2.3f</td><td>%2.3f</td></tr>",
                            sideString,
                            correctString,
                            stopString,
                            appearTimeString,
                            releaseTimeString,
                            touchTimeString,
                            stopTimeString,
                            reactionTime,
                            movementTime,
                            overshoot];
        }
        sqlite3_finalize(statement);
    }
    
    retVal = [retVal stringByAppendingFormat:@"</tbody></table></center><br /><br />"];
    return retVal;
}




@end
