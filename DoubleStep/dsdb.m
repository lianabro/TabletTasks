//
//  dsdb.m
//  DoubleStep
//
//  Created by David Hallin on 2014-04-11.
//  Copyright (c) 2014 Ferocia Solutions Inc. All rights reserved.
//

#import "dsdb.h"
#import "Trial.h"

@implementation dsdb
@synthesize databaseName, databasePath;
static  dsdb *_database;

+(dsdb*)database {
    if (_database == nil)
    {
        _database = [[dsdb alloc] init];
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
    NSString *query = @"Select * from doubleStep where appearanceTime IS NULL ORDER BY RANDOM() LIMIT 1;";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil)
        == SQLITE_OK) {
        if (sqlite3_step(statement) == SQLITE_ROW) {
               retVal.trialNumber = sqlite3_column_int(statement, 0);
               retVal.startPoint = sqlite3_column_int(statement, 3);
               retVal.endPoint = sqlite3_column_int(statement, 4);
               retVal.isStop = sqlite3_column_int(statement, 8);
            
        } else
        {
            retVal.trialNumber = -1;
        }
        sqlite3_finalize(statement);
    }
    return retVal;
}

-(NSString *)getJumpType {
    NSString *retVal = [[NSString alloc] init];
    NSString *query = @"Select settingValue from doubleStepSettings where settingName LIKE 'jumpType';";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil)
        == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            retVal = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,0)];
        }
        sqlite3_finalize(statement);
    }
    return retVal;
}

-(void)setJumpType:(NSString *)jumpType
{
    [self insertQuery:[NSString stringWithFormat:@"UPDATE doubleStepSettings set settingValue = '%@' where settingName LIKE 'jumpType'", jumpType]];
}

-(void)setJumpTimer:(int)jumpTimer
{
    [self insertQuery:[NSString stringWithFormat:@"UPDATE doubleStepSettings set settingValue = '%d' where settingName LIKE 'jumpTimer'", jumpTimer]];
}

-(int)getJumpTimer {
    int retVal;
    NSString *query = @"Select settingValue from doubleStepSettings where settingName LIKE 'jumpTimer';";
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

-(void)loadStops {
    for (int f = 0; f<2;f++)
    {
        NSString *insertString = [[NSString alloc] initWithFormat:@"INSERT INTO doubleStep (startPoint, endPoint, isStop) VALUES (2, 1, %d)", f];
        [self insertQuery:insertString];
    }
    
    for (int f = 0; f<2;f++)
    {
        NSString *insertString = [[NSString alloc] initWithFormat:@"INSERT INTO doubleStep (startPoint, endPoint, isStop) VALUES (2, 3, %d)", f];
        [self insertQuery:insertString];
    }
    
    for (int f = 0; f<2;f++)
    {
        NSString *insertString = [[NSString alloc] initWithFormat:@"INSERT INTO doubleStep (startPoint, endPoint, isStop) VALUES (3, 2, %d)", f];
        [self insertQuery:insertString];
    }
    
    for (int f = 0; f<2;f++)
    {
        NSString *insertString = [[NSString alloc] initWithFormat:@"INSERT INTO doubleStep (startPoint, endPoint, isStop) VALUES (3, 4, %d)", f];
        [self insertQuery:insertString];
    }
    
    for (int f = 0; f<2;f++)
    {
        NSString *insertString = [[NSString alloc] initWithFormat:@"INSERT INTO doubleStep (startPoint, endPoint, isStop) VALUES (4, 5, %d)", f];
        [self insertQuery:insertString];
    }
    
    for (int f = 0; f<2;f++)
    {
        NSString *insertString = [[NSString alloc] initWithFormat:@"INSERT INTO doubleStep (startPoint, endPoint, isStop) VALUES (4, 3, %d)", f];
        [self insertQuery:insertString];
    }
}

-(void)loadNoJumps {
    for (int i = 0; i < 4; i++)
    {
        for (int f = 2; f <5; f++)
        {
            NSString *insertString = [[NSString alloc] initWithFormat:@"INSERT INTO doubleStep (startPoint, endPoint, isStop) VALUES (%d, %d, 0)", f, f];
            [self insertQuery:insertString];
        }
    }
}

-(int)getRecordsCount {
    int retVal;
    NSString *query = @"Select COUNT(*) from doubleStep;";
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

-(NSString *)getRecords {
    NSString *retVal = [[NSString alloc] init];
    NSString *query = @"Select trialNumber, IFNULL(xDown, 0), IFNULL(yDown, 0), IFNULL(startPoint, 0), IFNULL(endPoint, 0), IFNULL(appearanceTime, ''), IFNULL(releaseTime, ''), IFNULL(touchTime, ''), IFNULL(isStop, 0), IFNULL(wasCorrect, 0) from doubleStep;";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil)
        == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            NSString *var = [NSString stringWithFormat:@"T: %d - xDown: %d, yDown: %d, startPoint: %d, endPoint: %d, appearTime: %@, releaseTime: %@, touchTime: %@, isStop: %d, wasCorrect: %d", sqlite3_column_int(statement, 0), sqlite3_column_int(statement, 1), sqlite3_column_int(statement, 2), sqlite3_column_int(statement, 3), sqlite3_column_int(statement, 4),  [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 5)], [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 6)], [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 7)], sqlite3_column_int(statement, 8),  sqlite3_column_int(statement, 9)];
            NSLog(@"%@", var);
            retVal = [NSString stringWithFormat:@"%@ \n %@", retVal, var];
        }
        sqlite3_finalize(statement);
    }
    return retVal;
}

