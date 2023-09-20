//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation

protocol CoinManagerDelegate {
    func didUpdateCurrency(_ : CoinManager, _ currency: Double)
    func didFailWithError(_ : CoinManager, _ error: Error)
}

struct CoinManager {

    var delegate: CoinManagerDelegate?
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC/"
    let apiKey = "6747B70C-99A1-40DD-9EA4-8DC4B5D62E40"
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]

}


// MARK: - Get Price

extension CoinManager {
    
    func getCoinPrice(for currency: String) {
        let url = "\(baseURL)\(currency)?apiKey=\(apiKey)"
        performRequest(url)
    }
    
}


// MARK: - Networking

extension CoinManager {
    
    private func performRequest(_ urlString: String) {
        if let url = URL(string: urlString) {
            createURLSession(url: url)
        }
    }
    
    private func createURLSession(url: URL) {
        let session = URLSession(configuration: .default)
        createTask(url: url, session: session)
    }
    
    private func createTask(url: URL, session: URLSession) {
        let task = session.dataTask(with: url, completionHandler: responseHandler(data:response:error:))
        task.resume()
    }
    
    private func responseHandler(data: Data?, response: URLResponse?, error: Error?) {
        if error != nil {
            delegate?.didFailWithError(self, error!)
        }
        
        if let data = data {
            checkData(data)
        }
    }
    
    private func checkData(_ data: Data) {
        if let currency = parseJSON(data) {
            delegate?.didUpdateCurrency(self, currency)
        }
    }
    
    private func parseJSON(_ data: Data) -> Double? {
        let decoder = JSONDecoder()
        
        do {
            let decodedData = try decoder.decode(CoinData.self, from: data)
            return decodedData.rate
        } catch {
            delegate?.didFailWithError(self, error)
            return nil
        }
    }
    
}
