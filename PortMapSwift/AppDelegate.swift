//
//  AppDelegate.swift
//  PortMapSwift
//
//  Created by C.W. Betts on 6/16/18.
//

import Cocoa
import TCMPortMapper

var statusImageFromMappingStatus: NSValueTransformerName {
	return NSValueTransformerName(rawValue: "TCMStatusImageFromMappingStatus")
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

	@IBOutlet weak var window: NSWindow!
	@IBOutlet weak var currentIPTextField: NSTextField!
	@IBOutlet weak var taglineTextField: NSTextField!
	@IBOutlet weak var portMappingsTableView: NSTableView!
	@IBOutlet weak var mappingsArrayController: NSArrayController!
	@IBOutlet weak var globalProgressIndicator: NSProgressIndicator!
	@IBOutlet weak var refreshButton: NSButton!
	@IBOutlet weak var invalidLocalPortView: NSView!
	@IBOutlet weak var invalidDesiredPortView: NSView!
	@IBOutlet weak var replacedReferenceStringTextField: NSTextField!
	
	@IBOutlet weak var addSheetPanel: NSWindow!
	@IBOutlet weak var addDescriptionField: NSTextField!
	@IBOutlet weak var addLocalPortField: NSTextField!
	@IBOutlet weak var addDesiredField: NSTextField!
	@IBOutlet weak var addProtocolTCPButton: NSButton!
	@IBOutlet weak var addProtocolUDPButton: NSButton!
	@IBOutlet weak var addPresetPopupButton: NSPopUpButton!
	@IBOutlet weak var addReferenceStringField: NSTextField!
	
	@IBOutlet weak var showUPNPMappingListWindow: NSWindow!
	@IBOutlet weak var UPNPMappingListArrayController: NSArrayController!
	@IBOutlet weak var localIPAddressTextField: NSTextField!
	@IBOutlet weak var showUPNPMappingTableButton: NSButton!
	@IBOutlet weak var upnpMappingListTabItem: NSTabViewItem!
	@IBOutlet weak var progressIndictatorTabItem: NSTabViewItem!
	@IBOutlet weak var UPNPTabItemProgressIndicator: NSProgressIndicator!
	
	@IBOutlet weak var instructionalSheetPanel: NSWindow!
	@IBOutlet weak var dontShowInstructionsAgainButton: NSButton!
	@IBOutlet weak var aboutWindow: NSWindow!
	
	@IBOutlet weak var aboutVersionLineTextField: NSTextField!
	
	override init() {
		super.init()
		ValueTransformer.setValueTransformer(StatusImageFromMappingStatusValueTransformer(), forName: statusImageFromMappingStatus)
	}

	func applicationWillFinishLaunching(_ notification: Notification) {
		
	}
	
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		// Insert code here to initialize your application
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}

	@IBAction open func togglePortMapper(_ aSender: Any?) {
		
	}
	
	
	@IBAction open func refresh(_ aSender: Any?) {
		
	}
	
	@IBAction open func addMapping(_ aSender: Any?) {
		
	}
	
	@IBAction open func removeMapping(_ aSender: Any?) {
		
	}
	
	@IBAction open func addMappingEndSheet(_ aSender: Any?) {
		
	}
	
	@IBAction open func addMappingCancelSheet(_ aSender: Any?) {
		
	}
	
	@IBAction open func choosePreset(_ aSender: Any?) {
		
	}
	
	@IBAction open func showInstructionalPanel(_ aSender: Any?) {
		
	}
	
	@IBAction open func endInstructionalSheet(_ aSender: Any?) {
		
	}
	
	
	@IBAction open func gotoPortMapHomepage(_ aSender: Any?) {
		
	}
	
	@IBAction open func gotoTCMPortMapperSources(_ aSender: Any?) {
		
	}
	
	@IBAction open func reportABug(_ aSender: Any?) {
		
	}
	
	@IBAction open func showReleaseNotes(_ aSender: Any?) {
		
	}
	
	
	@IBAction open func showAbout(_ aSender: Any?) {
		
	}
	
	
	@IBAction open func requestUPNPMappingTable(_ aSender: Any?) {
		
	}
	
	@IBAction open func requestUPNPMappingTableRemoveMappings(_ aSender: Any?) {
		
	}
	
	@IBAction open func requestUPNPMappingTableOKSheet(_ aSender: Any?) {
		
	}
	
	private func writeMappingDefaults() {
		let mappings = mappingsArrayController.arrangedObjects as! NSArray as! [TCMPortMapping]
		var mappingsToStore = [[String: Any]]()
		for mapping in mappings {
			mappingsToStore.append(mapping.dictionaryRepresentation)
		}
		UserDefaults.standard.set(mappingsToStore, forKey: "StoredMappings")
	}
}

