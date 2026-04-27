import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var vm: StockViewModel
    @State private var inputCode = ""
    @State private var inputAlias = ""
    @State private var searchResults: [(name: String, code: String)] = []
    @FocusState private var isAliasFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // 헤더
            HStack {
                Button(action: { vm.showSettings = false }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("뒤로")
                    }
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.accentColor)
                }
                .buttonStyle(.plain)
                
                Spacer()
                Text("종목 설정").font(.system(size: 13, weight: .bold))
                Spacer()
                
                // 균형을 위한 빈 공간
                Text("뒤로").font(.system(size: 13)).opacity(0)
            }
            .padding(.horizontal, 12).padding(.vertical, 12)
            
            Divider()
            
            VStack(alignment: .leading, spacing: 12) {
                Text("종목 추가").font(.system(size: 11, weight: .semibold)).foregroundColor(.secondary)
                
                HStack(spacing: 8) {
                    VStack(alignment: .leading, spacing: 0) {
                        TextField("종목명", text: $inputAlias)
                            .textFieldStyle(.roundedBorder)
                            .focused($isAliasFocused)
                            .onChange(of: inputAlias) { newValue in
                                Task {
                                    let results = await vm.searchStock(query: newValue)
                                    await MainActor.run {
                                        self.searchResults = results
                                    }
                                }
                            }
                    }
                    
                    TextField("코드", text: $inputCode)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 80)
                    
                    Button("추가") {
                        vm.addStock(code: inputCode, alias: inputAlias)
                        inputCode = ""
                        inputAlias = ""
                        searchResults = []
                        isAliasFocused = false
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(inputCode.count != 6)
                }
                
                if !searchResults.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(searchResults.prefix(5), id: \.code) { result in
                            Button(action: {
                                inputAlias = result.name
                                inputCode = result.code
                                searchResults = []
                            }) {
                                HStack {
                                    Text(result.name).font(.system(size: 12))
                                    Spacer()
                                    Text(result.code).font(.system(size: 11)).foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .background(Color.accentColor.opacity(0.1))
                            .cornerRadius(4)
                        }
                    }
                    .padding(.top, 4)
                }
            }
            .padding(12)
            .background(Color.secondary.opacity(0.05))
            
            Divider()
            
            // 종목 리스트
            ScrollView {
                VStack(spacing: 0) {
                    if vm.watchlist.isEmpty {
                        Text("등록된 종목이 없습니다")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                            .padding(.top, 40)
                    } else {
                        ForEach(Array(vm.watchlist.enumerated()), id: \.element.code) { index, item in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.alias).font(.system(size: 13, weight: .medium))
                                    Text(item.code).font(.system(size: 10)).foregroundColor(.secondary)
                                }
                                Spacer()
                                
                                Button(action: {
                                    vm.removeStock(at: index)
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red.opacity(0.7))
                                        .font(.system(size: 13))
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal, 16).padding(.vertical, 10)
                            Divider().padding(.horizontal, 12).opacity(0.5)
                        }
                    }
                }
            }
            
            Divider()
            
            // 종료 버튼
            HStack {
                Spacer()
                Button(action: { NSApplication.shared.terminate(nil) }) {
                    HStack(spacing: 4) {
                        Image(systemName: "power")
                        Text("프로그램 종료")
                    }
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.red.opacity(0.8))
                }
                .buttonStyle(.plain)
                .padding(8)
            }
            .padding(.horizontal, 8)
        }
        .background(Color(NSColor.windowBackgroundColor))
        .onAppear {
            isAliasFocused = false
        }
    }
}
