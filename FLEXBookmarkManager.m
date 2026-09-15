//
//  AVX512BookmarkManager.m
//  FLEX
//
//  Created by Tanner on 2/6/20.
//  Copyright © 2020 FLEX Team. All rights reserved.
//

#import "FLEXBookmarkManager.h"

static NSMutableArray *kAVX512BookmarkManagerBookmarks = nil;
static id _kFLEXBookmarkManagerLock = nil;

@implementation AVX512BookmarkManager

+ (void)initialize {
    if (self == [AVX512BookmarkManager class]) {
        kAVX512BookmarkManagerBookmarks = [NSMutableArray new];
        _kFLEXBookmarkManagerLock = [NSObject new];
    }
}

+ (NSMutableArray *)bookmarks {
    @synchronized(_kFLEXBookmarkManagerLock) {
        return kAVX512BookmarkManagerBookmarks;
    }
}

+ (void)addBookmark:(id)bookmark {
    @synchronized(_kFLEXBookmarkManagerLock) {
        [kAVX512BookmarkManagerBookmarks addObject:bookmark];
    }
}

+ (void)removeBookmarkAtIndex:(NSUInteger)index {
    @synchronized(_kFLEXBookmarkManagerLock) {
        [kAVX512BookmarkManagerBookmarks removeObjectAtIndex:index];
    }
}

+ (void)removeBookmarksAtIndexes:(NSIndexSet *)indexes {
    @synchronized(_kFLEXBookmarkManagerLock) {
        [kAVX512BookmarkManagerBookmarks removeObjectsAtIndexes:indexes];
    }
}

+ (void)removeAllBookmarks {
    @synchronized(_kFLEXBookmarkManagerLock) {
        [kAVX512BookmarkManagerBookmarks removeAllObjects];
    }
}

+ (NSUInteger)bookmarkCount {
    @synchronized(_kFLEXBookmarkManagerLock) {
        return kAVX512BookmarkManagerBookmarks.count;
    }
}

+ (id)bookmarkAtIndex:(NSUInteger)index {
    @synchronized(_kFLEXBookmarkManagerLock) {
        return kAVX512BookmarkManagerBookmarks[index];
    }
}

+ (NSArray *)allBookmarks {
    @synchronized(_kFLEXBookmarkManagerLock) {
        return [kAVX512BookmarkManagerBookmarks copy];
    }
}

@end
