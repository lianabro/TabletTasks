//
//  idb.m
//  Interception
//
//  Created by David Hallin on 2014-05-10.
//  Copyright (c) 2014 Ferocia Solutions Inc. All rights reserved.
//

#import "idb.h"

@implementation idb
static  idb *_database;

+(idb*)database {
    if (_database == nil)
    {
        _database = [[idb alloc] init];
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

- (trial *)getNextRecord {
    trial *retVal = [[trial alloc] init];
    NSString *query = @"Select * from trials where timeOfTouch IS NULL ORDER BY RANDOM() LIMIT 1;";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil)
        == SQLITE_OK) {
        if (sqlite3_step(statement) == SQLITE_ROW) {
            retVal.trialNumber = sqlite3_column_int(statement, 0);
            retVal.acc = sqlite3_column_int(statement, 1);
            retVal.vel = sqlite3_column_int(statement, 2);
        } else
        {
            retVal.trialNumber = -1;
        }
        sqlite3_finalize(statement);
    }
    return retVal;
}

-(float)AverageSuccessRate {
    float retVal = 0;
    NSString *query = @"Select AVG(successful) from exportTable";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil)
        == SQLITE_OK) {
        if (sqlite3_step(statement) == SQLITE_ROW) {
            retVal = sqlite3_column_double(statement, 0);
        }
        sqlite3_finalize(statement);
    }
    return retVal;
}


-(float)AverageTrialTime {
    float retVal = 0;
    NSString *query = @"Select AVG(trialTime) from exportTable";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil)
        == SQLITE_OK) {
        if (sqlite3_step(statement) == SQLITE_ROW) {
            retVal = sqlite3_column_double(statement, 0);
        }
        sqlite3_finalize(statement);
    }
    return retVal;
}

-(int)numTrials {
    int retVal = 0;
    NSString *query = @"Select COUNT(*) from exportTable";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil)
        == SQLITE_OK) {
        if (sqlite3_step(statement) == SQLITE_ROW) {
            retVal = sqlite3_column_int(statement, 0);
        }
        sqlite3_finalize(statement);
    }
    return retVal;
}

-(float)AverageDeltaTime {
    float retVal = 0;
    NSString *query = @"Select AVG(deltaTouchTime) from exportTable";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil)
        == SQLITE_OK) {
        if (sqlite3_step(statement) == SQLITE_ROW) {
            retVal = sqlite3_column_double(statement, 0);
        }
        sqlite3_finalize(statement);
    }
    return retVal;
}

-(float)AverageABSDeltaTime {
    float retVal = 0;
    NSString *query = @"Select AVG(ABS(deltaTouchTime)) from exportTable";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil)
        == SQLITE_OK) {
        if (sqlite3_step(statement) == SQLITE_ROW) {
            retVal = sqlite3_column_double(statement, 0);
        }
        sqlite3_finalize(statement);
    }
    return retVal;
}

-(float)AverageDeltaPos {
    float retVal = 0;
    NSString *query = @"Select AVG(deltaTouchPosition) from exportTable";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil)
        == SQLITE_OK) {
        if (sqlite3_step(statement) == SQLITE_ROW) {
            retVal = sqlite3_column_double(statement, 0);
        }
        sqlite3_finalize(statement);
    }
    return retVal;
}


-(float)STDevDeltaTouchPos {
    float retVal = 0;
    float meanVal = [self AverageDeltaPos];
    //dont forget to square root this dave....
    NSString *query = [NSString stringWithFormat:@"SELECT SUM(val)/(SELECT COUNT(*) from exportTable) from (select (deltaTouchPosition - %2.0f)*(deltaTouchPosition - %2.0f) as val from exportTable);", meanVal, meanVal];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil)
        == SQLITE_OK) {
        if (sqlite3_step(statement) == SQLITE_ROW) {
            retVal = sqrt(sqlite3_column_double(statement, 0));
        }
        sqlite3_finalize(statement);
    }
    return retVal;
}

