//
//  EEDWSubprocess.h
//  DarwinWrapper
//
//  Created by Hoon H. on 2015/11/21.
//  Copyright © 2015 Eonil. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 `NSTask` running in Xcode debugging context crashes `rustc` and `cargo`.
 This class just replaces `NSTask` to avoid the issue by wrapping `posix_spawn`.
 */
@interface EEDWSubprocess : NSObject
+ (instancetype)spawnWithExecutablePath:(NSString*)executablePath arguments:(NSArray<NSString*>*)arguments environment:(NSArray<NSString*>*)environment error:(NSError**)error;
//- (instancetype)initWithExecutablePath:(NSString*)executablePath arguments:(NSArray<NSString*>*)arguments;
- (NSFileHandle*)standardInput;
- (NSFileHandle*)standardOutput;
- (NSFileHandle*)standardError;
- (BOOL)waitUntilExitWithError:(NSError**)error;
@end
