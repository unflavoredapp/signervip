//
//  AVX512NetworkTransactionDetailController.m
//  Flipboard
//
//  Created by Ryan Olson on 2/10/15.
//  Copyright (c) 2020 FLEX Team. All rights reserved.
//

#import "FLEXColor.h"
#import "FLEXHTTPTransactionDetailController.h"
#import "FLEXNetworkCurlLogger.h"
#import "FLEXNetworkRecorder.h"
#import "FLEXNetworkTransaction.h"
#import "FLEXWebViewController.h"
#import "FLEXImagePreviewViewController.h"
#import "FLEXMultilineTableViewCell.h"
#import "FLEXUtility.h"
#import "FLEXManager+Private.h"
#import "FLEXTableView.h"
#import "UIBarButtonItem+FLEX.h"
#import "NSDateFormatter+FLEX.h"

typedef UIViewController *(^AVX512NetworkDetailRowSelectionFuture)(void);

@interface AVX512NetworkDetailRow : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *detailText;
@property (nonatomic, copy) AVX512NetworkDetailRowSelectionFuture selectionFuture;
@end

@implementation AVX512NetworkDetailRow
@end

@interface AVX512NetworkDetailSection : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSArray<AVX512NetworkDetailRow *> *rows;
@end

@implementation AVX512NetworkDetailSection
@end

@interface AVX512HTTPTransactionDetailController ()

@property (nonatomic, readonly) AVX512HTTPTransaction *transaction;
@property (nonatomic, copy) NSArray<AVX512NetworkDetailSection *> *sections;

@end

@implementation AVX512HTTPTransactionDetailController

+ (instancetype)withTransaction:(AVX512HTTPTransaction *)transaction {
    AVX512HTTPTransactionDetailController *controller = [self new];
    controller.transaction = transaction;
    return controller;
}

- (instancetype)initWithStyle:(UITableViewStyle)style {
    // Force grouped style
    return [super initWithStyle:UITableViewStyleGrouped];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [NSNotificationCenter.defaultCenter addObserver:self
        selector:@selector(handleTransactionUpdatedNotification:)
        name:kAVX512NetworkRecorderTransactionUpdatedNotification
        object:nil
    ];
    self.toolbarItems = @[
        UIBarButtonItem.avx512_flexibleSpace,
        [UIBarButtonItem
            avx512_itemWithTitle:@"Copy copy-copy duplicate curl"
            target:self
            action:@selector(copyButtonPressed:)
        ]
    ];
    
    [self.tableView registerClass:[AVX512MultilineTableViewCell class] forCellReuseIdentifier:kAVX512MultilineCell];
}

- (void)setTransaction:(AVX512HTTPTransaction *)transaction {
    if (![_transaction isEqual:transaction]) {
        _transaction = transaction;
        self.title = [transaction.request.URL lastPathComponent];
        [self rebuildTableSections];
    }
}

- (void)setSections:(NSArray<AVX512NetworkDetailSection *> *)sections {
    if (![_sections isEqual:sections]) {
        _sections = [sections copy];
        [self.tableView reloadData];
    }
}

- (void)rebuildTableSections {
    NSMutableArray<AVX512NetworkDetailSection *> *sections = [NSMutableArray new];

    AVX512NetworkDetailSection *generalSection = [[self class] generalSectionForTransaction:self.transaction];
    if (generalSection.rows.count > 0) {
        [sections addObject:generalSection];
    }
    AVX512NetworkDetailSection *requestHeadersSection = [[self class] requestHeadersSectionForTransaction:self.transaction];
    if (requestHeadersSection.rows.count > 0) {
        [sections addObject:requestHeadersSection];
    }
    AVX512NetworkDetailSection *queryParametersSection = [[self class] queryParametersSectionForTransaction:self.transaction];
    if (queryParametersSection.rows.count > 0) {
        [sections addObject:queryParametersSection];
    }
    AVX512NetworkDetailSection *postBodySection = [[self class] postBodySectionForTransaction:self.transaction];
    if (postBodySection.rows.count > 0) {
        [sections addObject:postBodySection];
    }
    AVX512NetworkDetailSection *responseHeadersSection = [[self class] responseHeadersSectionForTransaction:self.transaction];
    if (responseHeadersSection.rows.count > 0) {
        [sections addObject:responseHeadersSection];
    }

    self.sections = sections;
}

- (void)handleTransactionUpdatedNotification:(NSNotification *)notification {
    AVX512NetworkTransaction *transaction = [[notification userInfo] objectForKey:kAVX512NetworkRecorderUserInfoTransactionKey];
    if (transaction == self.transaction) {
        [self rebuildTableSections];
    }
}

