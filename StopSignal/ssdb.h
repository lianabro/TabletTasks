//
//  ssdb.h
//  StopSignal
//
//  Created by David Hallin on 2014-05-14.
//  Copyright (c) 2014 Ferocia Solutions Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "Trial.h"

@interface ssdb : NSObject
{
    sqlite3 *_database;
    NSString *databaseName, *databasePath;
}

@property (nonatomic, retain) NSString *databaseName, *databasePath;
-(void)clearDB;
+ (ssdb*)database;
- (Trial *)getNextRecord;
-(void)insertQuery:(NSString *)stringQuery;
-(int)getRecordsCount;
-(NSString *)getRecords;
-(void)loadTrials;
//-(void)buildExportTable;
//- (Trial *)exportNext;

-(NSString *)getRows;
-(NSString *)getOtherData;
@end
