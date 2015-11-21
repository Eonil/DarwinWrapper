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
	int			_stdin_pipe[2];
	int			_stdout_pipe[2];
	int			_stderr_pipe[2];
	pid_t			_subproc_pid;
	NSFileHandle*		_subproc_stdin;
	NSFileHandle*		_subproc_stdout;
	NSFileHandle*		_subproc_stderr;
}
+ (instancetype)spawnWithExecutablePath:(NSString *)executablePath arguments:(NSArray<NSString *> *)arguments error:(NSError *__autoreleasing  _Nullable *)error {
	char const*	path1;
	char const*	args1[arguments.count];
	int		stdin_pipe[2];
	int		stdout_pipe[2];
	int		stderr_pipe[2];

	path1	=	executablePath.UTF8String;
	for (int i=0; i<arguments.count; i++) {
		NSString*	arg	=	arguments[i];
		char const*	arg1	=	arg.UTF8String;
		args1[i]		=	arg1;
	}

	pipe(stdin_pipe);
	pipe(stdout_pipe);
	pipe(stderr_pipe);

	pid_t	pid	=	fork();

	if (pid == 0) {
		// OK and we're in child process.
		close(stdin_pipe[1]);
		close(stdout_pipe[0]);
		close(stderr_pipe[0]);
		dup2(stdin_pipe[0], STDIN_FILENO);
		dup2(stdout_pipe[1], STDOUT_FILENO);
		dup2(stderr_pipe[1], STDERR_FILENO);

		int	ret	=	execv(path1, (char * const *)args1);
		NSAssert(ret == -1, @"If returned, the returned value must be -1.");

		int		e	=	errno;
		perror(NULL);
		exit(e);
	}
	if (pid == -1) {
		// Error and we're in parent process.
		int		e	=	errno;
		char const*	s	=	strerror(e);
		NSString*	s1	=	[[NSString alloc] initWithUTF8String:s];
		NSError*	e1	=	[[NSError alloc] initWithDomain:NSPOSIXErrorDomain code:e userInfo:@{NSLocalizedDescriptionKey: s1}];
		if (error != NULL) {
			*error			=	e1;
		}
		return	nil;
	}

	// OK and we're in parent process.
	close(stdin_pipe[0]);
	close(stdout_pipe[1]);
	close(stderr_pipe[1]);

	EEDWSubprocess*	p	=	[[EEDWSubprocess alloc] init];
	p->_stdin_pipe[0]	=	stdin_pipe[0];
	p->_stdin_pipe[1]	=	stdin_pipe[1];
	p->_stdout_pipe[0]	=	stdout_pipe[0];
	p->_stdout_pipe[1]	=	stdout_pipe[1];
	p->_stderr_pipe[0]	=	stderr_pipe[0];
	p->_stderr_pipe[1]	=	stderr_pipe[1];
	p->_subproc_pid		=	pid;
	p->_subproc_stdin	=	[[NSFileHandle alloc] initWithFileDescriptor:stdin_pipe[1]];
	p->_subproc_stdout	=	[[NSFileHandle alloc] initWithFileDescriptor:stdout_pipe[0]];
	p->_subproc_stderr	=	[[NSFileHandle alloc] initWithFileDescriptor:stderr_pipe[0]];
	return	p;
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











