//
//  URDateUtil.swift
//  ureport
//
//  Created by Daniel Amaral on 09/07/15.
//  Copyright (c) 2015 ilhasoft. All rights reserved.
//

import UIKit

open class FCMChannelDateUtil: NSObject {
   
    open class func birthDayFormatter(_ date:Date) -> String{
        return DateFormatter.localizedString(from: date, dateStyle: DateFormatter.Style.medium, timeStyle: DateFormatter.Style.none)
    }
    
    open class func birthDayFormatter(_ date:Date,brFormat:Bool) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = brFormat == true ? "dd-MM-yyyy HH:mm" : "MM-dd-yyyy HH:mm" //format style. Browse online to get a format that fits your needs.
        return dateFormatter.string(from: date)
    }
    
    open class func dateFormatter(_ date:Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SS'Z'"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        return dateFormatter.string(from: date)
    }
    
    open class func dateParser(_ date:String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SS'Z'"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        return dateFormatter.date(from: date)!
    }
    
    open class func UTCDateFormatter(_ date:Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        return dateFormatter.string(from: date)
    }
    
    open class func getYear(_ date:Date) -> Int {
        let calendar: Calendar = Calendar.current
        let components = (calendar as NSCalendar).components(NSCalendar.Unit.year, from: date)
        return components.year!        
    }
    
}