- (void)copyButtonPressed:(id)sender {
    [UIPasteboard.generalPasteboard setString:[AVX512NetworkCurlLogger curlCommandString:_transaction.request]];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    AVX512NetworkDetailSection *sectionModel = self.sections[section];
    return sectionModel.rows.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    AVX512NetworkDetailSection *sectionModel = self.sections[section];
    return sectionModel.title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AVX512MultilineTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kAVX512MultilineCell forIndexPath:indexPath];

    AVX512NetworkDetailRow *rowModel = [self rowModelAtIndexPath:indexPath];

    cell.textLabel.attributedText = [[self class] attributedTextForRow:rowModel];
    cell.accessoryType = rowModel.selectionFuture ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
    cell.selectionStyle = rowModel.selectionFuture ? UITableViewCellSelectionStyleDefault : UITableViewCellSelectionStyleNone;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AVX512NetworkDetailRow *rowModel = [self rowModelAtIndexPath:indexPath];

    UIViewController *viewController = nil;
    if (rowModel.selectionFuture) {
        viewController = rowModel.selectionFuture();
    }

    if ([viewController isKindOfClass:UIAlertController.class]) {
        [self presentViewController:viewController animated:YES completion:nil];
    } else if (viewController) {
        [self.navigationController pushViewController:viewController animated:YES];
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    AVX512NetworkDetailRow *row = [self rowModelAtIndexPath:indexPath];
    NSAttributedString *attributedText = [[self class] attributedTextForRow:row];
    BOOL showsAccessory = row.selectionFuture != nil;
    return [AVX512MultilineTableViewCell
        preferredHeightWithAttributedText:attributedText
        maxWidth:tableView.bounds.size.width
        style:tableView.style
        showsAccessory:showsAccessory
    ];
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [NSArray avx512_forEachUpTo:self.sections.count map:^id(NSUInteger i) {
        return @"⦁";
    }];
}

- (AVX512NetworkDetailRow *)rowModelAtIndexPath:(NSIndexPath *)indexPath {
    AVX512NetworkDetailSection *sectionModel = self.sections[indexPath.section];
    return sectionModel.rows[indexPath.row];
}

#pragma mark - Cell Copying

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    return action == @selector(copy:);
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    if (action == @selector(copy:)) {
        AVX512NetworkDetailRow *row = [self rowModelAtIndexPath:indexPath];
        UIPasteboard.generalPasteboard.string = row.detailText;
    }
}

- (UIContextMenuConfiguration *)tableView:(UITableView *)tableView contextMenuConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath point:(CGPoint)point __IOS_AVAILABLE(13.0) {
    return [UIContextMenuConfiguration
        configurationWithIdentifier:nil
        previewProvider:nil
        actionProvider:^UIMenu *(NSArray<UIMenuElement *> *suggestedActions) {
            UIAction *copy = [UIAction
                actionWithTitle:@"Copy copy-copy duplicate"
                image:nil
                identifier:nil
                handler:^(__kindof UIAction *action) {
                    AVX512NetworkDetailRow *row = [self rowModelAtIndexPath:indexPath];
                    UIPasteboard.generalPasteboard.string = row.detailText;
                }
            ];
            return [UIMenu
                menuWithTitle:@"" image:nil identifier:nil
                options:UIMenuOptionsDisplayInline
                children:@[copy]
            ];
        }
    ];
}

#pragma mark - View Configuration

+ (NSAttributedString *)attributedTextForRow:(AVX512NetworkDetailRow *)row {
    NSDictionary<NSString *, id> *titleAttributes = @{ NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Medium" size:12.0],
                                                       NSForegroundColorAttributeName : [UIColor colorWithWhite:0.5 alpha:1.0] };
    NSDictionary<NSString *, id> *detailAttributes = @{ NSFontAttributeName : UIFont.avx512_defaultTableCellFont,
                                                        NSForegroundColorAttributeName : AVX512Color.primaryTextColor };

    NSString *title = [NSString stringWithFormat:@"%@: ", row.title];
    NSString *detailText = row.detailText ?: @"";
    NSMutableAttributedString *attributedText = [NSMutableAttributedString new];
    [attributedText appendAttributedString:[[NSAttributedString alloc] initWithString:title attributes:titleAttributes]];
    [attributedText appendAttributedString:[[NSAttributedString alloc] initWithString:detailText attributes:detailAttributes]];

    return attributedText;
}

#pragma mark - Table table data to generate the tables of