-(float)STDevDeltaTouchTime {
    float retVal = 0;
    float meanVal = [self AverageDeltaTime];
    //dont forget to square root this dave....
    NSString *query = [NSString stringWithFormat:@"SELECT SUM(val)/(SELECT COUNT(*) from exportTable) from (select (deltaTouchTime - %2.0f)*(deltaTouchTime - %2.0f) as val from exportTable);", meanVal, meanVal];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil)
        == SQLITE_OK) {
        if (sqlite3_step(statement) == SQLITE_ROW) {
            retVal = sqrt(sqlite3_column_double(statement, 0));
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

-(void)loadFive:(int)vel andAccel:(int)acc {
    for (int f = 0; f<5;f++)
    {
        NSString *insertString = [[NSString alloc] initWithFormat:@"INSERT INTO trials (acc, vel) VALUES (%d, %d)", acc, vel];
        [self insertQuery:insertString];
    }
}

-(void)loadTen:(int)vel andAccel:(int)acc {
    for (int f = 0; f<10;f++)
    {
        NSString *insertString = [[NSString alloc] initWithFormat:@"INSERT INTO trials (acc, vel) VALUES (%d, %d)", acc, vel];
        [self insertQuery:insertString];
    }
}

-(NSString *)getRecords {
    NSString *retVal = [[NSString alloc] init];
    NSString *query = @"Select trialNumber, acc, vel, IFNULL(timeOfStart, ''), IFNULL(timeOfTouch, ''), hit from trials";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil)
        == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            NSString *var = [NSString stringWithFormat:@"T: %d   Acceleration: %d Initial Velocity: %d, startTime: %@, touchTime: %@, hit:%d", sqlite3_column_int(statement, 0), sqlite3_column_int(statement, 1), sqlite3_column_int(statement, 2), [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)], [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)], sqlite3_column_int(statement, 5)];
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

-(NSDate *)getIdealTouchTimeWithVel:(int)vel andAcc:(int)acc andstartTime:(NSDate *)startTime
{
    // (Vf)^2 = (Vo)^2 + 2ad
    // d = 784
    //v0 is a variable we know,
    //a is a variable we know
    float idealt;
    if (acc > 0)
    {
        float vf = sqrtf((vel*vel)+(784*2*acc));
        idealt = (vf - vel)/acc;
    } else
    {
        idealt = 784/(float)vel;
    }
    return [startTime dateByAddingTimeInterval:idealt];
}

-(float)getPositionAtTouchWithTrial:(trial *)t1
{
    float t = [t1.timeOfTouch timeIntervalSinceDate:t1.timeOfStart];
    float d;
    d = (t1.vel*t) + ((0.5*t1.acc)*t*t);
    return d;
}

-(void)buildExportTable
{
    
    [self insertQuery:@"delete from exportTable"];
    [self insertQuery:@"delete from trials where timeOfTouch is NULL"];
    trial *t = [[trial alloc] init];

    
    t = [self exportNext];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"HH:mm:ss.SSS"];
    
    while (t.trialNumber > 0) {
        NSTimeInterval trialTime = [t.timeOfTouch timeIntervalSinceDate:t.timeOfStart];
        NSDate *idealTime = [self getIdealTouchTimeWithVel:t.vel andAcc:t.acc andstartTime:t.timeOfStart];
        float posAtT = [self getPositionAtTouchWithTrial:t];
        NSTimeInterval deltaTouchTime = [t.timeOfTouch timeIntervalSinceDate:idealTime];
        //Delta Touch Time
        int dPos = posAtT - 784; // Delta Position
        
        
        
        
        [self insertQuery:[NSString stringWithFormat:@"INSERT INTO exportTable (successful, vel, acc, startTime, touchTime, trialTime, idealTouchTime, positionAtTouch, idealTouchPosition, deltaTouchTime, deltaTouchPosition) VALUES (%d, %d, %d, '%@', '%@', %2.3f, '%@', %2.0f, 784, %2.3f, %d)",
                           t.hit,
                           t.vel,
                           t.acc,
                           [df stringFromDate:t.timeOfStart],
                           [df stringFromDate:t.timeOfTouch],
                           trialTime,
                           [df stringFromDate:idealTime],
                           posAtT,
                           deltaTouchTime,
                           dPos]];
                           
                           
                           /*
                           [df stringFromDate:t.appearanceTime],//AppearanceTime,
                           [df stringFromDate:t.releaseTime],//releaseTime
                           reactionTime,//reactionTime
                           [df stringFromDate:t.touchTime],//touchTime
                           movementTime,//movementTime
                           t.xDown,//xDown
                           t.yDown,//yDown
                           didJump,//didJump
                           t.startPoint, //Initial Placement
                           t.endPoint,// finalPlacement
                           dx,// dx
                           dy1,// dy1
                           dy2,// dy2
                           absX,
                           absY1,
                           absY2, t.isStop]];*/
        
        t = [self exportNext];
    }
}

- (trial *)exportNext {
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"HH:mm:ss.SSS"];
    
    trial *retVal = [[trial alloc] init];
    NSString *query = @"Select trialNumber, acc, vel, IFNULL(timeOfStart,'0'), IFNULL(timeOfTouch,'0'), hit FROM trials ORDER BY timeOfStart ASC LIMIT 1;";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil)
        == SQLITE_OK) {
        if (sqlite3_step(statement) == SQLITE_ROW) {
            retVal.trialNumber = sqlite3_column_int(statement, 0);
            retVal.acc = sqlite3_column_int(statement, 1);
            retVal.vel = sqlite3_column_int(statement, 2);
            retVal.hit = sqlite3_column_int(statement, 5);
            retVal.timeOfStart =    [df dateFromString:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)]];
            retVal.timeOfTouch =    [df dateFromString:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)]];
            
            [self insertQuery:[NSString stringWithFormat:@"Delete from trials where trialNumber = %d", retVal.trialNumber]];
        } else {
            retVal.trialNumber = -1;
        }
        sqlite3_finalize(statement);
    }
    return retVal;
}




