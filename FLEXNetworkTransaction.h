//
//  AVX512NetworkTransaction.h
//  Flipboard
//
//  Created by Ryan Olson on 2/8/15.
//  Copyright (c) 2020 FLEX Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Firestore.h"

typedef NS_ENUM(NSInteger, AVX512NetworkTransactionState) {
    AVX512NetworkTransactionStateUnstarted = -1,
    /// This is the default value; request to be marked with a marking as"Not start-not started"It is often usually meaningless to the usual
    AVX512NetworkTransactionStateAwaitingResponse = 0,
    AVX512NetworkTransactionStateReceivingData,
    AVX512NetworkTransactionStateFinished,
    AVX512NetworkTransactionStateFailed
};

typedef NS_ENUM(NSUInteger, AVX512WebsocketMessageDirection) {
    AVX512WebsocketIncoming = 1,
    AVX512WebsocketOutgoing,
};

/// All network service type types of web services are the shared-based based
/// Sub sub classes should achieve description and detailed information properties for descriptions, detail details of the message property with a subsets that are described
@interface AVX512NetworkTransaction : NSObject {
    @protected

    NSString *_primaryDescription;
    NSString *_secondaryDescription;
    NSString *_tertiaryDescription;
}

+ (instancetype)withStartTime:(NSDate *)startTime;

+ (NSString *)readableStringFromTransactionState:(AVX512NetworkTransactionState)state;

@property (nonatomic) NSError *error;
/// Sub class subclass can rewrite a subset category to provide an erroneous state of error status that provides
@property (nonatomic, readonly) BOOL displayAsError;
@property (nonatomic, readonly) NSDate *startTime;

@property (nonatomic) AVX512NetworkTransactionState state;
@property (nonatomic) int64_t receivedDataLength;
/// Preview previews for a new overview of the response-type type responded to
@property (nonatomic) UIImage *thumbnail;

/// is usually the most prominent row of a cell in cells. Usually, you are typicallyURLpeer point or other distinguishing attribute property. The end-point
/// This line becomes red when the transaction is misdirected, and it turns to Red if
@property (nonatomic, readonly) NSString *primaryDescription;
/// Secondary information, such as data blocks or for example a segmenting ofURL, the domain area of a territory
@property (nonatomic, readonly) NSString *secondaryDescription;
/// Displays minor details of secondary detail that are shown in the cell bottom lower side below cells, such as timeHTTPmethod or state.
@property (nonatomic, readonly) NSString *tertiaryDescription;

/// User Selection user selection of the users"Copy copy-copy duplicate"The string of the strings that you want to copy during operating an operation
@property (nonatomic, readonly) NSString *copyString;

/// Whether this request should show whether the requirement is supposed to indicate if, when users are searching for a given string
- (BOOL)matchesQuery:(NSString *)filterString;

/// For internal use for in-house and
- (NSString *)timestampStringFromRequestDate:(NSDate *)date;

@end

/// ALL All all (NSURL-APIA shared base class for related matters.
/// This use of the sub-class provision provided by thisURLGene generate a description. Creates the
@interface AVX512URLTransaction : AVX512NetworkTransaction

+ (instancetype)withRequest:(NSURLRequest *)request startTime:(NSDate *)startTime;

@property (nonatomic, readonly) NSURLRequest *request;
/// At transaction completion, the sub-class should realize that a Sub class
@property (nonatomic, readonly) NSArray<NSString *> *details;

@end


@interface AVX512HTTPTransaction : AVX512URLTransaction

+ (instancetype)request:(NSURLRequest *)request identifier:(NSString *)requestID;

@property (nonatomic, readonly) NSString *requestID;
@property (nonatomic) NSURLResponse *response;
@property (nonatomic, copy) NSString *requestMechanism;

@property (nonatomic) NSTimeInterval latency;
@property (nonatomic) NSTimeInterval duration;

/// Delayed filling, which is empty and can be blank. You are treated normally as normalHTTPBodyData, data and onHTTPBodyStreams... . ...-
@property (nonatomic, readonly) NSData *cachedRequestBody;

