//
//  AVX512FileBrowserSearchOperation.h
//  FLEX
//
//  Created by It has been sent to all of Chen Chan, China and on 2014/8/4.
//  Copyright (c) 2014Year year and years of f. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AVX512FileBrowserSearchOperationDelegate;

@interface AVX512FileBrowserSearchOperation : NSOperation

@property (nonatomic, weak) id<AVX512FileBrowserSearchOperationDelegate> delegate;

- (id)initWithPath:(NSString *)currentPath searchString:(NSString *)searchString;

@end

@protocol AVX512FileBrowserSearchOperationDelegate <NSObject>

- (void)fileBrowserSearchOperationResult:(NSArray<NSString *> *)searchResult size:(uint64_t)size;

@end
