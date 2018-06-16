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

var portStringFromPublicPort: NSValueTransformerName {
	return NSValueTransformerName(rawValue: "TCMPortStringFromPublicPort")
}

var replacedStringFromPortMappingReferenceString: NSValueTransformerName {
	return NSValueTransformerName(rawValue: "TCMReplacedStringFromPortMappingReferenceString")
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
		ValueTransformer.setValueTransformer(PortStringFromPublicPortValueTransformer(), forName: portStringFromPublicPort)
		ValueTransformer.setValueTransformer(ReplacedStringFromPortMappingReferenceStringValueTransformer(), forName: replacedStringFromPortMappingReferenceString)
	}

	func applicationWillFinishLaunching(_ notification: Notification) {
		window.setAutorecalculatesContentBorderThickness(false, for: .maxY)
		window.setContentBorderThickness(73, for: .maxY)
		
		let pm = TCMPortMapper.shared
		let center = NotificationCenter.default
		center.addObserver(self, selector: #selector(AppDelegate.portMapperExternalIPAddressDidChange(_:)), name: .TCMPortMapperExternalIPAddressDidChange, object: pm)
		center.addObserver(self, selector: #selector(AppDelegate.portMapperWillSearchForRouter(_:)), name: .TCMPortMapperWillStartSearchForRouter, object: pm)
		center.addObserver(self, selector: #selector(AppDelegate.portMapperDidFindRouter(_:)), name: .TCMPortMapperDidFinishSearchForRouter, object: pm)
		center.addObserver(self, selector: #selector(AppDelegate.startProgressIndicator(_:)), name: .TCMPortMapperDidStartWork, object: pm)
		center.addObserver(self, selector: #selector(AppDelegate.stopProgressIndicator(_:)), name: .TCMPortMapperDidFinishWork, object: pm)
		
		if let mappings = UserDefaults.standard.array(forKey: "StoredMappings") as? [[String: Any]] {
			for mappingRep in mappings {
				let mapping = TCMPortMapping(dictionaryRepresentation: mappingRep)
				mappingsArrayController.addObject(mapping)
				mapping.addObserver(self, forKeyPath: "userInfo.active", options: [], context: nil)
				if ((mapping.userInfo as! NSDictionary).object(forKey: "active")) as! Bool {
					pm.addPortMapping(mapping)
				}
			}
		}
		pm.start()
		
		center.addObserver(self, selector: #selector(AppDelegate.portMapperDidReceiveUPNPMappingTable(_:)), name: .TCMPortMapperDidReceiveUPNPMappingTable, object: pm)

		if let url = Bundle.main.url(forResource: "Presets", withExtension: "plist"),
		let array = NSArray(contentsOf: url) as? [[String: Any]] {
			for preset in array {
				if let title = preset["mappingTitle"] as? String {
					addPresetPopupButton.addItem(withTitle: title)
					addPresetPopupButton.lastItem?.representedObject = preset
				}
			}
		}
		
		// set the version
		if let infoDictionary = Bundle.main.infoDictionary {
			var versionString = aboutVersionLineTextField.stringValue
			if let shortVers = infoDictionary["CFBundleShortVersionString"] as? String {
				versionString += " "
				versionString += shortVers
			}
			if let shortVers = infoDictionary["CFBundleVersion"] as? String {
				versionString += " (\(shortVers))"
			}
			
			aboutVersionLineTextField.stringValue = versionString
		}
	}
	
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		// Insert code here to initialize your application
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		writeMappingDefaults()
		TCMPortMapper.shared.stopBlocking()
	}

	private func writeMappingDefaults() {
		let mappings = mappingsArrayController.arrangedObjects as! NSArray as! [TCMPortMapping]
		var mappingsToStore = [[String: Any]]()
		for mapping in mappings {
			mappingsToStore.append(mapping.dictionaryRepresentation)
		}
		UserDefaults.standard.set(mappingsToStore, forKey: "StoredMappings")
	}
	
	@objc func portMapperExternalIPAddressDidChange(_ aNotification: Notification?) {
		let pm = TCMPortMapper.shared
		if pm.isRunning {
			if pm.externalIPAddress != nil {
				currentIPTextField.objectValue = externalIPAddressString
			}
		} else {
			currentIPTextField.stringValue = NSLocalizedString("Stopped", comment: "")
		}
		updateTagLine()
	}
	
	@objc func portMapperWillSearchForRouter(_ aNotification: Notification) {
		refreshButton.isEnabled = false
		currentIPTextField.stringValue = NSLocalizedString("Searching...", comment: "")
	}
	
	@objc func portMapperDidFindRouter(_ aNotification: Notification) {
		refreshButton.isEnabled = true
		let pm = TCMPortMapper.shared
		if pm.externalIPAddress != nil {
			currentIPTextField.objectValue = externalIPAddressString
		} else {
			if pm.routerIPAddress != nil {
				currentIPTextField.stringValue = NSLocalizedString("Router incompatible.", comment: "")
				showInstructionalPanel(self)
			} else {
				currentIPTextField.stringValue = NSLocalizedString("Can't find router.", comment: "")
			}
		}
		updateTagLine()
	}
	
	func updateTagLine() {
		let pm = TCMPortMapper.shared
		if pm.isRunning {
			if pm.externalIPAddress != nil {
				taglineTextField.stringValue = "\(pm.mappingProtocol.rawValue) - \(pm.routerName!) - \(pm.routerIPAddress!)"
			} else {
				taglineTextField.stringValue = "\(pm.mappingProtocol.rawValue) - \(pm.routerName!) - \(pm.routerIPAddress ?? NSLocalizedString("No Router", comment: ""))"
			}
		} else {
			taglineTextField.stringValue = NSLocalizedString("Stopped", comment: "")
		}
	}
	
	var externalIPAddressString: String {
		guard let externalIPAddress = TCMPortMapper.shared.externalIPAddress, externalIPAddress != "0.0.0.0" else {
			return NSLocalizedString("No external Address.", comment: "")
		}
		return externalIPAddress
	}
	
	@objc func startProgressIndicator(_ aNotification: Notification) {
		globalProgressIndicator.startAnimation(self)
		showUPNPMappingTableButton.isEnabled = false
		UPNPTabItemProgressIndicator.startAnimation(self)
	}
	
	@objc func stopProgressIndicator(_ aNotification: Notification) {
		globalProgressIndicator.stopAnimation(self)
		UPNPTabItemProgressIndicator.stopAnimation(self)
		showUPNPMappingTableButton.isEnabled = TCMPortMapper.shared.mappingProtocol == .UPNP
		if let localIPAddress = TCMPortMapper.shared.localIPAddress {
			localIPAddressTextField.stringValue = localIPAddress
			window.title = String(format: NSLocalizedString("Port Map on %@", comment: ""), localIPAddress)
		} else {
			window.title = "Port Map"
			localIPAddressTextField.stringValue = ""
		}
	}

	
	@IBAction open func togglePortMapper(_ aSender: NSButton?) {
		if aSender?.state == .on {
			TCMPortMapper.shared.start()
		} else {
			TCMPortMapper.shared.stop()
			portMapperExternalIPAddressDidChange(nil)
		}
	}
	
	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		if let obj = object as? TCMPortMapping {
			if (obj.userInfo as! NSDictionary).value(forKey: "active") as! Bool {
				TCMPortMapper.shared.addPortMapping(obj)
			} else {
				TCMPortMapper.shared.removePortMapping(obj)
			}
			writeMappingDefaults()

		}
	}
	
	@IBAction open func refresh(_ aSender: Any?) {
		TCMPortMapper.shared.refresh()
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
		aboutWindow.center()
		aboutWindow.makeKeyAndOrderFront(self)
	}
	
	@IBAction open func requestUPNPMappingTable(_ aSender: Any?) {
		
	}
	
	@objc func portMapperDidReceiveUPNPMappingTable(_ aNotification: Notification) {
		
	}

	@IBAction open func requestUPNPMappingTableRemoveMappings(_ aSender: Any?) {
		
	}
	
	@IBAction open func requestUPNPMappingTableOKSheet(_ aSender: Any?) {
		
	}
	
	override func controlTextDidChange(_ obj: Notification) {
		
	}
	
	//- (void)controlTextDidChange:(NSNotification *)aNotification
	
}
