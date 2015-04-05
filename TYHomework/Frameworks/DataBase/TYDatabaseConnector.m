//
//  RSDatabaseConnector.m
//  StoreKit
//
//  Created by closure on 3/21/15.
//  Copyright (c) 2015 closure. All rights reserved.
//

#import "TYDatabaseConnector.h"
#import <FMDB/FMDB.h>
#import "TYRowMapper.h"
//#import "RSStoreKit.h"
//#import "RSStorage.h"

@interface FMDatabaseQueue (X)
- (FMDatabase *)database;
@end

@interface TYDatabaseConnector () {
@private
    FMDatabaseQueue *_queue;
}
@end

@interface RyxDatabaseConnectorTableNameRowMapper : TYObject<TYRowMapper>
- (NSString *)rowMapperWithResultSet:(FMResultSet *)resultSet;
@end

@implementation RyxDatabaseConnectorTableNameRowMapper

- (NSString *)rowMapperWithResultSet:(FMResultSet *)resultSet {
    return [resultSet stringForColumnIndex:0];
}

@end

@implementation TYDatabaseConnector

+ (NSString *)pathForName:(NSString *)name {
    return name;
}

//- (instancetype)init {
//    if (self = [self initWithPath:[[[RSStoreKit kit] storageNamed:@"connector"] path] name:@"StoreKit.dat"]) {
//        
//    }
//    return self;
//}

- (instancetype)initWithName:(NSString *)name {
    if (self = [self initWithPath:name name:name]) {
        
    }
    return self;
}

