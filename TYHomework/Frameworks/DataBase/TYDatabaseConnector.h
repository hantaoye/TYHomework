//
//  RyxDatabaseConnector.h
//  FITogether
//
//  Created by closure on 1/21/15.
//  Copyright (c) 2015 closure. All rights reserved.
//

#import "TYObject.h"

@class FMDatabaseQueue;

@interface RyxDatabaseConnector : TYObject
+ (NSString *)pathForName:(NSString *)name;
- (instancetype)init;
- (instancetype)initWithName:(NSString *)name;
- (instancetype)initWithPath:(NSString *)path name:(NSString *)name;

- (void)executeStatements:(NSString *)sql;

- (void)updateWithAction:(void (^)(BOOL success))action SQL:(NSString *)sql,...;
- (void)queryObjectWithActon:(void(^)(id obj))action rowMapper:(id<RyxRowMapper>)rowMapper SQL:(NSString *)sql, ...;
- (void)queryObjectsWithActon:(void(^)(NSArray *objs))action rowMapper:(id<RyxRowMapper>)rowMapper SQL:(NSString *)sql, ...;
- (BOOL)updateWithSQL:(NSString *)sql,...;
- (id)queryObjectWithRowMapper:(id<RyxRowMapper>)rowMapper SQL:(NSString *)sql, ...;
- (NSMutableArray *)queryObjectsWithRowMapper:(id<RyxRowMapper>)rowMapper SQL:(NSString *)sql, ...;
- (NSMutableArray *)queryObjectsWithRowMapper:(id<RyxRowMapper>)rowMapper SQL:(NSString *)sql ids:(NSArray *)keys;

- (long long)countOfTable:(NSString *)tableName;
- (BOOL)dropTable:(NSString *)table;
- (NSMutableArray *)allTableNames;

- (FMDatabaseQueue *)dbQueue;

- (NSError *)lastError;
@end
