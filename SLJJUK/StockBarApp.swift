import SwiftUI

@main
struct StockBarApp: App {
    @StateObject private var viewModel = StockViewModel()
    
    var body: some Scene {
        // Dock 아이콘 없는 메뉴바 전용 앱 (Info.plist: LSUIElement = YES)
        MenuBarExtra {
            PopoverView()
                .environmentObject(viewModel)
        } label: {
            MenuBarLabel(viewModel: viewModel)
        }
        .menuBarExtraStyle(.window)
    }
}

struct MenuBarLabel: View {
    @ObservedObject var viewModel: StockViewModel
    
    var body: some View {
        if let stock = viewModel.currentDisplayStock {
            Text(stock.menuBarText)
                .font(.system(size: 12, weight: .medium).monospacedDigit())
        } else {
            HStack(spacing: 3) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 13))
                if viewModel.isLoading {
                    Text("로딩 중...").font(.system(size: 12))
                }
            }
        }
    }
}//
//  StockBarApp.swift
//  SLJJUK
//
//  Created by 김현일 on 4/27/26.
//

