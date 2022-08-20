//
//  API.swift
//  Web3
//
//  Created by Kefan Xie on 8/19/22.
//

import Foundation
import Alamofire

let HOST = "https://www.realfan.xyz/api/"
let API_GET_PROFILE = "get_profile.php"
let API_SET_PROFILE = "set_profile.php"

class API {
    static func setProfile(params: Dictionary<String, Any>, completion: @escaping (Dictionary<String, Any>?) -> Void){
//        print(params)
        self.jsonRequest(method: API_SET_PROFILE, params: params) { json in
            completion(json)
        }
    }
    
    static func getProfile(params: Dictionary<String, Any>, completion: @escaping (Dictionary<String, Any>?) -> Void){
//        print(params)
        self.jsonRequest(method: API_GET_PROFILE, params: params) { json in
            completion(json)
        }
    }

    static func jsonRequest(method: String, params: Optional<Dictionary<String, Any>>? = [:], completion: @escaping (Dictionary<String, Any>?) -> Void)
    {
        let url = HOST + method

        //if you want to add paramter
        let req = AF.request(url as URLConvertible, method: .post, parameters: params!!)

        req.responseJSON { response in
                //to get status code
                switch response.result {
                    case .success(let value):
                        completion(value as? Dictionary<String, Any>)
                    case .failure(let error):
                        print(error)
                    completion([:])
                }
            }
    }
}
