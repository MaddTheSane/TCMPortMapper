//
//  TCMPortMappingAdditions.swift
//  PortMapSwift
//
//  Created by C.W. Betts on 6/16/18.
//

import Foundation
import TCMPortMapper

private let userInfoMapKey = "userInfo"
private let privatePortMapKey = "privatePort"
private let desiredPublicPortMapKey = "desiredPublicPort"
private let transportProtocolMapKey = "transportProtocol"

extension TCMPortMapping {
	convenience init(dictionaryRepresentation dr: [String: Any]) {
		var newLPort: UInt16 = 0
		if let newLPort2 = dr[privatePortMapKey] as? UInt16 {
			newLPort = newLPort2
		} else if let newLPort3 = dr[privatePortMapKey] as? Int {
			newLPort = UInt16(truncatingIfNeeded: newLPort3)
		}
		var newDPort: UInt16 = 0
		if let newLPort2 = dr[desiredPublicPortMapKey] as? UInt16 {
			newDPort = newLPort2
		} else if let newLPort3 = dr[desiredPublicPortMapKey] as? Int {
			newDPort = UInt16(truncatingIfNeeded: newLPort3)
		}
		var usrInfo = dr[userInfoMapKey]
		if usrInfo is NSNull {
			usrInfo = nil
		}
		let theProtocol: TCMPortMappingTransportProtocol? = {
			guard let prot2 = dr[transportProtocolMapKey] else {
				return nil
			}
			if let prot3 = prot2 as? TCMPortMappingTransportProtocol {
				return prot3
			}
			if let prot3 = prot2 as? TCMPortMappingTransportProtocol.RawValue {
				return TCMPortMappingTransportProtocol(rawValue: prot3)
			}
			if let prot3 = prot2 as? Int,
				let prot4 = TCMPortMappingTransportProtocol.RawValue(exactly: prot3) {
				return TCMPortMappingTransportProtocol(rawValue: prot4)
			}
			return nil
		}()
		
		
		self.init(localPort: newLPort, desiredExternalPort: newDPort, transportProtocol: .TCP, userInfo: usrInfo)
		if let theProtocol = theProtocol {
			transportProtocol = theProtocol
		}
	}
	
    var dictionaryRepresentation: [String: Any] {
		var dict: [String: Any] = [privatePortMapKey: Int(localPort),
				desiredPublicPortMapKey: Int(desiredExternalPort),
				transportProtocolMapKey: Int(transportProtocol.rawValue)] 
		
		dict[userInfoMapKey] = userInfo
		
		return dict
    }
}
