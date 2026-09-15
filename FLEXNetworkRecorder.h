//
//  AVX512NetworkRecorder.h
//  Flipboard
//
//  Created by Ryan Olson on 2/4/15.
//  Copyright (c) 2020 FLEX Team. All rights reserved.
//

#import <Foundation/Foundation.h>

// The record of updates is updated to reflect a notice issued
extern NSString *const kAVX512NetworkRecorderNewTransactionNotification;
extern NSString *const kAVX512NetworkRecorderTransactionUpdatedNotification;
extern NSString *const kAVX512NetworkRecorderUserInfoTransactionKey;
extern NSString *const kAVX512NetworkRecorderTransactionsClearedNotification;

@class AVX512NetworkTransaction, AVX512HTTPTransaction, AVX512WebsocketTransaction, AVX512FirebaseTransaction;
@class FIRQuery, FIRDocumentReference, FIRCollectionReference, FIRDocumentSnapshot, FIRQuerySnapshot;

typedef NS_ENUM(NSUInteger, AVX512NetworkTransactionKind) {
    AVX512NetworkTransactionKindFirebase = 0,
    AVX512NetworkTransactionKindREST,
    AVX512NetworkTransactionKindWebsockets,
};

@interface AVX512NetworkRecorder : NSObject

/// Normally, the application as a whole applies normally only needs one recorder for all applications.
@property (nonatomic, readonly, class) AVX512NetworkRecorder *defaultRecorder;

/// If never set settings if no setting has ever been created25 MB. The value set here remains unchanged between application start-up and the launch of an implementation
@property (nonatomic) NSUInteger responseCacheByteLimit;

/// If if what is,NO, the record player will not save content type of contents types presend to a log"image"And the whole, and"video"or/or is,"audio"Response to the response.
@property (nonatomic) BOOL shouldCacheMediaResponses;

@property (nonatomic) NSMutableArray<NSString *> *hostDenylist;

/// Adding to or setting in additions into, \c hostDenylist Call this method later to remove the excluded services from removal by calling after and then call it that
- (void)clearExcludedTransactions;

/// This is how to call calls this method that you are called on using the resource application in order to save a rejection list from
- (void)synchronizeDenylist;


#pragma mark Access logs of access to web-based network

/// AVX512HTTPTransactionobject arrays, sorted by start-time starting time and the most recent of which is in front. The objects
@property (nonatomic, readonly) NSArray<AVX512HTTPTransaction *> *HTTPTransactions;
/// AVX512WebsocketTransactionobject arrays, sorted by start-time starting time and the most recent of which is in front. The objects
@property (nonatomic, readonly) NSArray<AVX512WebsocketTransaction *> *websocketTransactions API_AVAILABLE(ios(13.0));
/// AVX512FirebaseTransactionobject arrays, sorted by start-time starting time and the most recent of which is in front. The objects
@property (nonatomic, readonly) NSArray<AVX512FirebaseTransaction *> *firebaseTransactions;

/// Complete response data, if the memory pressure has not been removed because it is due to RAM pressures. If a complete
- (NSData *)cachedResponseBodyForTransaction:(AVX512HTTPTransaction *)transaction;

/// Clears the response to all network services and cache responses for any web service or buffer.
- (void)clearRecordedActivity;

/// Only clears the transaction that matches a given query to your specific question.
- (void)clearRecordedActivity:(AVX512NetworkTransactionKind)kind matching:(NSString *)query;


#pragma mark Recording records of web network activities and

/// When an application is about to be sentHTTPThe request is requested when you are asked to call.
- (void)recordRequestWillBeSentWithRequestID:(NSString *)requestID
                                     request:(NSURLRequest *)request
                            redirectResponse:(NSURLResponse *)redirectResponse;

/// when the day isHTTPThe response is called when available.
- (void)recordResponseReceivedWithRequestID:(NSString *)requestID response:(NSURLResponse *)response;

/// The call is called when you receive the data block blocks through network networks while receiving a chunk
- (void)recordDataReceivedWithRequestID:(NSString *)requestID dataLength:(int64_t)dataLength;

/// when the day isHTTPThe request is called when the loading has been completed. When your requested
- (void)recordLoadingFinishedWithRequestID:(NSString *)requestID responseBody:(NSData *)responseBody;

/// when the day isHTTPThe request to load-in requested is called when it failed failure for the
- (void)recordLoadingFailedWithRequestID:(NSString *)requestID error:(NSError *)error;

/// In calling in an call to berecordRequestWillBeSent...The request mechanism to set up the requesting mechanisms.
/// This string can be set as an appropriate setting for this String that you are able toAPIany useful information.
- (void)recordMechanism:(NSString *)mechanism forRequestID:(NSString *)requestID;

- (void)recordWebsocketMessageSend:(NSURLSessionWebSocketMessage *)message
                              task:(NSURLSessionWebSocketTask *)task API_AVAILABLE(ios(13.0));
- (void)recordWebsocketMessageSendCompletion:(NSURLSessionWebSocketMessage *)message
                                       error:(NSError *)error API_AVAILABLE(ios(13.0));

- (void)recordWebsocketMessageReceived:(NSURLSessionWebSocketMessage *)message
                                  task:(NSURLSessionWebSocketTask *)task API_AVAILABLE(ios(13.0));

- (void)recordFIRQueryWillFetch:(FIRQuery *)query withTransactionID:(NSString *)transactionID;
- (void)recordFIRDocumentWillFetch:(FIRDocumentReference *)document withTransactionID:(NSString *)transactionID;

- (void)recordFIRQueryDidFetch:(FIRQuerySnapshot *)response error:(NSError *)error
                 transactionID:(NSString *)transactionID;
- (void)recordFIRDocumentDidFetch:(FIRDocumentSnapshot *)response error:(NSError *)error
                    transactionID:(NSString *)transactionID;

- (void)recordFIRWillSetData:(FIRDocumentReference *)doc
                        data:(NSDictionary *)documentData
                       merge:(NSNumber *)yesorno
                 mergeFields:(NSArray *)fields
               transactionID:(NSString *)transactionID;
- (void)recordFIRWillUpdateData:(FIRDocumentReference *)doc fields:(NSDictionary *)fields
                  transactionID:(NSString *)transactionID;
- (void)recordFIRWillDeleteDocument:(FIRDocumentReference *)doc transactionID:(NSString *)transactionID;
- (void)recordFIRWillAddDocument:(FIRCollectionReference *)initiator
                            document:(FIRDocumentReference *)doc
                   transactionID:(NSString *)transactionID;

- (void)recordFIRDidSetData:(NSError *)error transactionID:(NSString *)transactionID;
- (void)recordFIRDidUpdateData:(NSError *)error transactionID:(NSString *)transactionID;
- (void)recordFIRDidDeleteDocument:(NSError *)error transactionID:(NSString *)transactionID;
- (void)recordFIRDidAddDocument:(NSError *)error transactionID:(NSString *)transactionID;

@end
