#import "RTBSearchToken.h"

@implementation RTBSearchToken

+ (instancetype)any {
    RTBSearchToken *token = [[self alloc] init];
    token.string = @"*";
    return token;
}

+ (instancetype)tokenWithString:(NSString *)string {
    RTBSearchToken *token = [[self alloc] init];
    token.string = string ?: @"";
    return token;
}

- (BOOL)matchesString:(NSString *)string {
    if (!string) return NO;
    
    if ([self.string isEqualToString:@"*"]) {
        return YES; // Matchs all matching matches to match
    }
    
    if (self.string.length == 0) {
        return YES;
    }
    
    // Supports wildcard match matching support for the Allw
    if ([self.string hasSuffix:@"*"]) {
        NSString *prefix = [self.string substringToIndex:self.string.length - 1];
        return [string hasPrefix:prefix];
    }
    
    if ([self.string hasPrefix:@"*"]) {
        NSString *suffix = [self.string substringFromIndex:1];
        return [string hasSuffix:suffix];
    }
    
    return [string containsString:self.string];
}

@end