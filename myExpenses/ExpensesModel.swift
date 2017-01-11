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

        if let usePrivate = data["private"] {
            self.usePrivate = usePrivate as! Bool
        }

        if let useBus = data["bus"] {
            self.usePrivate = useBus as! Bool
        }

        if let useOther = data["other"] {
            self.useOther = useOther as! Bool
        }

        if let from = data["from"] {
            self.from = from as! String
        }

        if let to = data["to"] {
            self.to = to as! String
        }

        if let fare = data["fare"] {
            self.fare = fare as! Int
        }

        if let remarks = data["remarks"] {
            self.remarks = remarks as! String
        }
    }
}

class ExpensesRequest: RequestProtocol {
    typealias Response = ExpensesModel
    var sessionId: String = ""
    var period: String = "" // TODO あとで型を作る

    var request: NSMutableURLRequest {
        let url:NSURL = NSURL(string: baseURL + "expenses.php?sessionId=\(sessionId)&period=\(period)")!
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }

    init(sessionId: String, period: String) {
        self.sessionId = sessionId
        self.period = period
    }
}