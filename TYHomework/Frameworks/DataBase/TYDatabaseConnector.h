//
//  RyxDatabaseConnector.h
//  FITogether
//
//  Created by closure on 1/21/15.
//  Copyright (c) 2015 closure. All rights reserved.
//

#import "TYObject.h"
#import "TYRowMapper.h"

@class FMDatabaseQueue;

@interface TYDatabaseConnector : TYObject
+ (NSString *)pathForName:(NSString *)name;
- (instancetype)init;
- (instancetype)initWithName:(NSString *)name;
- (instancetype)initWithPath:(NSString *)path name:(NSString *)name;

- (void)executeStatements:(NSString *)sql;

- (void)updateWithAction:(void (^)(BOOL success))action SQL:(NSString *)sql,...;
- (void)queryObjectWithActon:(void(^)(id obj))action rowMapper:(id<TYRowMapper>)rowMapper SQL:(NSString *)sql, ...;
- (void)queryObjectsWithActon:(void(^)(NSArray *objs))action rowMapper:(id<TYRowMapper>)rowMapper SQL:(NSString *)sql, ...;
- (BOOL)updateWithSQL:(NSString *)sql,...;
- (id)queryObjectWithRowMapper:(id<TYRowMapper>)rowMapper SQL:(NSString *)sql, ...;
- (NSMutableArray *)queryObjectsWithRowMapper:(id<TYRowMapper>)rowMapper SQL:(NSString *)sql, ...;
- (NSMutableArray *)queryObjectsWithRowMapper:(id<TYRowMapper>)rowMapper SQL:(NSString *)sql ids:(NSArray *)keys;

- (long long)countOfTable:(NSString *)tableName;
- (BOOL)dropTable:(NSString *)table;
- (NSMutableArray *)allTableNames;

- (FMDatabaseQueue *)dbQueue;

- (NSError *)lastError;
@end