-(NSString *)getRows
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"HH:mm:ss.SSS"];
    
    NSString *retVal = [[NSString alloc] init];
    
    retVal = [NSString stringWithFormat:@"<table style=\"cell-padding:10px; cell-spacing:10px; border:1px solid black;\"><thead><tr><th>Successful</th><th>Initial Velocity</th><th>Acceleration</th><th>Trial Start</th><th>Touch Time</th><th>Trial Time</th><th>Ideal Touch Time</th><th>Touch Position</th><th>Ideal Touch Position</th><th>Delta Touch Time</th><th>Delta Touch Position</th></tr></thead><tbody>"];
    
    NSString *query = @"Select * from exportTable";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            retVal = [retVal stringByAppendingFormat:@"<tr><td>%d</td><td>%d</td><td>%d</td><td>%@</td><td>%@</td><td>%2.3f</td><td>%@</td><td>%d</td><td>%d</td><td>%2.3f</td><td>%d</td></tr>",
                      sqlite3_column_int(statement, 0), //Successful
                      sqlite3_column_int(statement, 1), //Initial Velocity
                      sqlite3_column_int(statement, 2), //Acceleration
                      [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)], //Trial Start Time
                      [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)], //Trial Touch Time
                      sqlite3_column_double(statement, 5), //Trial Time
                      [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 6)], //Ideal Touch Time
                      sqlite3_column_int(statement, 7), //Position At Touch
                      sqlite3_column_int(statement, 8), //Ideal Touch Position
                      sqlite3_column_double(statement, 9), //Delta Touch Time
                      sqlite3_column_int(statement, 10) //Delta Touch Position

                      
                      
                      
                      
                      /*[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)],//0                      appearanceTime TEXT
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
                      sqlite3_column_int(statement, 16)//16                      isStop INTEGER*/
                      ];
        }
        sqlite3_finalize(statement);
    }
    
    retVal = [retVal stringByAppendingString:@"</tbody></table>"];
    retVal = [retVal stringByAppendingString:@"<br /><br /><br /><b>Statistics</b><br />"];
    
    retVal = [retVal stringByAppendingString:[NSString stringWithFormat:@"Correct Average: %2.2f <br />", (100*[self AverageSuccessRate])]];
    retVal = [retVal stringByAppendingString:[NSString stringWithFormat:@"Average Trial Length: %2.3f <br />", [self AverageTrialTime]]];
    retVal = [retVal stringByAppendingString:[NSString stringWithFormat:@"Number of Trials: %d <br />", [self numTrials]]];
    retVal = [retVal stringByAppendingString:[NSString stringWithFormat:@"Average Delta Time: %2.3f <br />", [self AverageDeltaTime]]];
    retVal = [retVal stringByAppendingString:[NSString stringWithFormat:@"Average Delta Position: %2.0f <br />", [self AverageDeltaPos]]];
    retVal = [retVal stringByAppendingString:[NSString stringWithFormat:@"Average Absolute Delta Time: %2.3f <br />", [self AverageABSDeltaTime]]];

    //Standard Deviations
    retVal = [retVal stringByAppendingString:[NSString stringWithFormat:@"Standard Deviation - Delta Time: %2.3f <br />", [self STDevDeltaTouchTime]]];
    retVal = [retVal stringByAppendingString:[NSString stringWithFormat:@"Standard Deviation - Delta Position: %2.3f <br />", [self STDevDeltaTouchTime]]];
    
    
    return retVal;
}

-(float)getMean:(int)jumpVar forCol:(NSString *)col
{
    float retVal;
    NSString *query = [NSString stringWithFormat:@"Select AVG(%@) from exportTable where didJump = %d", col, jumpVar];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        if (sqlite3_step(statement) == SQLITE_ROW) {
            retVal = sqlite3_column_double(statement, 0);
        }
        sqlite3_finalize(statement);
    }
    return retVal;
}

-(float)getStdDev:(NSString *)col withJumps:(int)jumpVar
{
    float retVal;
    float mean = [self getMean:jumpVar forCol:col];
    NSString *query = [NSString stringWithFormat:@"Select SUM(a.sq)/(SELECT count(*) from exportTable where didJump = %d) from (select (%@ - %f)*(%@ - %f) as sq from exportTable where didJump = %d) a", jumpVar, col, mean, col, mean, jumpVar];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        if (sqlite3_step(statement) == SQLITE_ROW) {
            retVal = sqrt(sqlite3_column_double(statement, 0));
        }
        sqlite3_finalize(statement);
    }
    return retVal;
}

