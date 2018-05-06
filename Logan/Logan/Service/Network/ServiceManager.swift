//
//  ServiceManager.swift
//  Logan
//
//  Created by Anh Son Le on 5/5/18.
//  Copyright © 2018 campathon. All rights reserved.
//

import UIKit
import Alamofire
import EVReflection

class ServerRequest {
    init (isDownload: Bool = false, saveToURL: URL = URL.init(fileURLWithPath: ""), method: Alamofire.HTTPMethod, encoding: ParameterEncoding, path: String, header: [String: String]? = nil, parameters: [String: AnyObject]?, datas: [(Data, String, String)]?, responseType: ServerResponse.Type) {
        self.method = method
        self.encoding = encoding
        self.path = path
        self.urlString = ServiceManager.baseURL + path
        self.params = parameters
        self.datas = datas
        self.responseType = responseType.self
        self.header = header
        self.isDownload = isDownload
        self.fileURL = saveToURL
    }
    var method: Alamofire.HTTPMethod
    var encoding: ParameterEncoding
    var path: String
    var urlString: String
    var params: [String: Any]?
    var datas: [(Data, String, String)]?
    var responseType: ServerResponse.Type
    var header: [String: String]?
    var isDownload: Bool
    var fileURL: URL
}

class ErrorResponse: EVObject {
    var code: NSNumber?
    var message: String?
}

class ServerResponse {
    required init(responseData: AnyObject) {
        self.responseData = responseData
    }
    var responseData: AnyObject
    var success: Bool {
        get {
            if let dict = responseData as? NSDictionary {
                if let succ = dict.value(forKey: "success") as? Bool {
                    return succ
                }
            }
            return false
        }
    }
    var data: NSDictionary? {
        get {
            if let dict = responseData as? NSDictionary {
                if let dataDict = dict.value(forKey: "data") as? NSDictionary {
                    return dataDict
                }
            }
            return nil
        }
    }
    var message: String? {
        get {
            if let dict = responseData as? NSDictionary {
                if let mesDict = dict.value(forKey: "message") as? String {
                    return mesDict
                }
            }
            return nil
        }
    }
}

class ServiceManager {
    static var baseURL: String {
        get {
            return AppDefine.domain.host.rawValue
        }
    }
    static let sharedInstance = ServiceManager()
    
    class func execute(_ request: ServerRequest, inViewController: UIViewController? = nil, completionHandle:@escaping ((_ isSuccess: Bool, _ response: ServerResponse?) -> Void), failureHandle:((_ code: Int?) -> Void)? = nil, animate: Bool, showErrorMessage: Bool = true, createRequestSuccess:((Request) -> Void)? = nil) {
        ServiceManager.sharedInstance.execute(request, inViewController: inViewController, completionHandle: completionHandle, failureHandle: failureHandle, animate: animate, showErrorMessage: showErrorMessage, createRequestSuccess: createRequestSuccess)
    }
    
