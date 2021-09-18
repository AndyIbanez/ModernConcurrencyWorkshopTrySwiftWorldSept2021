//
//  Demo3View.swift
//  Demos
//
//  Created by Andy Ibanez on 9/16/21.
//

import SwiftUI
import UIKit

fileprivate enum ImageError: Error {
    case badImage
}

fileprivate enum ImageStatus {
    case downloading
    case downloaded(_ image: UIImage)
    case error(_ error: Error)
}

@MainActor
fileprivate class Demo3ViewModel: ObservableObject {
    @Published var imageStatus: ImageStatus = .downloading
    private var downloadTask: Task<Void, Never>?
    
    func downloadImage() async {
        imageStatus = .downloading
        downloadTask = Task {
            let url = URL(string: "https://images.unsplash.com/photo-1536590158209-e9d615d525e4?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=3648&q=80")!
            do {
                let image = try await downloadImage(url: url)
                imageStatus = .downloaded(image)
            } catch {
                imageStatus = .error(error)
            }
        }
    }
    
    func downloadImage(url: URL) async throws -> UIImage {
        try Task.checkCancellation() // <- Checking for cancellation early on.
        let session = URLSession(configuration: .ephemeral)
        let (data, _) = try await session.data(from: url, delegate: nil)
        guard let image = UIImage(data: data) else {
            throw ImageError.badImage
        }
        return image
    }
    
    func cancelDownload() {
        downloadTask?.cancel()
    }
}

struct Demo3View: View {
    @StateObject private var viewModel = Demo3ViewModel()
    
    var body: some View {
        VStack {
            switch viewModel.imageStatus {
            case .downloading:
                ProgressView()
            case .downloaded(let image):
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            case .error(let error):
                viewFor(error: error)
            }
          Spacer()
            HStack {
                Spacer()
                switch viewModel.imageStatus {
                case .downloaded(_):
                    Button {
                        Task {
                            await viewModel.downloadImage()
                        }
                    } label: {
                        Text("Image Downloaded")
                    }
                case .error(_):
                    Button {
                        Task {
                            await viewModel.downloadImage()
                        }
                    } label: {
                        Text("Retry")
                    }
                case .downloading:
                    Button {
                        viewModel.cancelDownload()
                    } label: {
                        Text("Cancel task")
                    }
                }
                Spacer()
            }
            HStack {
                Spacer()
                Text("Image by: @zoegayah (Unsplash)")
            }
        }
        .task {
            await viewModel.downloadImage()
        }
    }
    
    @ViewBuilder
    func viewFor(error: Error) -> some View {
        HStack {
            Image(systemName: "xmark")
            Text(error.localizedDescription)
        }
        .padding()
        .foregroundColor(.red)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct Demo3View_Previews: PreviewProvider {
    static var previews: some View {
        Demo3View()
    }
}
