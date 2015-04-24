//
//  TYNoteDao.h
//  TYHomework
//
//  Created by taoYe on 15/4/22.
//  Copyright (c) 2015年 RenYuXian. All rights reserved.
//

#import "TYObject.h"

@class TYDatabaseConnector, TYNote;
@interface TYNoteDao : TYObject
- (instancetype)initWithConnector:(TYDatabaseConnector *)dataBaseConnector;

+ (instancetype)sharedDao;

- (void)selectNoteWithID:(NSInteger)ID action:(void(^)(TYNote *note))action;

- (void)selectNoteWithTitle:(NSString *)title action:(void(^)(TYNote *note))action;

- (void)selectNotesWithTitle:(NSString *)title action:(void (^)(NSArray *notes))action;

- (void)insertNoteWithID:(NSInteger)ID title:(NSString *)title desc:(NSString *)desc videoPagth:(NSString *)videoPath imageURL:(NSString *)imageURL drawImageURL:(NSString *)drawImageURL audioURL:(NSString *)audioURL action:(void (^)(TYNote *))action;

- (BOOL)deleteWithNoteTitle:(NSString *)title;

- (BOOL)deleteWithNoteID:(NSInteger)ID;

- (BOOL)updateNoteWithNoteTitle:(NSString *)title note:(TYNote *)note;
- (BOOL)updateNoteWithNoteID:(NSInteger)ID note:(TYNote *)note;

- (NSArray *)getAllNotes;

@end
