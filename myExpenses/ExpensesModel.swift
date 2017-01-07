//
//  ExpensesModel.swift
//  myExpenses
//
//  Created by Yuki Sumida on 2017/01/07.
//
//

import Foundation
import RxSwift

class ExpensesModel: ResponseProtocol {
    var result:APIResult?
    var resultCode: String = ""
    var resultMessage: String = ""
    var sessionId: String = ""
    var destinations: [DestinationModel] = []

    required init(data: NSDictionary) {
        if let resultCode = data["resultCode"] {
            self.resultCode = resultCode as! String
        }

        if let resultMessage = data["resultMessage"] {
            self.resultMessage = resultMessage as! String
        }

        if let sessionId = data["sessionId"] {
            self.sessionId = sessionId as! String
        }

        if let destinations = data["destinations"] {
            let desitnationsArray = destinations as! Array<[String : AnyObject]>
            
            self.destinations = desitnationsArray.map {
               DestinationModel(data: $0)
            }
        }

        result = APIResult(code: self.resultCode, message: self.resultMessage)
    }

    static func call(sessionId: String, period: String) -> Observable<(ExpensesModel, NSHTTPURLResponse)> {

        let session: NSURLSession = NSURLSession.sharedSession()
        return session.rx_responseObject(ExpensesRequest(sessionId: sessionId, period: period))
    }
}

class DestinationModel {
    var id: String = ""
    var date: NSDate?
    var name: String = ""
    var useJR: Bool = false
    var usePrivate: Bool = false
    var useHighway: Bool = false
    var useBus: Bool = false
    var useOther: Bool = false
    var from: String = ""
    var to: String = ""
    var fare: Int = 0
    var remarks: String = ""

    init(data: NSDictionary) {
        if let id = data["id"] {
            self.id = id as! String
        }

        if let date = data["date"] {
            let formatter = NSDateFormatter()
            formatter.dateFormat = "yyyyMMdd"
            self.date = formatter.dateFromString(date as! String)
        }

        if let name = data["name"] {
            self.name = name as! String
        }

        if let useJR = data["jr"] {
            self.useJR = useJR as! Bool
        }
    }
}

class ExpensesRequest: RequestProtocol {
    typealias Response = ExpensesModel
    var sessionId: String = ""
    var period: String = "" // TODO あとで型を作る

    var request: NSMutableURLRequest {
        let body = NSMutableDictionary()
        body.setValue(sessionId, forKey: "sessionId");
        body.setValue(period, forKey: "period");

        let url:NSURL = NSURL(string: "http://localhost/expenses.php")!
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(body, options: NSJSONWritingOptions.init(rawValue: 2))
        return request
    }

    init(sessionId: String, period: String) {
        self.sessionId = sessionId
        self.period = period
    }
}