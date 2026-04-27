import SwiftUI
import Combine

@MainActor
class StockViewModel: ObservableObject {
    @Published var stocks: [StockItem] = []
    @Published var isLoading = false
    @Published var lastUpdated: Date?
    @Published var displayIndex: Int = 0
    @Published var showSettings = false
    
    @Published var watchlist: [WatchlistItem] = [] {
        didSet { saveWatchlist() }
    }
    
    private var cancellables = Set<AnyCancellable>()
    private let service = NaverStockService.shared
    private let watchlistKey = "stockbar_watchlist_v2" // 버전 업으로 초기화 방지
    
    var currentDisplayStock: StockItem? {
        guard !stocks.isEmpty else { return nil }
        return stocks[displayIndex % stocks.count]
    }
    
    var lastUpdatedString: String {
        guard let d = lastUpdated else { return "연결 중..." }
        let fmt = DateFormatter(); fmt.dateFormat = "HH:mm:ss"
        return "갱신: \(fmt.string(from: d))"
    }
    
    init() {
        loadWatchlist()
        Task { await refresh() }
        
        // 메뉴바 롤링 (10초)
        Timer.publish(every: 10, on: .main, in: .common).autoconnect()
            .sink { [weak self] _ in
                guard let self = self, self.stocks.count > 1 else { return }
                self.displayIndex = (self.displayIndex + 1) % self.stocks.count
            }
            .store(in: &cancellables)
            
        // 전체 자동 새로고침 (30초)
        Timer.publish(every: 30, on: .main, in: .common).autoconnect()
            .sink { [weak self] _ in
                Task { await self?.refresh() }
            }
            .store(in: &cancellables)
    }
    
    func refresh() async {
        guard !watchlist.isEmpty else { 
            self.stocks = []
            return 
        }
        isLoading = true
        let fetched = await service.fetchStocks(watchlist)
        self.stocks = fetched
        self.lastUpdated = Date()
        self.isLoading = false
    }
    
    func addStock(code: String, alias: String) {
        let cleanCode = code.trimmingCharacters(in: .whitespaces)
        guard cleanCode.count == 6, cleanCode.allSatisfy({ $0.isNumber }) else { return }
        if watchlist.contains(where: { $0.code == cleanCode }) { return }
        
        let finalAlias = alias.trimmingCharacters(in: .whitespaces).isEmpty ? cleanCode : alias
        self.watchlist.append(WatchlistItem(code: cleanCode, alias: finalAlias))
        
        Task { await refresh() }
    }

    func searchStock(query: String) async -> [(name: String, code: String)] {
        guard !query.isEmpty else { return [] }
        return await service.searchStock(query: query)
    }
    
    func removeStock(at index: Int) {
        guard index >= 0 && index < watchlist.count else { return }
        watchlist.remove(at: index)
        Task { await refresh() }
    }
    
    func moveStock(from source: IndexSet, to destination: Int) {
        watchlist.move(fromOffsets: source, toOffset: destination)
        Task { await refresh() }
    }
    
    private func saveWatchlist() {
        if let data = try? JSONEncoder().encode(watchlist) {
            UserDefaults.standard.set(data, forKey: watchlistKey)
        }
    }
    
    private func loadWatchlist() {
        if let data = UserDefaults.standard.data(forKey: watchlistKey),
           let list = try? JSONDecoder().decode([WatchlistItem].self, from: data) {
            watchlist = list
        } else {
            watchlist = [
                WatchlistItem(code: "005930", alias: "삼성전자"),
                WatchlistItem(code: "000660", alias: "SK하이닉스")
            ]
        }
    }
}
