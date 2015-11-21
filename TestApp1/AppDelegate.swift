//
//  AppDelegate.swift
//  TestApp1
//
//  Created by Hoon H. on 2015/11/21.
//  Copyright © 2015 Eonil. All rights reserved.
//

import Cocoa
import DarwinWrapper

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

	@IBOutlet weak var window: NSWindow!

	var sp1	:	EEDWSubprocess?

	func applicationDidFinishLaunching(aNotification: NSNotification) {
		sp1	=	try! EEDWSubprocess.spawnWithExecutablePath("/bin/bash", arguments: ["/bin/bash", "-c", "echo AAA; sleep 2;"], environment: []);
		print("...")

		try! sp1!.waitUntilExit()
		print("OK!")
	}

	func applicationWillTerminate(aNotification: NSNotification) {
		// Insert code here to tear down your application
	}


}

