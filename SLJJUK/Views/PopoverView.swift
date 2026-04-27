import SwiftUI

struct PopoverView: View {
    @EnvironmentObject var vm: StockViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            if vm.showSettings {
                SettingsView()
            } else {
                // 헤더
                HStack {
                    Text("📈 SLJJUK").font(.system(size: 13, weight: .bold))
                    Spacer()
                    Text(vm.lastUpdatedString).font(.system(size: 10)).foregroundColor(.secondary)
                    Button { Task { await vm.refresh() } } label: {
                        Image(systemName: "arrow.clockwise").font(.system(size: 11))
                    }
                    .buttonStyle(.plain).foregroundColor(.secondary)
                }
                .padding(.horizontal, 12).padding(.vertical, 10)
                
                Divider()
                
                // 주가 리스트
                if vm.watchlist.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 30)).foregroundColor(.secondary.opacity(0.5))
                        Text("설정에서 종목을 추가하세요")
                            .font(.system(size: 12)).foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(vm.stocks) { stock in
                                StockRowView(stock: stock)
                                Divider().padding(.horizontal, 12).opacity(0.5)
                            }
                        }
                    }
                }
                
                Divider()
                
                // 푸터
                HStack {
                    Button(action: { vm.showSettings = true }) {
                        HStack(spacing: 4) {
                            Image(systemName: "gearshape.fill")
                            Text("설정")
                        }
                        .font(.system(size: 12))
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                    
                    Button(action: { NSApplication.shared.terminate(nil) }) {
                        Text("종료").font(.system(size: 12)).foregroundColor(.red.opacity(0.8))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 12).padding(.vertical, 10)
            }
        }
        .frame(width: 300, height: 480)
        .background(Color(NSColor.windowBackgroundColor))
    }
}
