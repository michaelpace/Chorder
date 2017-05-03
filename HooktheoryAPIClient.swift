//
//  HooktheoryAPIClient.swift
//  Chorder
//
//  Created by Michael Pace on 5/2/17.
//  Copyright © 2017 Michael Pace. All rights reserved.
//

import Foundation

/// TODO
struct HooktheoryAPIClient {

    fileprivate let baseURL: URL
    fileprivate let urlSession: URLSession

    /// TODO
    ///
    /// - Parameters:
    ///   - baseURL: TODO
    ///   - TODO: TODO
    init(baseURL: URL = URL(string: "https://api.hooktheory.com/v1/")!, // TODO: Constant-ize.
         urlSessionConfiguration: URLSessionConfiguration = .default) {

        self.baseURL = baseURL
        self.urlSession = URLSession(configuration: urlSessionConfiguration)
    }

    /// TODO
    ///
    /// - Parameters:
    ///   - request: TODO
    ///   - completion: TODO
    func perform<ResultType: Parseable>(_ request: Request, completion: @escaping (Result<ResultType>) -> Void) {
        let urlRequest = self.urlRequest(with: request)

        let task = urlSession.dataTask(with: urlRequest) { (data, response, error) in

            if let error = error {
                completion(.failure(error: error))
            } else {
                guard let data = data else { fatalError("Expected the request to have a result.") }
                guard let parsedValue = ResultType.parse(from: data) else { fatalError("Unable to parse data from request to \(request.path): \(data)") }

                completion(.success(result: parsedValue))
            }

        }

        task.resume()
    }

}

private extension HooktheoryAPIClient {

    func urlRequest(with request: Request) -> URLRequest {
        let url = baseURL.appendingPathComponent(request.path, isDirectory: false)

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method
        urlRequest.httpBody = request.body

        return urlRequest
    }

}
