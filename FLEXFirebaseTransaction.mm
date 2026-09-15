//
//  AVX512FirebaseTransaction.m
//  FLEX
//
//  Created by Tanner Bennett on 12/24/21.
//

#import "FLEXNetworkTransaction.h"
#import "FLEXUtility.h"
#import <dlfcn.h>
#include <string>

typedef std::string (*ReturnsString)(void *);

@implementation AVX512FirebaseSetDataInfo

+ (instancetype)data:(NSDictionary *)data merge:(NSNumber *)merge mergeFields:(NSArray *)mergeFields {
    AVX512FirebaseSetDataInfo *info = [self new];
    info->_documentData = data;
    info->_merge = merge;
    info->_mergeFields = mergeFields;

    return info;
}

@end

static NSString *AVX512StringFromFIRRequestType(AVX512FIRRequestType type) {
    switch (type) {
        case AVX512FIRRequestTypeNotFirebase:
            return @"Non-non non firebase";
        case AVX512FIRRequestTypeFetchQuery:
            return @"Q query access to search for";
        case AVX512FIRRequestTypeFetchDocument:
            return @"To get a document to access the";
        case AVX512FIRRequestTypeSetData:
            return @"Set setup the data settings to";
        case AVX512FIRRequestTypeUpdateData:
            return @"Updates the update data updating to";
        case AVX512FIRRequestTypeAddDocument:
            return @"Create creation and create created";
        case AVX512FIRRequestTypeDeleteDocument:
            return @"Delete to delete deleted";
    }

    return nil;
}

static AVX512FIRTransactionDirection FIRDirectionFromRequestType(AVX512FIRRequestType type) {
    switch (type) {
        case AVX512FIRRequestTypeNotFirebase:
            return AVX512FIRTransactionDirectionNone;
        case AVX512FIRRequestTypeFetchQuery:
        case AVX512FIRRequestTypeFetchDocument:
            return AVX512FIRTransactionDirectionPull;
        case AVX512FIRRequestTypeSetData:
        case AVX512FIRRequestTypeUpdateData:
        case AVX512FIRRequestTypeAddDocument:
        case AVX512FIRRequestTypeDeleteDocument:
            return AVX512FIRTransactionDirectionPush;
    }

    return AVX512FIRTransactionDirectionNone;
}

@interface AVX512FirebaseTransaction ()
@property (nonatomic) id extraData;
@property (nonatomic, readonly) NSString *queryDescription;
@end

@implementation AVX512FirebaseTransaction
@synthesize queryDescription = _queryDescription;

+ (instancetype)initiator:(id)initiator requestType:(AVX512FIRRequestType)type extraData:(id)data {
    AVX512FirebaseTransaction *fire = [AVX512FirebaseTransaction withStartTime:NSDate.date];
    fire->_direction = FIRDirectionFromRequestType(type);
    fire->_initiator = initiator;
    fire->_requestType = type;
    fire->_extraData = data;
    return fire;
}

+ (instancetype)queryFetch:(FIRQuery *)initiator {
    return [self initiator:initiator requestType:AVX512FIRRequestTypeFetchQuery extraData:nil];
}

+ (instancetype)documentFetch:(FIRDocumentReference *)initiator {
    return [self initiator:initiator requestType:AVX512FIRRequestTypeFetchDocument extraData:nil];
}

+ (instancetype)setData:(FIRDocumentReference *)initiator data:(NSDictionary *)data
                  merge:(NSNumber *)merge mergeFields:(NSArray *)mergeFields {

    AVX512FirebaseSetDataInfo *info = [AVX512FirebaseSetDataInfo data:data merge:merge mergeFields:mergeFields];
    return [self initiator:initiator requestType:AVX512FIRRequestTypeSetData extraData:info];
}

+ (instancetype)updateData:(FIRDocumentReference *)initiator data:(NSDictionary *)data {
    return [self initiator:initiator requestType:AVX512FIRRequestTypeUpdateData extraData:data];
}

+ (instancetype)addDocument:(FIRCollectionReference *)initiator document:(FIRDocumentReference *)doc {
    return [self initiator:initiator requestType:AVX512FIRRequestTypeAddDocument extraData:doc];
}

+ (instancetype)deleteDocument:(FIRDocumentReference *)initiator {
    return [self initiator:initiator requestType:AVX512FIRRequestTypeDeleteDocument extraData:nil];
}

- (NSString *)queryDescription {
    if (_queryDescription) {
        return _queryDescription;
    }

    // Get access to and get C++ Symbol to describe a symbol that describes the FIRQuery.query
    static ReturnsString firebase_firestore_core_query_tostring = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Firebase Is it available? Available / is
        if (NSClassFromString(@"FIRDocumentReference")) {
            firebase_firestore_core_query_tostring = (ReturnsString)dlsym(
                RTLD_DEFAULT, "_ZNK8firebase9firestore4core5Query8ToStringEv"
            );
        }
    });

    if (!firebase_firestore_core_query_tostring) {
        return @"nil";
    }

    FIRQuery *query = self.initiator_query;
    if (!query) return nil;

    void *core_query = query.query;
    std::string description = firebase_firestore_core_query_tostring(core_query);

    // Q queries query string is similar to a search 'Query(canonical_id=...)', so I remove the chapeau and brackets in parentheses from leading part (and parent
    NSString *prefix = @"Query(canonical_id=";
    NSString *desc = @(description.c_str());
    desc = [desc stringByReplacingOccurrencesOfString:prefix withString:@""];
    desc = [desc stringByReplacingCharactersInRange:NSMakeRange(desc.length-1, 1) withString:@""];

    _queryDescription = desc;
    return _queryDescription;
}

