//
//  TYNoteDao.m
//  TYHomework
//
//  Created by taoYe on 15/4/22.
//  Copyright (c) 2015年 RenYuXian. All rights reserved.
//

#import "TYNoteDao.h"
#import "TYShareStorage.h"
#import "TYAccount.h"
#import "TYDatabaseConnector.h"
#import "TYNoteMapper.h"
#import "TYNote.h"


static NSString *RSAccountSQLAddAccount = @"replace into table_note (id, name, avatar) values (?, ?, ?);";

static NSString *RSAccountSQLRemoveAccount = @"delete from table_note where id = ?";
static NSString *RSNoteSQLUpdateNote = @"update table_note set title = ?, desc = ? note = ? where title = ?";

static NSString *RSNoteSQLUpdateNoteID = @"update table_note set title = ?, desc = ? note = ? where id = ?";

static NSString *RSAccountSQLUpdateAccountWithNickName = @"update table_note set name = ?, avatar = ?, nickName =? where id = ?";
static NSString *RSAccountSQLGetAccount = @"select id, name, avatar, nickName, timestamp from table_note where id = ?";
static NSString *RSAccountSQLMultiGetAccount = @"select id, name, avatar, nickName, timestamp from table_note where id in (%@)";


static NSString *RSNoteSQLCreateNote = @"create table if not exists table_note(id integer primary key autoincrement, access_token text, userID integer, title text, desc text, videoPath text, imageURL text, drawImageURL text, timestamp text, note blob)";

static NSString *RSNoteSQLAddNoteWithName = @"replace into table_note (title, desc, videoPath, imageURL, note) values (?, ?, ?, ?, ?);";

static NSString *RSNoteSQLCheckID = @"select note from table_note where id = ?";

static NSString *RSNoteSQLMultiGetNote = @"select id, note from table_note where id in (%@)";

static NSString *RSNoteSQLAllNote = @"select note from table_note order by id asc";
static NSString *RSNoteSQLCheckTitle = @"select id, note from table_note where title = ?";
static NSString *RSNoteSQLMultiGetNotesTitle = @"select id, note from table_note where title like %@ order by id asc";
static NSString *TYNoteSQLDeleteNoteTitle = @"delete from table_note where title = ?";
static NSString *TYNoteSQLDeleteNoteID = @"delete from table_note where id = ?";


@interface TYNoteDao ()

@property (strong, nonatomic) TYDatabaseConnector *connector;

@end

@implementation TYNoteDao

- (instancetype)initWithConnector:(TYDatabaseConnector *)dataBaseConnector {
    if (self = [super init]) {
        _connector = dataBaseConnector;
        [self createTable];
    }
    return self;
}

- (void)createTable {
    [self.connector executeStatements:RSNoteSQLCreateNote];
}

+ (instancetype)sharedDao {
    return [TYShareStorage shareStorage].noteDao;
}

- (void)selectNoteWithID:(NSInteger)ID action:(void(^)(TYNote *note))action {
    [self.connector queryObjectWithActon:^(TYNote *obj) {
        action(obj);
    } rowMapper:[[TYNoteMapper alloc] init] SQL:RSNoteSQLCheckID, ID];
}

- (void)selectNoteWithTitle:(NSString *)title action:(void(^)(TYNote *note))action {
    [self.connector queryObjectWithActon:^(id obj) {
        action(obj);
    } rowMapper:[[TYNoteMapper alloc] init] SQL:RSNoteSQLCheckTitle, title];
}

- (void)selectNotesWithTitle:(NSString *)title action:(void (^)(NSArray *))action {
    NSString *string = [NSString stringWithFormat:@"'%%%@%%'", title];
    NSString *str = [NSString stringWithFormat:RSNoteSQLMultiGetNotesTitle, string];
//    [self.connector queryObjectsWithActon:^(NSArray *objs) {
//        action(objs);
//            } rowMapper:[[TYNoteMapper alloc] init] SQL:str];
   NSArray *array = [self.connector queryObjectsWithRowMapper:[[TYNoteMapper alloc] init] SQL:str];
    action(array);
}

- (void)insertNoteWithID:(NSInteger)ID title:(NSString *)title desc:(NSString *)desc videoPagth:(NSString *)videoPath imageURL:(NSString *)imageURL drawImageURL:(NSString *)drawImageURL audioURL:(NSString *)audioURL action:(void (^)(TYNote *))action {
    TYNote *note = [[TYNote alloc] init];
    note.title = title;
    note.desc = desc;
    note.videopath = videoPath;
    note.imageURL = imageURL;
    note.drawImageURL = drawImageURL;
    note.audioURL = audioURL;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
    NSString *timestamp = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    note.timestamp = timestamp;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:note];
    if ([self.connector updateWithSQL:RSNoteSQLAddNoteWithName, title, desc, videoPath, imageURL, data]) {
        action(note);
    } else {
        action(nil);
    }
}

- (BOOL)updateNoteWithNoteTitle:(NSString *)title note:(TYNote *)note {
   return [self.connector updateWithSQL:RSNoteSQLUpdateNote, title, note.desc, note, title];
}

- (BOOL)updateNoteWithNoteID:(NSInteger)ID note:(TYNote *)note {
    return [self.connector updateWithSQL:RSNoteSQLUpdateNoteID, note.title, note.desc, note, ID];
}

- (NSArray *)getAllNotes {
   return [self.connector queryObjectsWithRowMapper:[[TYNoteMapper alloc] init] SQL:RSNoteSQLAllNote];
}

- (BOOL)deleteWithNoteTitle:(NSString *)title {
    return [self.connector updateWithSQL:TYNoteSQLDeleteNoteTitle, title];
}

- (BOOL)deleteWithNoteID:(NSInteger)ID {
    return [self.connector updateWithSQL:TYNoteSQLDeleteNoteID, ID];
}


@end
