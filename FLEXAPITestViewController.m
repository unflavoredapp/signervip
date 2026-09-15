#import "FLEXAPITestViewController.h"

@interface AVX512APITestViewController () <UITextViewDelegate>
@property (nonatomic, strong) UITextView *urlTextView;
@property (nonatomic, strong) UISegmentedControl *methodSegment;
@property (nonatomic, strong) UITextView *headersTextView;
@property (nonatomic, strong) UITextView *bodyTextView;
@property (nonatomic, strong) UITextView *responseTextView;
@property (nonatomic, strong) UIButton *sendButton;
@end

@implementation AVX512APITestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"APITest test testing tests to";
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    
    [self setupUI];
}

- (void)setupUI {
    // URLEnter Input Entry entry input
    UILabel *urlLabel = [[UILabel alloc] init];
    urlLabel.text = @"URL:";
    urlLabel.font = [UIFont boldSystemFontOfSize:16];
    
    self.urlTextView = [[UITextView alloc] init];
    self.urlTextView.font = [UIFont systemFontOfSize:14];
    self.urlTextView.layer.borderWidth = 1;
    self.urlTextView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.urlTextView.layer.cornerRadius = 8;
    self.urlTextView.text = @"https://httpbin.org/json";
    
    // HTTPThe method selection choice of the methodological
    UILabel *methodLabel = [[UILabel alloc] init];
    methodLabel.text = @"methodological approach methodology and methodologies:";
    methodLabel.font = [UIFont boldSystemFontOfSize:16];
    
    self.methodSegment = [[UISegmentedControl alloc] initWithItems:@[@"GET", @"POST", @"PUT", @"DELETE"]];
    self.methodSegment.selectedSegmentIndex = 0;
    
    // Request to request the header of
    UILabel *headersLabel = [[UILabel alloc] init];
    headersLabel.text = @"Request to request the header of (JSONFormat format of the tab):";
    headersLabel.font = [UIFont boldSystemFontOfSize:16];
    
    self.headersTextView = [[UITextView alloc] init];
    self.headersTextView.font = [UIFont systemFontOfSize:14];
    self.headersTextView.layer.borderWidth = 1;
    self.headersTextView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.headersTextView.layer.cornerRadius = 8;
    self.headersTextView.text = @"{\n  \"Content-Type\": \"application/json\"\n}";
    
    // Request Panel of the requesting party has
    UILabel *bodyLabel = [[UILabel alloc] init];
    bodyLabel.text = @"Request Panel of the requesting party has:";
    bodyLabel.font = [UIFont boldSystemFontOfSize:16];
    
    self.bodyTextView = [[UITextView alloc] init];
    self.bodyTextView.font = [UIFont systemFontOfSize:14];
    self.bodyTextView.layer.borderWidth = 1;
    self.bodyTextView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.bodyTextView.layer.cornerRadius = 8;
    self.bodyTextView.text = @"{\n  \"test\": \"data\"\n}";
    
    // To send the sent button to sending
    self.sendButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.sendButton setTitle:@"Send Request sent request to send requests" forState:UIControlStateNormal];
    self.sendButton.backgroundColor = [UIColor systemBlueColor];
    [self.sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.sendButton.layer.cornerRadius = 8;
    [self.sendButton addTarget:self action:@selector(sendRequest) forControlEvents:UIControlEventTouchUpInside];
    
    // Response to outcome response, responding results
    UILabel *responseLabel = [[UILabel alloc] init];
    responseLabel.text = @"Response to outcome response, responding results:";
    responseLabel.font = [UIFont boldSystemFontOfSize:16];
    
    self.responseTextView = [[UITextView alloc] init];
    self.responseTextView.font = [UIFont fontWithName:@"Courier" size:12];
    self.responseTextView.layer.borderWidth = 1;
    self.responseTextView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.responseTextView.layer.cornerRadius = 8;
    self.responseTextView.editable = NO;
    self.responseTextView.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0];
    
    // Creates the creation of a scroll view to create rolling views and stack
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:@[
        urlLabel, self.urlTextView,
        methodLabel, self.methodSegment,
        headersLabel, self.headersTextView,
        bodyLabel, self.bodyTextView,
        self.sendButton,
        responseLabel, self.responseTextView
    ]];
    
    stackView.axis = UILayoutConstraintAxisVertical;
    stackView.spacing = 8;
    
    [scrollView addSubview:stackView];
    [self.view addSubview:scrollView];
    
    // Binding binding and bound to
    scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    stackView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [NSLayoutConstraint activateConstraints:@[
        [scrollView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [scrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        
        [stackView.topAnchor constraintEqualToAnchor:scrollView.topAnchor constant:16],
        [stackView.leadingAnchor constraintEqualToAnchor:scrollView.leadingAnchor constant:16],
        [stackView.trailingAnchor constraintEqualToAnchor:scrollView.trailingAnchor constant:-16],
        [stackView.bottomAnchor constraintEqualToAnchor:scrollView.bottomAnchor constant:-16],
        [stackView.widthAnchor constraintEqualToAnchor:scrollView.widthAnchor constant:-32],
        
        [self.urlTextView.heightAnchor constraintEqualToConstant:60],
        [self.headersTextView.heightAnchor constraintEqualToConstant:80],
        [self.bodyTextView.heightAnchor constraintEqualToConstant:100],
        [self.sendButton.heightAnchor constraintEqualToConstant:44],
        [self.responseTextView.heightAnchor constraintEqualToConstant:200]
    ]];
}

- (void)sendRequest {
    // ✅ Repair restoration: The correct method is used to call in the right way
    NSString *urlString = [self.urlTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (urlString.length == 0) {
        [self showAlert:@"Please enter into the inputURL"];
        return;
    }
    
    NSURL *url = [NSURL URLWithString:urlString];
    if (!url) {
        [self showAlert:@"URLThis format error-form Error Format"];
        return;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    // Set the setting of aHTTPmethodological approach methodology and methodologies
    NSString *method = [self.methodSegment titleForSegmentAtIndex:self.methodSegment.selectedSegmentIndex];
    request.HTTPMethod = method;
    
    // Sets the request to set setting settings
    // ✅ Repair restoration: The correct method is used to call in the right way
    NSString *headersString = [self.headersTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (headersString.length > 0) {
        NSError *error;
        NSDictionary *headers = [NSJSONSerialization JSONObjectWithData:[headersString dataUsingEncoding:NSUTF8StringEncoding]
                                                               options:0
                                                                 error:&error];
        if (headers && [headers isKindOfClass:[NSDictionary class]]) {
            for (NSString *key in headers.allKeys) {
                [request setValue:headers[key] forHTTPHeaderField:key];
            }
        } else if (error) {
            [self showAlert:[NSString stringWithFormat:@"Request to request the header ofJSONThis format error-form Error Format: %@", error.localizedDescription]];
            return;
        }
    }
    
    // Sets the settingup request body to
    // ✅ Repair restoration: The correct method is used to call in the right way
    NSString *bodyString = [self.bodyTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (bodyString.length > 0 && ![method isEqualToString:@"GET"]) {
        request.HTTPBody = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    // Send Request sent request to send requests
    self.sendButton.enabled = NO;
    [self.sendButton setTitle:@"Sending is sending through send-..." forState:UIControlStateNormal];
    self.responseTextView.text = @"Request is sending a request to be sent...";
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.sendButton.enabled = YES;
            [self.sendButton setTitle:@"Send Request sent request to send requests" forState:UIControlStateNormal];
            
            if (error) {
                self.responseTextView.text = [NSString stringWithFormat:@"Request failed failure to Failed request::\n%@", error.localizedDescription];
            } else {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                NSString *responseString = @"";
                
                if (data) {
                    responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    
                    // Try trying to try tried formatting inJSON
                    NSError *jsonError;
                    id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                    if (jsonObject && !jsonError) {
                        NSData *formattedData = [NSJSONSerialization dataWithJSONObject:jsonObject 
                                                                               options:NSJSONWritingPrettyPrinted 
                                                                                 error:nil];
                        if (formattedData) {
                            responseString = [[NSString alloc] initWithData:formattedData encoding:NSUTF8StringEncoding];
                        }
                    }
                }
                
                self.responseTextView.text = [NSString stringWithFormat:@"The status-state code for the: %ld\n\nResponse to content-response response,:\n%@", 
                                            (long)httpResponse.statusCode, 
                                            responseString ?: @"(No response-responsive data for no)"];
            }
        });
    }];
    
    [task resume];
}

- (void)showAlert:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"A reminder to a point" 
                                                                   message:message 
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK is set to confirm" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end