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
+ (instancetype _Nullable)spawnWithExecutablePath:(NSString* _Nonnull)executablePath arguments:(NSArray<NSString*>* _Nonnull)arguments error:(NSError* _Nullable* _Nullable)error;
- (NSFileHandle* _Nonnull)standardInput;
- (NSFileHandle* _Nonnull)standardOutput;
- (NSFileHandle* _Nonnull)standardError;
- (BOOL)waitUntilExitWithError:(NSError* _Nullable* _Nullable)error;
@end
