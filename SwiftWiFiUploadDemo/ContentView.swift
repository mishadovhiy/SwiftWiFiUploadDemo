//
//  ContentView.swift
//  SwiftWiFiUploadDemo
//
//  Created by Misha Dovhiy on 16.07.2024.
//

import SwiftUI

struct ContentView: View {
    
    @State var viewModel:ContentViewViewModel = .init()
    
    var body: some View {
        VStack {
            if #available(iOS 15.0, *) {
                image
                    .foregroundStyle(.tint)
            } else {
                image
            }
            Text("Hello, world!")
            Spacer()
                .frame(height: 10)
            Button((viewModel.serverModel.listener != nil ? "Stop" : "Start") + " server") {
                viewModel.serverModel.toggleServer()
            }
            TextField("server title", text: .init(get: {
                viewModel.serverModel.htmlString
            }, set: {
                self.viewModel.serverModel.htmlString = $0
            }))
            TextField("message", text: .init(get: {
                viewModel.serverModel.message
            }, set: {
                viewModel.serverModel.message = $0
            }))
            Button("show popup", action: {
                self.viewModel.isPresentingPopover = true
            })
            .popover(isPresented: $viewModel.isPresentingPopover) {
                PopoverContentView(content: .init(title: "enter urls"), primaryButton: .init(title: "ok", pressed: {
                    self.viewModel.isPresentingPopover = false
                    self.viewModel.createDirectory()
                }), textFieldText: $viewModel.popuoverText)
            }
        }
        .padding()
        .onAppear(perform: {
            
        })
    }
    
    var image: some View {
        Image(systemName: "globe")
            .imageScale(.large)
    }
}

#Preview {
    ContentView()
}

struct ContentViewViewModel {
    var serverModel:ServerModel = .init()
    var isPresentingPopover:Bool = false
    var popuoverText:String = ""
    var fileManager:FileManagerService = .init()
    
    mutating func createDirectory() {
        let text = popuoverText
        fileManager.createDirectory(name: text)
        popuoverText = ""
        serverModel.fileDirectoryToSend = text
    }
}


struct PopoverContentView: View {
    var content:MessageContent
    var primaryButton:ButtonContent
    var secondaryButton:ButtonContent? = nil
    @Binding var textFieldText:String
    
    var body: some View {
        VStack {
            Text(content.title)
            if let description = content.description {
                Text(description)
            }
            TextField("", text: $textFieldText)
            Button(primaryButton.title, action: {
                primaryButton.pressed?()
            })
            if let secondaryButton {
                Button(secondaryButton.title, action: {
                    secondaryButton.pressed?()
                })
            }
        }
    }
}
