import SwiftUI

struct StockRowView: View {
    let stock: StockItem
    
    var priceColor: Color {
        switch stock.direction {
        case .rising:  return Color(red: 0.80, green: 0.15, blue: 0.15) // 빨강 (상승)
        case .falling: return Color(red: 0.08, green: 0.45, blue: 0.82) // 파랑 (하락)
        default:       return .secondary
        }
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text(stock.alias).font(.system(size: 13, weight: .medium))
                Text(stock.name).font(.system(size: 10)).foregroundColor(.secondary).lineLimit(1)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(stock.price)
                    .font(.system(size: 14, weight: .semibold).monospacedDigit())
                    .foregroundColor(priceColor)
                HStack(spacing: 2) {
                    Text(stock.direction.arrow).font(.system(size: 9))
                    Text("\(stock.change)  \(stock.changeRate)%")
                        .font(.system(size: 10).monospacedDigit())
                }
                .foregroundColor(priceColor)
            }
        }
        .padding(.horizontal, 12).padding(.vertical, 10)
        .contentShape(Rectangle())
        .onTapGesture {
            if let url = URL(string: "https://m.stock.naver.com/domestic/stock/\(stock.code)/total") {
                NSWorkspace.shared.open(url)
            }
        }
    }
}//
//  StockRowView.swift
//  SLJJUK
//
//  Created by 김현일 on 4/27/26.
//