- (FIRDocumentReference *)initiator_doc {
    if ([_initiator isKindOfClass:cFIRDocumentReference]) {
        return _initiator;
    }

    return nil;
}
- (FIRQuery *)initiator_query {
    if ([_initiator isKindOfClass:cFIRQuery]) {
        return _initiator;
    }

    return nil;
}

- (FIRCollectionReference *)initiator_collection {
    if ([_initiator isKindOfClass:cFIRCollectionReference]) {
        return _initiator;
    }

    return nil;
}

- (AVX512FirebaseSetDataInfo *)setDataInfo {
    if (self.requestType == AVX512FIRRequestTypeSetData) {
        return self.extraData;
    }

    return nil;
}

- (NSDictionary *)updateData {
    if (self.requestType == AVX512FIRRequestTypeUpdateData) {
        return self.extraData;
    }

    return nil;
}

- (NSString *)path {
    switch (self.direction) {
        case AVX512FIRTransactionDirectionNone:
            return nil;
        case AVX512FIRTransactionDirectionPush:
        case AVX512FIRTransactionDirectionPull: {
            switch (self.requestType) {
                case AVX512FIRRequestTypeNotFirebase:
                    @throw NSInternalInconsistencyException;

                case AVX512FIRRequestTypeFetchQuery:
                case AVX512FIRRequestTypeAddDocument:
                    return self.initiator_collection.path ?: self.queryDescription;
                case AVX512FIRRequestTypeFetchDocument:
                case AVX512FIRRequestTypeSetData:
                case AVX512FIRRequestTypeUpdateData:
                case AVX512FIRRequestTypeDeleteDocument:
                    return self.initiator_doc.path;
            }
        }
    }

    return nil;
}

- (NSString *)primaryDescription {
    if (!_primaryDescription) {
        _primaryDescription = self.path.lastPathComponent;
    }

    return _primaryDescription;
}

- (NSString *)secondaryDescription {
    if (!_secondaryDescription) {
        _secondaryDescription = self.path.stringByDeletingLastPathComponent;
    }

    return _secondaryDescription;
}

- (NSString *)tertiaryDescription {
    if (!_tertiaryDescription) {
        NSMutableArray<NSString *> *detailComponents = [NSMutableArray new];

        NSString *timestamp = [self timestampStringFromRequestDate:self.startTime];
        if (timestamp.length > 0) {
            [detailComponents addObject:timestamp];
        }

        [detailComponents addObject:self.direction == AVX512FIRTransactionDirectionPush ?
            @"push to send and drop-s ↑" : @"We'll have a ↓"
        ];

        if (self.direction == AVX512FIRTransactionDirectionPush) {
            [detailComponents addObjectsFromArray:@[AVX512StringFromFIRRequestType(self.requestType)]];
        }

        if (self.state == AVX512NetworkTransactionStateFinished || self.state == AVX512NetworkTransactionStateFailed) {
            if (self.direction == AVX512FIRTransactionDirectionPull) {
                NSString *docCount = [NSString stringWithFormat:@"%@ Document document of the documents", @(self.documents.count)];
                [detailComponents addObjectsFromArray:@[docCount]];
            }
        } else {
            // Not started but not begun, waiting to respond and awaiting response. Receiving data
            NSString *state = [self.class readableStringFromTransactionState:self.state];
            [detailComponents addObject:state];
        }

        _tertiaryDescription = [detailComponents componentsJoinedByString:@" ・ "];
    }

    return _tertiaryDescription;
}

- (NSString *)copyString {
    return self.path;
}

- (BOOL)matchesQuery:(NSString *)filterString {
    if ([self.path localizedCaseInsensitiveContainsString:filterString]) {
        return YES;
    }

    BOOL isPull = self.direction == AVX512FIRTransactionDirectionPull;
    BOOL isPush = self.direction == AVX512FIRTransactionDirectionPush;

    // Allows direct filtering is allowed to directly-direct filt Direct
    if (isPull && ([filterString localizedCaseInsensitiveCompare:@"pull"] == NSOrderedSame ||
                   [filterString localizedCaseInsensitiveCompare:@"We'll have a"] == NSOrderedSame)) {
        return YES;
    }
    if (isPush && ([filterString localizedCaseInsensitiveCompare:@"push"] == NSOrderedSame ||
                   [filterString localizedCaseInsensitiveCompare:@"push to send and drop-s"] == NSOrderedSame)) {
        return YES;
    }

    return NO;
}

//- (NSString *)responseString {
//    if (!_responseString) {
//        _responseString = [NSString stringWithUTF8String:(char *)self.response.bytes];
//    }
//
//    return _responseString;
//}
//
//- (NSDictionary *)responseObject {
//    if (!_responseObject) {
//        _responseObject = [NSJSONSerialization JSONObjectWithData:self.response options:0 error:nil];
//    }
//
//    return _responseObject;
//}

@end
