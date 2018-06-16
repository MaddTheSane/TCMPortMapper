//
//  StatusImageFromMappingStatusValueTransformer.swift
//  PortMapSwift
//
//  Created by C.W. Betts on 6/16/18.
//

import Cocoa

class StatusImageFromMappingStatusValueTransformer: ValueTransformer {
	override class func transformedValueClass() -> AnyClass {
		return NSImage.self
	}
	
	override func transformedValue(_ value: Any?) -> Any? {
		guard let val2 = value as? Int else {
			return NSImage(named: .statusNone)
		}
		switch val2 {
		case 2:
			return NSImage(named: .statusAvailable)
			
		case 1:
			return NSImage(named: .statusPartiallyAvailable)

		default:
			return NSImage(named: .statusUnavailable)
		}
	}
}

class PortStringFromPublicPortValueTransformer : ValueTransformer {
	
}

class ReplacedStringFromPortMappingReferenceStringValueTransformer : ValueTransformer {
	
}