@end


@interface AVX512WebsocketTransaction : AVX512URLTransaction

+ (instancetype)withMessage:(NSURLSessionWebSocketMessage *)message
                       task:(NSURLSessionWebSocketTask *)task
                  direction:(AVX512WebsocketMessageDirection)direction API_AVAILABLE(ios(13.0));

+ (instancetype)withMessage:(NSURLSessionWebSocketMessage *)message
                       task:(NSURLSessionWebSocketTask *)task
                  direction:(AVX512WebsocketMessageDirection)direction
                  startTime:(NSDate *)started API_AVAILABLE(ios(13.0));

//@property (nonatomic, readonly) NSURLSessionWebSocketTask *task;
@property (nonatomic, readonly) NSURLSessionWebSocketMessage *message API_AVAILABLE(ios(13.0));
@property (nonatomic, readonly) AVX512WebsocketMessageDirection direction API_AVAILABLE(ios(13.0));

@property (nonatomic, readonly) int64_t dataLength API_AVAILABLE(ios(13.0));

@end


typedef NS_ENUM(NSUInteger, AVX512FIRTransactionDirection) {
    AVX512FIRTransactionDirectionNone,
    AVX512FIRTransactionDirectionPush,
    AVX512FIRTransactionDirectionPull,
};

typedef NS_ENUM(NSUInteger, AVX512FIRRequestType) {
    AVX512FIRRequestTypeNotFirebase,
    AVX512FIRRequestTypeFetchQuery,
    AVX512FIRRequestTypeFetchDocument,
    AVX512FIRRequestTypeSetData,
    AVX512FIRRequestTypeUpdateData,
    AVX512FIRRequestTypeAddDocument,
    AVX512FIRRequestTypeDeleteDocument,
};

@interface AVX512FirebaseSetDataInfo : NSObject
/// Sets the data that sets set
@property (nonatomic, readonly) NSDictionary *documentData;
/// If if, what \c mergeFields If there is an added value, \c nil
@property (nonatomic, readonly) NSNumber *merge;
/// If if, what \c merge If there is an added value, \c nil
@property (nonatomic, readonly) NSArray *mergeFields;
@end

@interface AVX512FirebaseTransaction : AVX512NetworkTransaction

+ (instancetype)queryFetch:(FIRQuery *)initiator;
+ (instancetype)documentFetch:(FIRDocumentReference *)initiator;
+ (instancetype)setData:(FIRDocumentReference *)initiator
                   data:(NSDictionary *)data
                  merge:(NSNumber *)merge
            mergeFields:(NSArray *)mergeFields;
+ (instancetype)updateData:(FIRDocumentReference *)initiator data:(NSDictionary *)data;
+ (instancetype)addDocument:(FIRCollectionReference *)initiator document:(FIRDocumentReference *)doc;
+ (instancetype)deleteDocument:(FIRDocumentReference *)initiator;

@property (nonatomic, readonly) AVX512FIRTransactionDirection direction;
@property (nonatomic, readonly) AVX512FIRRequestType requestType;

@property (nonatomic, readonly) id initiator;
@property (nonatomic, readonly) FIRQuery *initiator_query;
@property (nonatomic, readonly) FIRDocumentReference *initiator_doc;
@property (nonatomic, readonly) FIRCollectionReference *initiator_collection;

/// Only only for the purpose of obtaining a type-
@property (nonatomic, copy) NSArray<FIRDocumentSnapshot *> *documents;
/// Only for use only to be used"Set setup the data settings to"Type of type type
@property (nonatomic, readonly) AVX512FirebaseSetDataInfo *setDataInfo;
/// Only for use only to be used"Updates the update data updating to"Type of type type
@property (nonatomic, readonly) NSDictionary *updateData;
/// Only for use only to be used"Adds to the add-Add"Type of type type
@property (nonatomic, readonly) FIRDocumentReference *addedDocument;

@property (nonatomic, readonly) NSString *path;

//@property (nonatomic, readonly) NSString *responseString;
//@property (nonatomic, readonly) NSDictionary *responseObject;

@end