+ (AVX512NetworkDetailSection *)generalSectionForTransaction:(AVX512HTTPTransaction *)transaction {
    NSMutableArray<AVX512NetworkDetailRow *> *rows = [NSMutableArray new];

    AVX512NetworkDetailRow *requestURLRow = [AVX512NetworkDetailRow new];
    requestURLRow.title = @"Request request, requests requestedURL";
    NSURL *url = transaction.request.URL;
    requestURLRow.detailText = url.absoluteString;
    requestURLRow.selectionFuture = ^{
        UIViewController *urlWebViewController = [[AVX512WebViewController alloc] initWithURL:url];
        urlWebViewController.title = url.absoluteString;
        return urlWebViewController;
    };
    [rows addObject:requestURLRow];

    AVX512NetworkDetailRow *requestMethodRow = [AVX512NetworkDetailRow new];
    requestMethodRow.title = @"Method for requesting methods of method to";
    requestMethodRow.detailText = transaction.request.HTTPMethod;
    [rows addObject:requestMethodRow];

    if (transaction.cachedRequestBody.length > 0) {
        AVX512NetworkDetailRow *postBodySizeRow = [AVX512NetworkDetailRow new];
        postBodySizeRow.title = @"Request body size request for requesting Body Size";
        postBodySizeRow.detailText = [NSByteCountFormatter stringFromByteCount:transaction.cachedRequestBody.length countStyle:NSByteCountFormatterCountStyleBinary];
        [rows addObject:postBodySizeRow];

        AVX512NetworkDetailRow *postBodyRow = [AVX512NetworkDetailRow new];
        postBodyRow.title = @"Request Panel of the requesting party has";
        postBodyRow.detailText = @"Click to click on the View Views";
        postBodyRow.selectionFuture = ^UIViewController * () {
            // If it is possible to show the requesting body if you
            NSString *contentType = [transaction.request valueForHTTPHeaderField:@"Content-Type"];
            NSData *body = [self postBodyDataForTransaction:transaction];
            UIViewController *detailViewController = [self detailViewControllerForMIMEType:contentType data:body];
            if (detailViewController) {
                detailViewController.title = @"Request Panel of the requesting party has";
                return detailViewController;
            }

            // Unable to display request bodies could not show the requesting body
            return [AVX512Alert makeAlert:^(AVX512Alert *make) {
                if (!body) {
                    make.title(@"Empty empty, space-HTTPBody body of physical,");
                } else {
                    make.title(@"Could not view failed to check couldHTTPbody-based data for bodies of");
                    make.message(@"AVX512It does not apply to this withoutMIMEType type of request for a requesting body data Data Viewer: ");
                }
                
                make.message(contentType);
                make.button(@"Close").cancelStyle();
            }];
        };

        [rows addObject:postBodyRow];
    }

    NSString *statusCodeString = [AVX512Utility statusCodeStringFromURLResponse:transaction.response];
    if (statusCodeString.length > 0) {
        AVX512NetworkDetailRow *statusCodeRow = [AVX512NetworkDetailRow new];
        statusCodeRow.title = @"The status-state code for the";
        statusCodeRow.detailText = statusCodeString;
        [rows addObject:statusCodeRow];
    }

    if (transaction.error) {
        AVX512NetworkDetailRow *errorRow = [AVX512NetworkDetailRow new];
        errorRow.title = @"Error error bug wrong mistake";
        errorRow.detailText = transaction.error.localizedDescription;
        [rows addObject:errorRow];
    }

    AVX512NetworkDetailRow *responseBodyRow = [AVX512NetworkDetailRow new];
    responseBodyRow.title = @"Response response to the respond-response";
    NSData *responseData = [AVX512NetworkRecorder.defaultRecorder cachedResponseBodyForTransaction:transaction];
    if (responseData.length > 0) {
        responseBodyRow.detailText = @"Click to click on the View Views";

        // Avoiding long-term strong and robust references to the response data is avoided from being used too strongly for a prolonged period of time
        weakify(responseData)
        responseBodyRow.selectionFuture = ^UIViewController *() { strongify(responseData)

            // If it is possible to show, if can be
            NSString *contentType = transaction.response.MIMEType;
            if (responseData) {
                UIViewController *bodyDetails = [self detailViewControllerForMIMEType:contentType data:responseData];
                if (bodyDetails) {
                    bodyDetails.title = @"Response response responded, responding";
                    return bodyDetails;
                }
            }

            // Unable to display a response. Could not show an answer
            return [AVX512Alert makeAlert:^(AVX512Alert *make) {
                make.title(@"Could not failed to view the response reply");
                if (responseData) {
                    make.message(@"There are no content type of contents types for the substance: ").message(contentType);
                } else {
                    make.message(@"The response has been cleared of the cached clean-out");
                }
                make.button(@"OK is set to confirm").cancelStyle();
            }];
        };
    } else {
        BOOL emptyResponse = transaction.receivedDataLength == 0;
        responseBodyRow.detailText = emptyResponse ? @"Empty empty, space-" : @"Not not in the cache-in of a C";
    }

    [rows addObject:responseBodyRow];

    AVX512NetworkDetailRow *responseSizeRow = [AVX512NetworkDetailRow new];
    responseSizeRow.title = @"Response-As response size/";
    responseSizeRow.detailText = [NSByteCountFormatter stringFromByteCount:transaction.receivedDataLength countStyle:NSByteCountFormatterCountStyleBinary];
    [rows addObject:responseSizeRow];

    AVX512NetworkDetailRow *mimeTypeRow = [AVX512NetworkDetailRow new];
    mimeTypeRow.title = @"MIMEType of type type";
    mimeTypeRow.detailText = transaction.response.MIMEType;
    [rows addObject:mimeTypeRow];

    AVX512NetworkDetailRow *mechanismRow = [AVX512NetworkDetailRow new];
    mechanismRow.title = @"Mechanisms mechanisms and institutional mechanism";
    mechanismRow.detailText = transaction.requestMechanism;
    [rows addObject:mechanismRow];

    AVX512NetworkDetailRow *localStartTimeRow = [AVX512NetworkDetailRow new];
    localStartTimeRow.title = [NSString stringWithFormat:@"_ Start time start date starting (%@)", [NSTimeZone.localTimeZone abbreviationForDate:transaction.startTime]];
    localStartTimeRow.detailText = [NSDateFormatter avx512_stringFrom:transaction.startTime format:AVX512DateFormatVerbose];
    [rows addObject:localStartTimeRow];

    AVX512NetworkDetailRow *utcStartTimeRow = [AVX512NetworkDetailRow new];
    utcStartTimeRow.title = @"_ Start time start date starting (UTC)";
    utcStartTimeRow.detailText = [NSDateFormatter avx512_stringFrom:transaction.startTime format:AVX512DateFormatVerbose];
    [rows addObject:utcStartTimeRow];

    AVX512NetworkDetailRow *unixStartTime = [AVX512NetworkDetailRow new];
    unixStartTime.title = @"Unix_ Start time start date starting";
    unixStartTime.detailText = [NSString stringWithFormat:@"%f", [transaction.startTime timeIntervalSince1970]];
    [rows addObject:unixStartTime];

    AVX512NetworkDetailRow *durationRow = [AVX512NetworkDetailRow new];
    durationRow.title = @"Total total duration of the CC";
    durationRow.detailText = [AVX512Utility stringFromRequestDuration:transaction.duration];
    [rows addObject:durationRow];

    AVX512NetworkDetailRow *latencyRow = [AVX512NetworkDetailRow new];
    latencyRow.title = @"Delay delayed delay in the";
    latencyRow.detailText = [AVX512Utility stringFromRequestDuration:transaction.latency];
    [rows addObject:latencyRow];

    AVX512NetworkDetailSection *generalSection = [AVX512NetworkDetailSection new];
    generalSection.title = @"General general regular, conventional";
    generalSection.rows = rows;

    return generalSection;
}

