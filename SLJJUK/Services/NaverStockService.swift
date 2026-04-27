import Foundation

class NaverStockService {
    static let shared = NaverStockService()
    private init() {}
    
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = [
            "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36",
            "Referer": "https://m.stock.naver.com/"
        ]
        config.timeoutIntervalForRequest = 10
        return URLSession(configuration: config)
    }()
    
    func fetchStock(code: String, alias: String) async throws -> StockItem {
        guard let url = URL(string: "https://m.stock.naver.com/api/stock/\(code)/basic") else {
            throw StockError.invalidURL
        }
        let (data, response) = try await session.data(from: url)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw StockError.httpError
        }
        return try JSONDecoder().decode(NaverBasicResponse.self, from: data).toStockItem(alias: alias)
    }
    
    func fetchStocks(_ watchlist: [WatchlistItem]) async -> [StockItem] {
        await withTaskGroup(of: StockItem?.self) { group in
            for item in watchlist {
                group.addTask { try? await self.fetchStock(code: item.code, alias: item.alias) }
            }
            var results: [StockItem] = []
            for await item in group { if let item { results.append(item) } }
            return watchlist.compactMap { w in results.first { $0.code == w.code } }
        }
    }

    func searchStock(query: String) async -> [(name: String, code: String)] {
        guard let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://ac.stock.naver.com/ac?q=\(encoded)&target=stock") else { return [] }
        
        do {
            let (data, _) = try await session.data(from: url)
            guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let itemsOuter = json["items"] as? [[Any]],
                  let items = itemsOuter.first else { return [] }
            
            return items.compactMap { item -> (name: String, code: String)? in
                guard let detail = item as? [Any], detail.count >= 2,
                      let name = detail[0] as? String,
                      let code = detail[1] as? String else { return nil }
                return (name, code)
            }
        } catch {
            return []
        }
    }
}

enum StockError: Error {
    case invalidURL, httpError
}
