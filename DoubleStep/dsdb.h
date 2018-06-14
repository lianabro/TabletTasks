//
//  dsdb.h
//  DoubleStep
//
//  Created by David Hallin on 2014-04-11.
//  Copyright (c) 2014 Ferocia Solutions Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "Trial.h"
@interface dsdb : NSObject
{
    sqlite3 *_database;
    NSString *databaseName, *databasePath;
}
@property (nonatomic, retain) NSString *databaseName, *databasePath;
-(void)clearDB;
+ (dsdb*)database;
- (Trial *)getNextRecord;
-(void)insertQuery:(NSString *)stringQuery;
-(int)getRecordsCount;
-(void)loadStops;
-(void)loadNoJumps;
-(NSString *)getRecords;

-(int)getJumpTimer;
-(void)setJumpTimer:(int)jumpTimer;
-(void)setJumpType:(NSString *)jumpType;
-(NSString *)getJumpType;

-(void)buildExportTable;
- (Trial *)exportNext;

-(NSString *)getRows;
-(NSString *)getAggData;
@end