-(float)rootNForSEM:(int)jumpVar
{
    float retVal;
    NSString *query = [NSString stringWithFormat:@"Select COUNT(*) from exportTable where didJump = %d", jumpVar];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        if (sqlite3_step(statement) == SQLITE_ROW) {
            retVal = sqrt(sqlite3_column_double(statement, 0));
        }
        sqlite3_finalize(statement);
    }
    return retVal;
}

-(float)getSEM:(NSString *)col withJumps:(int)jumpVar
{
    float SD = [self getStdDev:col withJumps:jumpVar];
    float rootN = [self rootNForSEM:jumpVar];
    
    return (SD/rootN);
}
-(NSString *)getAggData
{
    NSString *retVal = [[NSString alloc] init];
    retVal = [NSString stringWithFormat:@"<table style=\"width:100%%;\"><tr><th></th><th>Type</th><th>Mean</th><th>SD</th><th>SEM</th></tr>"];
    
    //Reaction Time
    retVal = [retVal stringByAppendingFormat:@"<tr><td>ReactionTime</td><td>No Jump</td><td>%f</td><td>%f</td><td>%f</td></tr>", [self getMean:0 forCol:@"reactionTime"], [self getStdDev:@"reactionTime" withJumps:0], [self getSEM:@"reactionTime" withJumps:0]];
    
    retVal = [retVal stringByAppendingFormat:@"<tr><td></td><td>Jumps</td><td>%f</td><td>%f</td><td>%f</td></tr>", [self getMean:1 forCol:@"reactionTime"], [self getStdDev:@"reactionTime" withJumps:1], [self getSEM:@"reactionTime" withJumps:1]];
    
    //Movement Time
    retVal = [retVal stringByAppendingFormat:@"<tr><td>Movement Time</td><td>No Jump</td><td>%f</td><td>%f</td><td>%f</td></tr>", [self getMean:0 forCol:@"movementTime"], [self getStdDev:@"movementTime" withJumps:0], [self getSEM:@"movementTime" withJumps:0]];
    
    retVal = [retVal stringByAppendingFormat:@"<tr><td></td><td>Jumps</td><td>%f</td><td>%f</td><td>%f</td></tr>", [self getMean:1 forCol:@"movementTime"], [self getStdDev:@"movementTime" withJumps:1], [self getSEM:@"movementTime" withJumps:1]];
    
    //absX
    retVal = [retVal stringByAppendingFormat:@"<tr><td>Movement Time</td><td>No Jump</td><td>%f</td><td>%f</td><td>%f</td></tr>", [self getMean:0 forCol:@"absX"], [self getStdDev:@"absX" withJumps:0], [self getSEM:@"absX" withJumps:0]];
    
    retVal = [retVal stringByAppendingFormat:@"<tr><td></td><td>Jumps</td><td>%f</td><td>%f</td><td>%f</td></tr>", [self getMean:1 forCol:@"absX"], [self getStdDev:@"absX" withJumps:1], [self getSEM:@"absX" withJumps:1]];
    
    
    //absY1
    retVal = [retVal stringByAppendingFormat:@"<tr><td>Movement Time</td><td>No Jump</td><td>%f</td><td>%f</td><td>%f</td></tr>", [self getMean:0 forCol:@"absY1"], [self getStdDev:@"absY1" withJumps:0], [self getSEM:@"absY1" withJumps:0]];
    
    retVal = [retVal stringByAppendingFormat:@"<tr><td></td><td>Jumps</td><td>%f</td><td>%f</td><td>%f</td></tr>", [self getMean:1 forCol:@"absY1"], [self getStdDev:@"absY1" withJumps:1], [self getSEM:@"absY1" withJumps:1]];
    
    
    //absY2
    retVal = [retVal stringByAppendingFormat:@"<tr><td>Movement Time</td><td>No Jump</td><td>%f</td><td>%f</td><td>%f</td></tr>", [self getMean:0 forCol:@"absY2"], [self getStdDev:@"absY2" withJumps:0], [self getSEM:@"absY2" withJumps:0]];
    
    retVal = [retVal stringByAppendingFormat:@"<tr><td></td><td>Jumps</td><td>%f</td><td>%f</td><td>%f</td></tr>", [self getMean:1 forCol:@"absY2"], [self getStdDev:@"absY2" withJumps:1], [self getSEM:@"absY2" withJumps:1]];
    
    
    retVal = [retVal stringByAppendingString:@"</table>"];
    
    return retVal;
}


@end
