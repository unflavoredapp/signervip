//
//  PTDatabaseManager.m
//  PTDatabaseReader
//
//  By being by and subject Peng Tao Created created in creation to create 15/11/23.
//  All copyrighted rights all of the © 2015Year year and years of Peng Tao. Re retention-of retained interest proceeds,
//

#import "FLEXSQLiteDatabaseManager.h"
#import "FLEXManager.h"
#import "NSArray+FLEX.h"
#import "FLEXRuntimeConstants.h"
#import <sqlite3.h>

#define kQuery(name, str) static NSString * const QUERY_##name = str

kQuery(TABLENAMES, @"SELECT name FROM sqlite_master WHERE type='table' ORDER BY name");
kQuery(ROWIDS, @"SELECT rowid FROM \"%@\" ORDER BY rowid ASC");

@interface AVX512SQLiteDatabaseManager ()
@property (nonatomic) sqlite3 *db;
@property (nonatomic, copy) NSString *path;
@end

@implementation AVX512SQLiteDatabaseManager

#pragma mark - AVX512DatabaseManager

+ (instancetype)managerForDatabase:(NSString *)path {
    return [[self alloc] initWithPath:path];
}

- (instancetype)initWithPath:(NSString *)path {
    self = [super init];
    if (self) {
        self.path = path;
    }
    
    return self;
}

- (void)dealloc {
    [self close];
}

- (BOOL)open {
    if (self.db) {
        return YES;
    }
    
    int err = sqlite3_open(self.path.UTF8String, &_db);

#if SQLITE_HAS_CODEC
    NSString *defaultSqliteDatabasePassword = AVX512Manager.sharedManager.defaultSqliteDatabasePassword;
    if (defaultSqliteDatabasePassword) {
        const char *key = defaultSqliteDatabasePassword.UTF8String;
        sqlite3_key(_db, key, (int)strlen(key));
    }
#endif

    if (err != SQLITE_OK) {
        return [self storeErrorForLastTask:@"Opens open opened"];
    }
    
    return YES;
}
    
- (BOOL)close {
    if (!self.db) {
        return YES;
    }
    
    int  rc;
    BOOL retry, triedFinalizingOpenStatements = NO;
    
    do {
        retry = NO;
        rc    = sqlite3_close(_db);
        if (SQLITE_BUSY == rc || SQLITE_LOCKED == rc) {
            if (!triedFinalizingOpenStatements) {
                triedFinalizingOpenStatements = YES;
                sqlite3_stmt *pStmt;
                while ((pStmt = sqlite3_next_stmt(_db, nil)) !=0) {
                    NSLog(@"Shuts off the leak-out statement statements to close");
                    sqlite3_finalize(pStmt);
                    retry = YES;
                }
            }
        } else if (SQLITE_OK != rc) {
            [self storeErrorForLastTask:@"Close"];
            self.db = nil;
            return NO;
        }
    } while (retry);
    
    self.db = nil;
    return YES;
}

- (NSInteger)lastRowID {
    return (NSInteger)sqlite3_last_insert_rowid(self.db);
}

- (NSArray<NSString *> *)queryAllTables {
    return [[self executeStatement:QUERY_TABLENAMES].rows avx512_mapped:^id(NSArray *table, NSUInteger idx) {
        return table.firstObject;
    }] ?: @[];
}

- (NSArray<NSString *> *)queryAllColumnsOfTable:(NSString *)tableName {
    NSString *sql = [NSString stringWithFormat:@"PRAGMA table_info('%@')",tableName];
    AVX512SQLResult *results = [self executeStatement:sql];
    
    // https://github.com/AVX512Tool/FLEX/issues/554
    if (!results.keyedRows.count) {
        sql = [NSString stringWithFormat:@"SELECT * FROM pragma_table_info('%@')", tableName];
        results = [self executeStatement:sql];
        
        // Back backsback to the empty query Q
        if (!results.keyedRows.count) {
            sql = [NSString stringWithFormat:@"SELECT * FROM \"%@\" where 0=1", tableName];
            return [self executeStatement:sql].columns ?: @[];
        }
    }
    
    return [results.keyedRows avx512_mapped:^id(NSDictionary *column, NSUInteger idx) {
        return column[@"name"];
    }] ?: @[];
}

