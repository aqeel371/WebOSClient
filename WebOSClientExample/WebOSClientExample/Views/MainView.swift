//
//  MainView.swift
//  WebOSClientExample
//
//  Created by Yaroslav Sedyshev on 11.01.2024.
//

import SwiftUI

struct MainView: View {
    @State private var selection: Int = 1
    @State private var appFilter: Int = 2
    @State private var showSettings: Bool = false
    @ObservedObject private var viewModel = ViewModel()
    var body: some View {
        NavigationView {
            List(selection: $selection) {
                Section(header: Text("INFO")) {
                    NavigationLink(destination: AboutView()) {
                        Label("About", systemImage: "info.bubble")
                    }
                    .tag(0)
                }
                Section(header: Text("CONNECTION STATUS")) {
                    if viewModel.isConnected {
                        Label("Connected", systemImage: "network")
                            .foregroundColor(.green)
                    } else {
                        Label("Disconnected", systemImage: "network.slash")
                            .foregroundColor(.accentColor)
                    }
                }
                Section(header: Text("MENU")) {
                    NavigationLink(destination: RemoteView(viewModel: viewModel)) {
                        Label("TV Remote", systemImage: "tv")
                    }
                    .tag(1)
                    NavigationLink(destination: MouseView(viewModel: viewModel)) {
                        Label("Mouse Pad", systemImage: "cursorarrow.click.2")
                    }
                    .tag(2)
                    NavigationLink(destination: AppsView(viewModel: viewModel)) {
                        Label("Apps", systemImage: "apps.ipad.landscape")
                    }
                    .tag(3)
                    NavigationLink(destination: SubscriptionsView(viewModel: viewModel)) {
                        Label("Subscriptions", systemImage: "antenna.radiowaves.left.and.right")
                    }
                    .tag(4)
                    NavigationLink(destination: KeyboardView(viewModel: viewModel)) {
                        Label("Keyboard", systemImage: "keyboard")
                    }
                    .tag(5)
                    NavigationLink(destination: ToastView(viewModel: viewModel)) {
                        Label("Toasts", systemImage: "text.bubble")
                    }
                    .tag(6)
                    NavigationLink(destination: MiscView(viewModel: viewModel)) {
                        Label("Miscellaneous", systemImage: "wrench.and.screwdriver")
                    }
                    .tag(7)
                    NavigationLink(destination: LogView(viewModel: viewModel)) {
                        Label("Logs", systemImage: "folder.badge.gearshape")
                    }
                    .tag(8)
                }
            }
            .listStyle(.sidebar)
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button(action: {
                        if viewModel.isConnected {
                            viewModel.tv?.disconnect()
                        } else {
                            let ip = UserDefaults.standard.value(forKey: ViewModel.Constants.tvIPKey) as? String
                            viewModel.connectAndRegister(with: ip)
                        }
                    }, label: {
                        Image(systemName: viewModel.isConnected ? "network.slash" : "network")
                    })
                    .help(viewModel.isConnected ? "Disconnect" : "Connect")
                }
                ToolbarItem(placement: .automatic) {
                    Button(action: {
                        showSettings.toggle()
                    }, label: {
                        Image(systemName: "gearshape")
                    })
                    .help("Settings")
                }
                if selection == 3 {
                    ToolbarItem(placement: .accessoryBar(id: 0)) {
                        Picker("Apps: ", selection: $appFilter) {
                            Text("All").tag(0)
                            Text("System").tag(1)
                            Text("Third-party").tag(2)
                        }
                        .disabled(!viewModel.isConnected)
                        .pickerStyle(.segmented)
                        .onChange(of: appFilter) { _ in
                            switch appFilter {
                            case 0:
                                viewModel.showAllApps()
                            case 1:
                                viewModel.showSystemApps()
                            case 2:
                                viewModel.showNonSystemApps()
                            default:
                                viewModel.showNonSystemApps()
                            }
                        }
                    }
                }
                if selection == 8 {
                    ToolbarItem(placement: .accessoryBar(id: 0)) {
                        Button(action: {
                            viewModel.clearLogs()
                        }, label: {
                            Image(systemName: "folder.badge.minus")
                            Text("Clear Logs")
                        })
                        .help("Clear Logs")
                    }
                    ToolbarItem(placement: .accessoryBar(id: 0)) {
                        Button(action: {
                            viewModel.tv?.send(.systemInfo)
                        }, label: {
                            Image(systemName: "info.square")
                            Text("System Info")
                        })
                        .help("System Info")
                    }
                }
            }
            .sheet(isPresented: $showSettings, onDismiss: {
                if let ip = UserDefaults.standard.value(forKey: ViewModel.Constants.tvIPKey) as? String {
                    viewModel.connectAndRegister(with: ip)
                }
            }) {
                SettingsView(showSettings: $showSettings, viewModel: viewModel)
            }
            .sheet(isPresented: $viewModel.showPinAlert) {
                PinView(showPin: $viewModel.showPinAlert, viewModel: viewModel)
            }
            .onAppear {
                if UserDefaults.standard.value(forKey: ViewModel.Constants.tvIPKey) as? String == nil {
                    showSettings = true
                }
            }
            .alert("Please accept registration prompt on the TV.",
                   isPresented: $viewModel.showPromptAlert) {}
        }
    }
}