-(void)clearDB {
    [self insertQuery:@"DELETE FROM doubleStep"];
}

-(void)dealloc {
    sqlite3_close(_database);
}

-(int)getYForPos:(int)var
{
    int retVal;
    switch (var) {
        case 5:
            retVal =  528;
            break;
        case 4:
            retVal =  640;
            break;
        case 3:
            retVal =  752;
            break;
        case 2:
            retVal =  864;
            break;
        case 1:
            retVal =  976;
            break;
        default:
            break;
    }
    return retVal;
}

-(void)buildExportTable
{
    [self insertQuery:@"delete from exportTable"];
    [self insertQuery:@"delete from doubleStep where appearanceTime is NULL"];
    Trial *t = [[Trial alloc] init];
    t = [self exportNext];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"HH:mm:ss.SSS"];
    
    while (t.trialNumber > 0) {
        NSTimeInterval reactionTime = [t.releaseTime timeIntervalSinceDate:t.appearanceTime];
        NSTimeInterval movementTime = [t.touchTime timeIntervalSinceDate:t.releaseTime];
        
        int didJump = 0;
        if (t.startPoint != t.endPoint)
        {
            didJump = 1;
        }
        
        int dx = t.xDown - 384;
        
        int y1Pos = [self getYForPos:t.startPoint];
        int y2Pos = [self getYForPos:t.endPoint];
        
        int dy1 = t.yDown - y1Pos;
        int dy2 = t.yDown - y2Pos;
        
        int absX = dx;
        if (absX < 0)
        {
            absX = 0 - absX;
        }
        
        int absY1 = dy1;
        if (absY1 < 0)
        {
            absY1 = 0 - absY1;
        }

        int absY2 = dy2;
        if (absY2 < 0)
        {
            absY2 = 0 - absY2;
        }
        
        [self insertQuery:[NSString stringWithFormat:@"INSERT INTO exportTable (appearanceTime, releaseTime, reactionTime, touchTime, movementTime, xDown, yDown, didJump, initialPlacement, finalPlacement, dx, dy1, dy2, absX, absY1, absY2, isStop) VALUES ('%@', '%@', %2.3f, '%@', %2.3f, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d)",
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
                absY2, t.isStop]];
    
        t = [self exportNext];
    }
}
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
}

-(NSString *)getRows
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
