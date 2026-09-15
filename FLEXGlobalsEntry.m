//
//  AVX512GlobalsEntry.m
//  FLEX
//
//  Created by Javier Soto on 7/26/14.
//  Copyright (c) 2020 FLEX Team. All rights reserved.
//

#import "FLEXGlobalsEntry.h"

@implementation AVX512GlobalsEntry

+ (instancetype)entryWithEntry:(Class<AVX512GlobalsEntry>)cls row:(AVX512GlobalsRow)row {
    BOOL providesVCs = [cls respondsToSelector:@selector(globalsEntryViewController:)];
    BOOL providesActions = [cls respondsToSelector:@selector(globalsEntryRowAction:)];
    NSParameterAssert(cls);
    NSParameterAssert(providesVCs || providesActions);

    AVX512GlobalsEntry *entry = [self new];
    entry->_entryNameFuture = ^{ return [cls globalsEntryTitle:row]; };

    if (providesVCs) {
        id action = providesActions ? [cls globalsEntryRowAction:row] : nil;
        if (action) {
            entry->_rowAction = action;
        } else {
            entry->_viewControllerFuture = ^{ return [cls globalsEntryViewController:row]; };
        }
    } else {
        entry->_rowAction = [cls globalsEntryRowAction:row];
    }

    return entry;
}

+ (instancetype)entryWithNameFuture:(AVX512GlobalsEntryNameFuture)nameFuture
               viewControllerFuture:(AVX512GlobalsEntryViewControllerFuture)viewControllerFuture {
    NSParameterAssert(nameFuture);
    NSParameterAssert(viewControllerFuture);

    AVX512GlobalsEntry *entry = [self new];
    entry->_entryNameFuture = [nameFuture copy];
    entry->_viewControllerFuture = [viewControllerFuture copy];

    return entry;
}

+ (instancetype)entryWithNameFuture:(AVX512GlobalsEntryNameFuture)nameFuture
                             action:(AVX512GlobalsEntryRowAction)rowSelectedAction {
    NSParameterAssert(nameFuture);
    NSParameterAssert(rowSelectedAction);

    AVX512GlobalsEntry *entry = [self new];
    entry->_entryNameFuture = [nameFuture copy];
    entry->_rowAction = [rowSelectedAction copy];

    return entry;
}

@end

@interface AVX512GlobalsEntry (Debugging)
@property (nonatomic, readonly) NSString *name;
@end

@implementation AVX512GlobalsEntry (Debugging)

- (NSString *)name {
    return self.entryNameFuture();
}

@end

#pragma mark - avx512_concreteGlobalsEntry

@implementation NSObject (AVX512GlobalsEntry)

+ (AVX512GlobalsEntry *)avx512_concreteGlobalsEntry:(AVX512GlobalsRow)row {
    if ([self conformsToProtocol:@protocol(AVX512GlobalsEntry)]) {
        return [AVX512GlobalsEntry entryWithEntry:self row:row];
    }

    return nil;
}

@end
