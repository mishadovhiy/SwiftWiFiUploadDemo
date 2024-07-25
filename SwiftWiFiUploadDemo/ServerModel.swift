//
//  ServerModel.swift
//  SwiftWiFiUploadDemo
//
//  Created by Misha Dovhiy on 16.07.2024.
//

import UIKit
import Network

class ServerModel {
    var message:String = ""
    var htmlString:String = "helsd"
    var serverStarted:Bool {
        listener?.state == .ready
    }
    var listener: NWListener?
    var fileDirectoryToSend:String? = nil
    
    func toggleServer() {
        if serverStarted {
            listener?.cancel()
            listener = nil
        } else {
            self.startServer()
        }
    }
    
    private func startServer() {
        do {
            let parameters = NWParameters.tcp
            let listener = try NWListener(using: parameters, on: 8080)
            self.listener = listener
            
            listener.stateUpdateHandler = { state in
                switch state {
                case .ready:
                    print("Server ready on port \(listener.port!)")
                
                case .failed(let error):
                    print("Server failed with error: \(error)")
                default:
                    break
                }
            }
            listener.newConnectionHandler = {newConnection in
                newConnection.stateUpdateHandler = { newState in
                    switch newState {
                    case .ready:
                        print("listenerstateUpdateHandler")
                        self.handleConnection(connection: newConnection)
                        self.receiveFileList(connection: newConnection)
                        if let fileDirectories = self.fileDirectoryToSend {
                            self.fileDirectoryToSend = nil
                            self.sendFileList(newConnection, directoryPath: fileDirectories)
                        }
                    default:
                        break
                    }
                }
                newConnection.start(queue: .main)
            }
            listener.start(queue: .main)
        } catch {
            print("Failed to start server: \(error)")
        }
    }
    
    private func handleConnection(connection: NWConnection) {
        let response = """
            HTTP/1.1 200 OK\r
            Content-Type: text/html\r
            Content-Length: 46\r
            \r
            <html><body><h1>\(htmlString), world!</h1></body></html>
            """
        let responseData = response.data(using: .utf8)!
        
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { data, context, isComplete, error in
            if let data = data, !data.isEmpty {
                print("Received data: \(String(data: data, encoding: .utf8) ?? "")")
                connection.send(content: responseData, completion: .contentProcessed({ sendError in
                    if let sendError = sendError {
                        print("Failed to send response: \(sendError)")
                    }
                    connection.cancel()
                }))
                if self.message != "" {
                    print("sending a message")
                    let message = self.message
                    self.message = ""
                    let data = message.data(using: .utf8)!
                            let metadata = NWProtocolWebSocket.Metadata(opcode: .text)
                            let context = NWConnection.ContentContext(identifier: "context", metadata: [metadata])
                    connection.send(content: data, contentContext: context, isComplete: true, completion: .contentProcessed({ error in
                        print("sendmessage rrror ", error)
                    }))
                }
                
            }
        }
    }
    
    private func receiveFileList(connection:NWConnection) {
            connection.receive(minimumIncompleteLength: 1, maximumLength: 1024) { data, context, isComplete, error in
                if let data = data, !data.isEmpty {
                    if let fileList = String(data: data, encoding: .utf8) {
                        print("Received file list:\n\(fileList)")
                    }
                }

                if isComplete {
                }

                if let error = error {
                    print("Error receiving data: \(error)")
                    connection.cancel()
                }
            }
        }
    
    private func sendFileList(_ connection: NWConnection, directoryPath:String) {
        print("sendFileList")
            do {
                let fileManager = FileManager.default
                let files = try fileManager.contentsOfDirectory(atPath: directoryPath)
                let fileList = files.joined(separator: "\n")
                let data = fileList.data(using: .utf8) ?? Data()

                connection.send(content: data, completion: .contentProcessed({ sendError in
                    if let error = sendError {
                        print("Failed to send data: \(error)")
                    } else {
                        print("File list sent successfully")
                    }
                    connection.cancel()
                }))
            } catch {
                print("Failed to list directory contents: \(error)")
                connection.cancel()
            }
        }
}