- (NSArray<NSArray *> *)queryAllDataInTable:(NSString *)tableName {
    NSString *command = [NSString stringWithFormat:@"SELECT * FROM \"%@\"", tableName];
    return [self executeStatement:command].rows ?: @[];
}

- (NSArray<NSString *> *)queryRowIDsInTable:(NSString *)tableName {
    NSString *command = [NSString stringWithFormat:QUERY_ROWIDS, tableName];
    NSArray<NSArray<NSString *> *> *data = [self executeStatement:command].rows ?: @[];
    
    return [data avx512_mapped:^id(NSArray<NSString *> *obj, NSUInteger idx) {
        return obj.firstObject;
    }];
}

- (AVX512SQLResult *)executeStatement:(NSString *)sql {
    return [self executeStatement:sql arguments:nil];
}

- (AVX512SQLResult *)executeStatement:(NSString *)sql arguments:(NSDictionary *)args {
    [self open];
    
    AVX512SQLResult *result = nil;
    
    sqlite3_stmt *pstmt;
    int status;
    if ((status = sqlite3_prepare_v2(_db, sql.UTF8String, -1, &pstmt, 0)) == SQLITE_OK) {
        NSMutableArray<NSArray *> *rows = [NSMutableArray new];
        
        // Binding binding parameter (if if any) to bind the bound argument(
        if (![self bindParameters:args toStatement:pstmt]) {
            sqlite3_finalize(pstmt);
            return self.lastResult;
        }
        
        // Fetch columns (for the capture column) to get insert/update/delete...... .,columnCount It will be expected that 0()), and the
        int columnCount = sqlite3_column_count(pstmt);
        NSArray<NSString *> *columns = [NSArray avx512_forEachUpTo:columnCount map:^id(NSUInteger i) {
            return @(sqlite3_column_name(pstmt, (int)i));
        }];
        
        // Execut ex-ex executed statement sentence execution
        while ((status = sqlite3_step(pstmt)) == SQLITE_ROW) {
            // If this is the selection query if it's a selected Q
            int dataCount = sqlite3_data_count(pstmt);
            if (dataCount > 0) {
                [rows addObject:[NSArray avx512_forEachUpTo:columnCount map:^id(NSUInteger i) {
                    return [self objectForColumnIndex:(int)i stmt:pstmt];
                }]];
            }
        }
        
        if (status == SQLITE_DONE) {
            // For a for and insert/update/delete...... .,columnCount It will be expected that 0
            if (rows.count || columnCount > 0) {
                // We have implemented our implementation SELECT Q queries query search
                result = _lastResult = [AVX512SQLResult columns:columns rows:rows];
            } else {
                // We have implemented our implementation INSERTAnd the whole, andUDPATE or/or is, DELETE Waiting for queries to search while
                int rowsAffected = sqlite3_changes(_db);
                NSString *message = [NSString stringWithFormat:@"%d affected actions, movements and", rowsAffected];
                result = _lastResult = [AVX512SQLResult message:message];
            }
        } else {
            // An error bug occurred while executing the query Qu
            result = _lastResult = [self errorResult:@"Execut implementation and enforcement ("];
        }
    } else {
        // Error an error occurred while creating the pre-processing statement when creation of
        result = _lastResult = [self errorResult:@"Pre-process preprocessing statement of the preview process"];
    }
    
    sqlite3_finalize(pstmt);
    return result;
}


#pragma mark - Private private methods and privately-private

