//
//  idb.h
//  Interception
//
//  Created by David Hallin on 2014-05-10.
//  Copyright (c) 2014 Ferocia Solutions Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "trial.h"

@interface idb : NSObject
{
    sqlite3 *_database;
    NSString *databaseName, *databasePath;
}


@property (nonatomic, retain) NSString *databaseName, *databasePath;
-(void)clearDB;
+ (idb*)database;
- (trial *)getNextRecord;
-(void)insertQuery:(NSString *)stringQuery;
-(int)getRecordsCount;
-(void)loadFive:(int)vel andAccel:(int)acc;
-(void)loadTen:(int)vel andAccel:(int)acc;
-(NSString *)getRecords;

-(void)buildExportTable;
- (trial *)exportNext;

-(NSString *)getRows;
-(NSString *)getAggData;

@end
