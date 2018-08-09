//
//  Serializable.swift
//  fcm-channel-ios
//
//  Created by Rubens Pessoa on 25/09/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

/*
 Converts A class to a dictionary, used for serializing dictionaries to JSON
 Supported objects:
 - Serializable derived classes (sub classes)
 - Arrays of Serializable
 - NSData
 - String, Numeric, and all other NSJSONSerialization supported objects
 */

import Foundation

open class Serializable: NSObject {
    
    convenience init(jsonDict: NSDictionary?) {
        self.init()
        
        if let jsonDict = jsonDict {
            for (key, value) in jsonDict {
                guard let key = key as? String else { continue }
                for c in Mirror(reflecting: self).children {
                    if let name = c.label{
                        if name == key {
                            self.setValue(value, forKey: key)
                            break
                        }
                    }
                }       
            }
        }
    }
    
    /**
     Converts the class to a dictionary.
     - returns: The class as an NSDictionary.
     */
    open func toDictionary() -> NSDictionary {
        let propertiesDictionary = NSMutableDictionary()
        let mirror0 = Mirror(reflecting: self)
        
        if let mirror = mirror0.superclassMirror {
            build(mirror, propertiesDictionary: propertiesDictionary)
            build(mirror0, propertiesDictionary: propertiesDictionary)
        }else {
            build(mirror0, propertiesDictionary: propertiesDictionary)
        }
        
        return propertiesDictionary
    }
    
    fileprivate func build(_ mirror:Mirror,propertiesDictionary:NSMutableDictionary) {
        for (propName, propValue) in mirror.children {
            
            let propValue = self.unwrap(propValue)
            
            if propValue is NSNull {
                continue
            }
            
            if let propName = propName {
                
                if let serializablePropValue = propValue as? Serializable {
                    propertiesDictionary.setValue(serializablePropValue.toDictionary(), forKey: propName)
                } else if let arrayPropValue = propValue as? [Serializable] {
                    var subArray = [NSDictionary]()
                    for item in arrayPropValue {
                        subArray.append(item.toDictionary())
                    }
                    
                    propertiesDictionary.setValue(subArray, forKey: propName)
                    
                } else if propValue is Int || propValue is Double || propValue is Float {
                    propertiesDictionary.setValue(propValue, forKey: propName)
                } else if let dataPropValue = propValue as? Data {
                    propertiesDictionary.setValue(dataPropValue.base64EncodedString(options: .lineLength64Characters), forKey: propName)
                } else if let boolPropValue = propValue as? Bool {
                    propertiesDictionary.setValue(boolPropValue, forKey: propName)
                } else if let stringPropValue = propValue as? String  {
                    propertiesDictionary.setValue(stringPropValue, forKey: propName)
                }else {
                    print(propValue)
                    propertiesDictionary.setValue(propValue, forKey: propName)
                }
            }
//            else if let propValue:Int8 = propValue as? Int8 {
//                propertiesDictionary.setValue(NSNumber(value: propValue as Int8), forKey: propName)
//            }
//            else if let propValue:Int16 = propValue as? Int16 {
//                propertiesDictionary.setValue(NSNumber(value: propValue as Int16), forKey: propName)
//            }
//            else if let propValue:Int32 = propValue as? Int32 {
//                propertiesDictionary.setValue(NSNumber(value: propValue as Int32), forKey: propName)
//            }
//            else if let propValue:Int64 = propValue as? Int64 {
//                propertiesDictionary.setValue(NSNumber(value: propValue as Int64), forKey: propName)
//            }
//            else if let propValue:UInt8 = propValue as? UInt8 {
//                propertiesDictionary.setValue(NSNumber(value: propValue as UInt8), forKey: propName)
//            }
//            else if let propValue:UInt16 = propValue as? UInt16 {
//                propertiesDictionary.setValue(NSNumber(value: propValue as UInt16), forKey: propName)
//            }
//            else if let propValue:UInt32 = propValue as? UInt32 {
//                propertiesDictionary.setValue(NSNumber(value: propValue as UInt32), forKey: propName)
//            }
//            else if let propValue:UInt64 = propValue as? UInt64 {
//                propertiesDictionary.setValue(NSNumber(value: propValue as UInt64), forKey: propName)
//            }
        }
        
    }
    
    /**
     Converts the class to JSON.
     - returns: The class as JSON, wrapped in NSData.
     */
    open func toJson(_ prettyPrinted : Bool = false) -> Data? {
        let dictionary = self.toDictionary()
        
        if JSONSerialization.isValidJSONObject(dictionary) {
            do {
                let json = try JSONSerialization.data(withJSONObject: dictionary, options: (prettyPrinted ? .prettyPrinted : JSONSerialization.WritingOptions()))
                return json
            } catch let error as NSError {
                print("ERROR: Unable to serialize json, error: \(error)")
                NotificationCenter.default.post(name: Notification.Name(rawValue: "CrashlyticsLogNotification"), object: self, userInfo: ["string": "unable to serialize json, error: \(error)"])
            }
        }
        
        return nil
    }
    
    /**
     Converts the class to a JSON string.
     - returns: The class as a JSON string.
     */
    open func toJsonString(_ prettyPrinted : Bool = false) -> String? {
        if let jsonData = self.toJson(prettyPrinted) {
            return String(data: jsonData, encoding: String.Encoding.utf8)
        }
        
        return nil
    }
    
}

extension Serializable {
    
    /**
     Unwraps 'any' object. See http://stackoverflow.com/questions/27989094/how-to-unwrap-an-optional-value-from-any-type
     - returns: The unwrapped object.
     */
    fileprivate func unwrap(_ any: Any) -> Any {
        let mi = Mirror(reflecting: any)
        
        if mi.displayStyle != .optional {
            return any
        }

        // TODO: check
        if let first = mi.children.first {
            let (_, some) = first
            return some
        } else {
            return NSNull()
        }

//        if mi.children.count == 0 { return NSNull() }
//        let (_, some) = mi.children.first ?? NSNull
//        return some
    }
}