    func execute(_ request: ServerRequest, inViewController: UIViewController? = nil, completionHandle:@escaping ((_ isSuccess: Bool, _ response: ServerResponse?) -> Void), failureHandle:((_ code: Int?) -> Void)? = nil, animate: Bool, showErrorMessage: Bool = false, createRequestSuccess:((Request) -> Void)? = nil) {
        
        // handle when requests fail
        func failure(_ code: Int = -1, message: String? = nil) {
            if (showErrorMessage) {
                // Check error and show it
                BannerManager.share.showMessage(withContent: message ?? "Có lỗi xảy ra", theme: BannerManager.BannerTheme.defaultTheme)
            } else {
                failureHandle?(code)
            }
        }
        
        // handle indicator
        func startIndicator(from topVC: UIViewController?) {
            if animate {
                Utils.startAnimate()
            }
        }
        
        func stopIndicator(from topVC: UIViewController?) {
            if animate {
                Utils.stopAnimate()
            }
        }
        
        print("==============================================")
        print("API: \(request.urlString)")
        print("Parameters: \(request.params)")
        if !Utils.isInternetAvailable() {
            // No internet
            Utils.showAlertDefault("Not internet connection", message: "Check your internet connection", buttons: ["Ok"], completed: { (_) in
                //
            })
            return
        }
        let topVC = Utils.topViewController()
        if animate {
            startIndicator(from: topVC)
        }
        if request.isDownload {
            let req = Alamofire.download(request.urlString,
                                         method: request.method,
                                         parameters: request.params,
                                         encoding: request.encoding,
                                         headers: request.header,
                                         to: { (url, response) -> (destinationURL: URL, options: DownloadRequest.DownloadOptions) in
                                            return (request.fileURL, .createIntermediateDirectories)
            }).responseData(completionHandler: { (downloadResponse) in
                stopIndicator(from: topVC)
                
                switch downloadResponse.result {
                case .success(let data):
                    print("==============================================")
                    print("API: ", request.urlString)
                    if let statusCode = downloadResponse.response?.statusCode {
                        do {
                            let responseObject = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
                            print("Response: ",responseObject)
                            let response = request.responseType.init(responseData: responseObject as AnyObject)
                            if statusCode / 100 == 2 && response.success {
                                completionHandle(true, response)
                                return
                            } else {
                                completionHandle(false, response)
                                failure(statusCode)
                                return
                            }
                        } catch {
                            failure()
                        }
                        completionHandle(false, nil)
                    } else {
                        failure()
                    }
                    
                case .failure:
                    failure()
                }
            })
            createRequestSuccess?(req)
        } else if let datas = request.datas {
            do {
                let url = try URLRequest(url: request.urlString, method: request.method, headers: request.header)
                Alamofire.upload(multipartFormData: { (multipartFormData) in
                    for (data, key, mimeType) in datas {
                        multipartFormData.append(data, withName: key, fileName: "image.png", mimeType: mimeType)
                    }
                    if let parameters = request.params {
                        for (key, value) in parameters {
                            if let data = "\(value)".data(using: String.Encoding.utf8) {
                                multipartFormData.append(data, withName: key)
                            }
                        }
                    }
                }, with: url, encodingCompletion: { (encodingResult) in
                    
                    
                    switch encodingResult {
                    case .success(let upload, _, _):
                        let req = upload.response(completionHandler: { (uploadResponse) in
                            stopIndicator(from: topVC)
                            print("==============================================")
                            print("API: ", request.urlString)
                            if let statusCode = uploadResponse.response?.statusCode {
                                if uploadResponse.error == nil {
                                    if let data = uploadResponse.data {
                                        do {
                                            let responseObject = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
                                            print("Response: ",responseObject)
                                            let response = request.responseType.init(responseData: responseObject as AnyObject)
                                            if statusCode / 100 == 2 && response.success {
                                                completionHandle(true, response)
                                                return
                                            } else {
                                                completionHandle(false, response)
                                                failure(statusCode, message: response.message ?? uploadResponse.response.debugDescription)
                                            }
                                        } catch {
                                            failure(-1, message: nil)
                                        }
                                    }
                                    completionHandle(false, nil)
                                    return
                                }
                            }
                            failure()
                        })
                        createRequestSuccess?(req)
                    case .failure(let error):
                        stopIndicator(from: topVC)
                        print(error)
                        completionHandle(false, nil)
                        failure()
                    }
                })
            } catch {}
        } else {
            let req = Alamofire.request(request.urlString, method: request.method, parameters: request.params, encoding: request.encoding, headers: request.header)
            req.response(completionHandler: { (res) in
                stopIndicator(from: topVC)
                
                print("==============================================")
                print("API: ", request.urlString)
                if let statusCode = res.response?.statusCode {
                    if res.error == nil {
                        if let data = res.data {
                            do {
                                let responseObject = try JSONSerialization.jsonObject(with: data, options: [JSONSerialization.ReadingOptions.allowFragments])
                                print("Response: ",responseObject)
                                let response = request.responseType.init(responseData: responseObject as AnyObject)
                                if statusCode / 100 == 2 && response.success {
                                    completionHandle(true, response)
                                    return
                                } else {
                                    completionHandle(false, response)
                                    failure(statusCode, message: response.message)
                                }
                            } catch let error {
                                print(error)
                                failure()
                            }
                        }
                        completionHandle(false, nil)
                        return
                    }
                } else {
                    completionHandle(false, nil)
                }
                failure()
            })
            createRequestSuccess?(req)
        }
    }
}