- (instancetype)initWithPath:(NSString *)path name:(NSString *)name {
    if (self = [super init]) {
        NSError *error = nil;
        if (![[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error]) {
            NSLog(@"%@", [error localizedDescription]);
        }
        NSString *fullPath = [path stringByAppendingPathComponent:name];
        _queue = [[FMDatabaseQueue alloc] initWithPath:fullPath];
        [[_queue database] setTraceExecution:[[[NSBundle mainBundle] infoDictionary][@"RSStoreKitConnectorEnableDebug"] boolValue]];
        NSLog(@"%@", path);
    }
    return self;
}

//- (instancetype)initWithStorage:(TYStorage *)storage name:(NSString *)name {
//    return [self initWithPath:[storage path] name:name];
//}

- (void)dealloc {
    [_queue close];
}

- (void)executeStatements:(NSString *)sql {
    [_queue inDatabase:^(FMDatabase *db) {
        [db executeStatements:sql];
    }];
    return;
}

- (void)updateWithAction:(void (^)(BOOL success))action SQL:(NSString *)sql, ... {
    va_list ap;
    va_start(ap, sql);
    [self _updateWithAction:action SQL:sql va_list:ap];
    va_end(ap);
}

- (void)_updateWithAction:(void (^)(BOOL))action SQL:(NSString *)sql va_list:(va_list)ap {
    [_queue inDatabase:^(FMDatabase *db) {
        BOOL x = [db executeUpdate:sql withVAList:ap];
        if (action) {
            action(x);
        }
    }];
}

- (void)queryObjectWithActon:(void(^)(id obj))action rowMapper:(id<TYRowMapper>)rowMapper SQL:(NSString *)sql, ... {
    va_list ap;
    va_start(ap, sql);
    [self _queryObjectWithActon:action rowMapper:rowMapper SQL:sql va_list:ap];
    va_end(ap);
}

- (void)_queryObjectWithActon:(void(^)(id obj))action rowMapper:(id<TYRowMapper>)rowMapper SQL:(NSString *)sql va_list:(va_list)ap {
    [_queue inDatabase:^(FMDatabase *db) {
        FMResultSet *set = [db executeQuery:sql withVAList:ap];
        if (action) {
            id obj = nil;
            if ([set next]) {
                obj = [rowMapper rowMapperWithResultSet:set];
            }
            [set close];
            [set setParentDB:nil];
            action(obj);
        } else {
            [set close];
            [set setParentDB:nil];
        }
    }];
}


- (void)queryObjectsWithActon:(void(^)(NSArray *objs))action rowMapper:(id<TYRowMapper>)rowMapper SQL:(NSString *)sql, ... {
    va_list ap;
    va_start(ap, sql);
    [self _queryObjectWithActon:action rowMapper:rowMapper SQL:sql va_list:ap];
    va_end(ap);
}

- (void)_queryObjectsWithActon:(void(^)(NSArray *objs))action rowMapper:(id<TYRowMapper>)rowMapper SQL:(NSString *)sql va_list:(va_list)ap {
    [_queue inDatabase:^(FMDatabase *db) {
        FMResultSet *set = [db executeQuery:sql withVAList:ap];
        if (action) {
            NSMutableArray *objs = [[NSMutableArray alloc] init];
            while ([set next]) {
                [objs addObject:[rowMapper rowMapperWithResultSet:set]];
            }
            [set close];
            [set setParentDB:nil];
            action(objs);
        } else {
            [set close];
            [set setParentDB:nil];
        }
    }];
}

- (BOOL)updateWithSQL:(NSString *)sql, ... {
    BOOL x = NO;
    va_list ap;
    va_start(ap, sql);
    x = [self _updateWithSQL:sql va_list:ap];
    va_end(ap);
    return x;
}

- (BOOL)_updateWithSQL:(NSString *)sql va_list:(va_list)ap {
    __block BOOL x = NO;
    [_queue inDatabase:^(FMDatabase *db) {
        x = [db executeUpdate:sql withVAList:ap];
    }];
    return x;
}

- (id)queryObjectWithRowMapper:(id<TYRowMapper>)rowMapper SQL:(NSString *)sql, ... {
    va_list ap;
    va_start(ap, sql);
    id obj = nil;
    obj = [self _queryObjectWithRowMapper:rowMapper SQL:sql va_list:ap];
    va_end(ap);
    return obj;
}

- (id)_queryObjectWithRowMapper:(id<TYRowMapper>)rowMapper SQL:(NSString *)sql va_list:(va_list)ap {
    __block id obj = nil;
    [_queue inDatabase:^(FMDatabase *db) {
        FMResultSet *set = [db executeQuery:sql withVAList:ap];
        if ([set next]) {
            obj = [rowMapper rowMapperWithResultSet:set];
        }
        [set close];
        [set setParentDB:nil];
    }];
    return obj;
}


- (NSMutableArray *)queryObjectsWithRowMapper:(id<TYRowMapper>)rowMapper SQL:(NSString *)sql, ... {
    va_list ap;
    va_start(ap, sql);
    NSMutableArray *objs = nil;
    objs = [self _queryObjectsWithRowMapper:rowMapper SQL:sql va_list:ap];
    va_end(ap);
    return objs;
}

- (NSMutableArray *)_queryObjectsWithRowMapper:(id<TYRowMapper>)rowMapper SQL:(NSString *)sql va_list:(va_list)ap {
    __block NSMutableArray *objs = nil;
    [_queue inDatabase:^(FMDatabase *db) {
        FMResultSet *set = [db executeQuery:sql withVAList:ap];
        objs = [[NSMutableArray alloc] init];
        while ([set next]) {
            [objs addObject:[rowMapper rowMapperWithResultSet:set]];
        }
        [set close];
        [set setParentDB:nil];
    }];
    return objs;
}

- (NSMutableArray *)queryObjectsWithRowMapper:(id<TYRowMapper>)rowMapper SQL:(NSString *)sql ids:(NSArray *)keys {
    __block NSMutableArray *objs = nil;
    [_queue inDatabase:^(FMDatabase *db) {
        FMResultSet *set = [db executeQuery:sql withArgumentsInArray:keys];
        objs = [[NSMutableArray alloc] init];
        while ([set next]) {
            [objs addObject:[rowMapper rowMapperWithResultSet:set]];
        }
        [set close];
        [set setParentDB:nil];
    }];
    return objs;
}

- (long long)countOfTable:(NSString *)tableName {
    if ([tableName length] == 0) {
        return 0;
    }
    return [[_queue database] intForQuery:[NSString stringWithFormat:@"select count(*) from %@", tableName]];
}

- (BOOL)dropTable:(NSString *)table {
    return [[_queue database] executeStatements:[NSString stringWithFormat:@"drop table %@", table]];
}

- (NSMutableArray *)allTableNames {
    static NSString *SQL = @"SELECT tbl_name FROM sqlite_master where type = \"table\";";
    return [self queryObjectsWithRowMapper:[RyxDatabaseConnectorTableNameRowMapper new] SQL:SQL, nil];
}

- (BOOL)tableIsExist:(NSString *)tableName {
    return [[[self dbQueue] database] tableExists:tableName];
}

- (FMDatabaseQueue *)dbQueue {
    return _queue;
}

- (NSError *)lastError {
    return [[_queue database] lastError];
}
@end
