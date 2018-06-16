//
//  PortStringFromPublicPortValueTransformer.swift
//  PortMapSwift
//
//  Created by C.W. Betts on 6/16/18.
//

import Foundation
import TCMPortMapper

class PortStringFromPublicPortValueTransformer : ValueTransformer {
	override class func transformedValueClass() -> AnyClass {
		return NSString.self
	}
	
	override func transformedValue(_ value: Any?) -> Any? {
		if let num = value as? Int {
			if num == 0 {
				return NSLocalizedString("unmapped", comment: "")
			}
			
			return "\(num)"
		} else {
			return "NaN"
		}
	}
}

class ReplacedStringFromPortMappingReferenceStringValueTransformer : ValueTransformer {
	override class func transformedValueClass() -> AnyClass {
		return NSString.self
	}
	
	override func transformedValue(_ value1: Any?) -> Any? {
		var value = value1
		if let newValue2 = (value as AnyObject?)?.lastObject {
			value = newValue2
		}
		if let value = value as? TCMPortMapping, value.mappingStatus == .mapped, TCMPortMapper.shared.externalIPAddress != nil {
			if var string: String = (value.userInfo as? NSDictionary)?.object(forKey: "referenceString") as? String {
				if let ipRange = string.range(of: "[IP]") {
					string.replaceSubrange(ipRange, with: TCMPortMapper.shared.externalIPAddress!)
				}
				if let portRange = string.range(of: "[PORT]") {
					string.replaceSubrange(portRange, with: "\(value.externalPort)")
				}
				return string
			} else {
				return nil
			}
		}
		
		return ""
	}
}