+ (AVX512NetworkDetailSection *)requestHeadersSectionForTransaction:(AVX512HTTPTransaction *)transaction {
    AVX512NetworkDetailSection *requestHeadersSection = [AVX512NetworkDetailSection new];
    requestHeadersSection.title = @"Request to request the header of";
    requestHeadersSection.rows = [self networkDetailRowsFromDictionary:transaction.request.allHTTPHeaderFields];

    return requestHeadersSection;
}

+ (AVX512NetworkDetailSection *)postBodySectionForTransaction:(AVX512HTTPTransaction *)transaction {
    AVX512NetworkDetailSection *postBodySection = [AVX512NetworkDetailSection new];
    postBodySection.title = @"Request Body request body parameter argument for the";
    if (transaction.cachedRequestBody.length > 0) {
        NSString *contentType = [transaction.request valueForHTTPHeaderField:@"Content-Type"];
        if ([contentType hasPrefix:@"application/x-www-form-urlencoded"]) {
            NSData *body = [self postBodyDataForTransaction:transaction];
            NSString *bodyString = [[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding];
            postBodySection.rows = [self networkDetailRowsFromQueryItems:[AVX512Utility itemsFromQueryString:bodyString]];
        }
    }
    return postBodySection;
}

+ (AVX512NetworkDetailSection *)queryParametersSectionForTransaction:(AVX512HTTPTransaction *)transaction {
    NSArray<NSURLQueryItem *> *queries = [AVX512Utility itemsFromQueryString:transaction.request.URL.query];
    AVX512NetworkDetailSection *querySection = [AVX512NetworkDetailSection new];
    querySection.title = @"Qu queries query para parameter";
    querySection.rows = [self networkDetailRowsFromQueryItems:queries];

    return querySection;
}

+ (AVX512NetworkDetailSection *)responseHeadersSectionForTransaction:(AVX512HTTPTransaction *)transaction {
    AVX512NetworkDetailSection *responseHeadersSection = [AVX512NetworkDetailSection new];
    responseHeadersSection.title = @"Response to head-head of response";
    if ([transaction.response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)transaction.response;
        responseHeadersSection.rows = [self networkDetailRowsFromDictionary:httpResponse.allHeaderFields];
    }
    return responseHeadersSection;
}

+ (NSArray<AVX512NetworkDetailRow *> *)networkDetailRowsFromDictionary:(NSDictionary<NSString *, id> *)dictionary {
    NSMutableArray<AVX512NetworkDetailRow *> *rows = [NSMutableArray new];
    NSArray<NSString *> *sortedKeys = [dictionary.allKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    
    for (NSString *key in sortedKeys) {
        id value = dictionary[key];
        AVX512NetworkDetailRow *row = [AVX512NetworkDetailRow new];
        row.title = key;
        row.detailText = [value description];
        [rows addObject:row];
    }

    return rows.copy;
}

+ (NSArray<AVX512NetworkDetailRow *> *)networkDetailRowsFromQueryItems:(NSArray<NSURLQueryItem *> *)items {
    // Sort the items by name
    items = [items sortedArrayUsingComparator:^NSComparisonResult(NSURLQueryItem *item1, NSURLQueryItem *item2) {
        return [item1.name caseInsensitiveCompare:item2.name];
    }];

    NSMutableArray<AVX512NetworkDetailRow *> *rows = [NSMutableArray new];
    for (NSURLQueryItem *item in items) {
        AVX512NetworkDetailRow *row = [AVX512NetworkDetailRow new];
        row.title = item.name;
        row.detailText = item.value;
        [rows addObject:row];
    }

    return [rows copy];
}

+ (UIViewController *)detailViewControllerForMIMEType:(NSString *)mimeType data:(NSData *)data {
    if (!data) {
        return nil; // An alert will be presented in place of this screen
    }
    
    AVX512CustomContentViewerFuture makeCustomViewer = AVX512Manager.sharedManager.customContentTypeViewers[mimeType.lowercaseString];

    if (makeCustomViewer) {
        UIViewController *viewer = makeCustomViewer(data);

        if (viewer) {
            return viewer;
        }
    }

    // FIXME (RKO): Don't rely on UTF8 string encoding
    UIViewController *detailViewController = nil;
    if ([AVX512Utility isValidJSONData:data]) {
        NSString *prettyJSON = [AVX512Utility prettyJSONStringFromData:data];
        if (prettyJSON.length > 0) {
            detailViewController = [[AVX512WebViewController alloc] initWithText:prettyJSON];
        }
    } else if ([mimeType hasPrefix:@"image/"]) {
        UIImage *image = [UIImage imageWithData:data];
        detailViewController = [AVX512ImagePreviewViewController forImage:image];
    } else if ([mimeType isEqual:@"application/x-plist"]) {
        id propertyList = [NSPropertyListSerialization propertyListWithData:data options:0 format:NULL error:NULL];
        detailViewController = [[AVX512WebViewController alloc] initWithText:[propertyList description]];
    }

    // Fall back to trying to show the response as text
    if (!detailViewController) {
        NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (text.length > 0) {
            detailViewController = [[AVX512WebViewController alloc] initWithText:text];
        }
    }
    return detailViewController;
}

+ (NSData *)postBodyDataForTransaction:(AVX512HTTPTransaction *)transaction {
    NSData *bodyData = transaction.cachedRequestBody;
    if (bodyData.length > 0 && [AVX512Utility hasCompressedContentEncoding:transaction.request]) {
        bodyData = [AVX512Utility inflatedDataFromCompressedData:bodyData];
    }
    return bodyData;
}

@end