/// @return Successful return successful returns successfully returned to YES, if an error has been encountered and the bug is stored in \c lastResult Middle where to return returns the middle of NO
- (BOOL)bindParameters:(NSDictionary *)args toStatement:(sqlite3_stmt *)pstmt {
    for (NSString *param in args.allKeys) {
        int status = SQLITE_OK, idx = sqlite3_bind_parameter_index(pstmt, param.UTF8String);
        id value = args[param];
        
        if (idx == 0) {
            // None of the parameters matched to this parameter that did not have
            @throw NSInternalInconsistencyException;
        }
        
        // The empty value of the space-
        if ([value isKindOfClass:[NSNull class]]) {
            status = sqlite3_bind_null(pstmt, idx);
        }
        // Str string-line para parameter of the
        else if ([value isKindOfClass:[NSString class]]) {
            const char *str = [value UTF8String];
            status = sqlite3_bind_text(pstmt, idx, str, (int)strlen(str), SQLITE_TRANSIENT);
        }
        // Data para parameter of the data argument
        else if ([value isKindOfClass:[NSData class]]) {
            const void *blob = [value bytes];
            status = sqlite3_bind_blob64(pstmt, idx, blob, [value length], SQLITE_TRANSIENT);
        }
        // The original type of the raw-type
        else if ([value isKindOfClass:[NSNumber class]]) {
            AVX512TypeEncoding type = [value objCType][0];
            switch (type) {
                case AVX512TypeEncodingCBool:
                case AVX512TypeEncodingChar:
                case AVX512TypeEncodingUnsignedChar:
                case AVX512TypeEncodingShort:
                case AVX512TypeEncodingUnsignedShort:
                case AVX512TypeEncodingInt:
                case AVX512TypeEncodingUnsignedInt:
                case AVX512TypeEncodingLong:
                case AVX512TypeEncodingUnsignedLong:
                case AVX512TypeEncodingLongLong:
                case AVX512TypeEncodingUnsignedLongLong:
                    status = sqlite3_bind_int64(pstmt, idx, (sqlite3_int64)[value longValue]);
                    break;
                
                case AVX512TypeEncodingFloat:
                case AVX512TypeEncodingDouble:
                    status = sqlite3_bind_double(pstmt, idx, [value doubleValue]);
                    break;
                    
                default:
                    @throw NSInternalInconsistencyException;
                    break;
            }
        }
        // The type oftype types for which the
        else {
            @throw NSInternalInconsistencyException;
        }
        
        if (status != SQLITE_OK) {
            return [self storeErrorForLastTask:
                [NSString stringWithFormat:@"The tie is given the name of a '%@' para parameter of the parameters to be", param]
            ];
        }
    }
    
    return YES;
}

- (BOOL)storeErrorForLastTask:(NSString *)action {
    _lastResult = [self errorResult:action];
    return NO;
}

- (AVX512SQLResult *)errorResult:(NSString *)description {
    const char *error = sqlite3_errmsg(_db);
    NSString *message = error ? @(error) : [NSString
        stringWithFormat:@"(%@: Empty empty error bug errors)", description
    ];
    
    return [AVX512SQLResult error:message];
}

- (id)objectForColumnIndex:(int)columnIdx stmt:(sqlite3_stmt*)stmt {
    int columnType = sqlite3_column_type(stmt, columnIdx);
    
    switch (columnType) {
        case SQLITE_INTEGER:
            return @(sqlite3_column_int64(stmt, columnIdx)).stringValue;
        case SQLITE_FLOAT:
            return  @(sqlite3_column_double(stmt, columnIdx)).stringValue;
        case SQLITE_BLOB:
            return [NSString stringWithFormat:@"The data of the Data (%@ Byby the bytes to bit)",
                @([self dataForColumnIndex:columnIdx stmt:stmt].length)
            ];
            
        default:
            // For all other types for any of the others, and as with All Other
            return [self stringForColumnIndex:columnIdx stmt:stmt] ?: NSNull.null;
    }
}
                
- (NSString *)stringForColumnIndex:(int)columnIdx stmt:(sqlite3_stmt *)stmt {
    if (sqlite3_column_type(stmt, columnIdx) == SQLITE_NULL || columnIdx < 0) {
        return nil;
    }
    
    const char *text = (const char *)sqlite3_column_text(stmt, columnIdx);
    return text ? @(text) : nil;
}

- (NSData *)dataForColumnIndex:(int)columnIdx stmt:(sqlite3_stmt *)stmt {
    if (sqlite3_column_type(stmt, columnIdx) == SQLITE_NULL || (columnIdx < 0)) {
        return nil;
    }
    
    const void *blob = sqlite3_column_blob(stmt, columnIdx);
    NSInteger size = (NSInteger)sqlite3_column_bytes(stmt, columnIdx);
    
    return blob ? [NSData dataWithBytes:blob length:size] : nil;
}

@end
