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
		sp1	=	try! EEDWSubprocess.spawnWithExecutablePath("/bin/bash", arguments: ["/bin/bash", "-s"]);

		sp1!.standardOutput().readabilityHandler	=	{ h in
			print(NSString(data: h.availableData, encoding: NSUTF8StringEncoding)! as String)
		}
		sp1!.standardError().readabilityHandler	=	{ h in
			print(NSString(data: h.availableData, encoding: NSUTF8StringEncoding)! as String)
		}
//		sp1!.standardInput().writeData(("echo AAA; ehco; echo `pwd`; sleep 2; exit;\n" as NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
		sp1!.standardInput().writeData(("source ~/.profile; cd ~/; rm -rf ./testproj3; cargo new --bin testproj3; cd testproj3; cargo build --verbose; exit;\n" as NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
		print("...")

		try! sp1!.waitUntilExit()
		print("OK!")
	}

	func applicationWillTerminate(aNotification: NSNotification) {
		// Insert code here to tear down your application
	}


}

