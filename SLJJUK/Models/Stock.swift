import Foundation

struct WatchlistItem: Codable, Identifiable {
    var id: String { code }
    let code: String   // "005930"
    var alias: String  // "삼전"
}

struct StockItem: Identifiable {
    let id: String
    let code: String
    let name: String
    let alias: String
    let price: String       // "224,750"
    let change: String      // "5,250"
    let changeRate: String  // "2.39"
    let direction: PriceDirection
    let marketStatus: MarketStatus
    
    var menuBarText: String {
        "\(alias) \(price) \(direction.arrow)\(changeRate)%"
    }
}

enum PriceDirection {
    case rising, falling, even, unknown
    var arrow: String {
        switch self {
        case .rising:  return "▲"
        case .falling: return "▼"
        case .even:    return "─"
        case .unknown: return ""
        }
    }
}

enum MarketStatus: String {
    case open = "OPEN", close = "CLOSE", unknown
}

// MARK: - Naver API Response
struct NaverBasicResponse: Decodable {
    let itemCode: String
    let stockName: String
    let closePrice: String
    let compareToPreviousClosePrice: String
    let compareToPreviousPrice: NaverPriceDirection
    let fluctuationsRatio: String
    let marketStatus: String
    
    struct NaverPriceDirection: Decodable {
        let name: String  // "RISING" | "FALLING" | "EVEN"
    }
    
    func toStockItem(alias: String) -> StockItem {
        let dir: PriceDirection
        switch compareToPreviousPrice.name {
        case "RISING":  dir = .rising
        case "FALLING": dir = .falling
        case "EVEN":    dir = .even
        default:        dir = .unknown
        }
        return StockItem(
            id: itemCode, code: itemCode, name: stockName,
            alias: alias.isEmpty ? stockName : alias,
            price: closePrice, change: compareToPreviousClosePrice,
            changeRate: fluctuationsRatio, direction: dir,
            marketStatus: MarketStatus(rawValue: marketStatus) ?? .unknown
        )
    }
}//
//  Stock.swift
//  SLJJUK
//
//  Created by 김현일 on 4/27/26.
//

