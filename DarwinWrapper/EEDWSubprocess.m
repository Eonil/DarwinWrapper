//
//  EEDWSubprocess.m
//  DarwinWrapper
//
//  Created by Hoon H. on 2015/11/21.
//  Copyright © 2015 Eonil. All rights reserved.
//

#import "EEDWSubprocess.h"
#import <spawn.h>

@implementation EEDWSubprocess {
	pid_t			_subproc_pid;
	NSFileHandle*		_subproc_stdin;
	NSFileHandle*		_subproc_stdout;
	NSFileHandle*		_subproc_stderr;
}
+ (instancetype)spawnWithExecutablePath:(NSString *)executablePath arguments:(NSArray<NSString *> *)arguments environment:(NSArray<NSString *> *)environment error:(NSError *__autoreleasing *)error {
	char const*	path1;
	char const*	args1[arguments.count];
	char const*	envs1[environment.count];
	int		stdin_pipe[2];
	int		stdout_pipe[2];
	int		stderr_pipe[2];

	path1	=	executablePath.UTF8String;
	for (int i=0; i<arguments.count; i++) {
		NSString*	arg	=	arguments[i];
		char const*	arg1	=	arg.UTF8String;
		args1[i]		=	arg1;
	}
	for (int i=0; i<environment.count; i++) {
		NSString*	env	=	environment[i];
		char const*	env1	=	env.UTF8String;
		envs1[i]		=	env1;
	}
	pipe(stdin_pipe);
	pipe(stdout_pipe);
	pipe(stderr_pipe);

	pid_t pid;
	posix_spawn_file_actions_t file_actions;
	posix_spawn_file_actions_init(&file_actions);
	posix_spawn_file_actions_addclose(&file_actions, stdin_pipe[1]);
	posix_spawn_file_actions_addclose(&file_actions, stdout_pipe[0]);
	posix_spawn_file_actions_addclose(&file_actions, stderr_pipe[0]);
	posix_spawn_file_actions_adddup2(&file_actions, stdin_pipe[0], STDIN_FILENO);
	posix_spawn_file_actions_adddup2(&file_actions, stdout_pipe[1], STDOUT_FILENO);
	posix_spawn_file_actions_adddup2(&file_actions, stderr_pipe[1], STDERR_FILENO);
	posix_spawnattr_t attr;
	posix_spawnattr_init(&attr);
	int ret = posix_spawn(&pid, path1, &file_actions, &attr, (char *const*)args1, (char *const*)envs1);
	posix_spawnattr_destroy(attr);
	posix_spawn_file_actions_destroy(&file_actions);

	if (ret == 0) {
		// OK.
		close(stdin_pipe[0]);
		close(stdout_pipe[1]);
		close(stderr_pipe[1]);
		EEDWSubprocess*	p	=	[[self alloc] init];
		p->_subproc_pid		=	pid;
		return		p;
	}
	else {
		// Error.
		char const*	s	=	strerror(ret);
		NSString*	s1	=	[[NSString alloc] initWithUTF8String:s];
		NSError*	e	=	[[NSError alloc] initWithDomain:NSPOSIXErrorDomain code:ret userInfo:@{NSLocalizedDescriptionKey: s1}];
		if (error != NULL) {
			*error			=	e;
		}
		return		nil;
	}

}
- (NSFileHandle *)standardInput {
	return	_subproc_stdin;
}
- (NSFileHandle *)standardOutput {
	return	_subproc_stdout;
}
- (NSFileHandle *)standardError {
	return	_subproc_stderr;
}
- (BOOL)waitUntilExitWithError:(NSError *__autoreleasing *)error {
RESTART:

	NSAssert(_subproc_pid > 0, @"Subprocess PID number to wait for must be larger than 0.");
	int	options	=	0;
	int	ret	=	waitpid(_subproc_pid, NULL, options);
	if (ret == _subproc_pid) {
		// OK.
		// Should exit early. We sholdn't check for another error.
		return 	YES;
	}
	if (ret == -1) {
		// No child process.
		int		e	=	errno;
		if (e == EINTR) {
			// https://sourceware.org/bugzilla/show_bug.cgi?id=8551
			// https://github.com/norahiko/runsync/pull/3
			goto RESTART;
		}
		char const*	s	=	strerror(e);
		NSString*	s1	=	[[NSString alloc] initWithUTF8String:s];
		NSError*	e1	=	[[NSError alloc] initWithDomain:NSPOSIXErrorDomain code:e userInfo:@{NSLocalizedDescriptionKey: s1}];
		*error			=	e1;
		return	NO;
	}

	NSAssert(errno == 0, @"");
	return 	YES;
}
@end











