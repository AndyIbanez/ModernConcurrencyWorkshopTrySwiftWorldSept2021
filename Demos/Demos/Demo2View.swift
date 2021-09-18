//
//  Demo2View.swift
//  Demos
//
//  Created by Andy Ibanez on 9/15/21.
//

import SwiftUI
import SwiftUI

private enum ImageError: Error {
    case badImage
}

private struct WebImage: Identifiable {
    let id = UUID()
    let image: UIImage
}

private enum LoadingStatus {
    case loading
    case finished
}

@MainActor
private class Demo2ViewModel: ObservableObject {
    @Published var images: [WebImage] = []
    @Published var loadingStatus: LoadingStatus = .loading
    
    private func downloadImage(url: URL) async throws -> UIImage {
        let session = URLSession(configuration: .ephemeral)
        let (data, _) = try await session.data(from: url, delegate: nil)
        guard let image = UIImage(data: data) else {
            throw ImageError.badImage
        }
        return image
    }
    
    private func downloadImages(from urls: [URL]) async -> [WebImage] {
        var images = [WebImage]()
        await withTaskGroup(of: WebImage?.self) { group in
            for url in urls {
                group.addTask(priority: .userInitiated) {
                    do {
                        let image = WebImage(image: try await self.downloadImage(url: url))
                        return image
                    } catch {
                        // ... Don't handle the error for now.
                        return nil
                    }
                }
                for await image in group {
                    if let image = image {
                        images += [image]
                    }
                }
            }
        }
        return images
    }
    
    func downloadImages(from urls: [URL]) async {
        loadingStatus = .loading
        self.images = await downloadImages(from: urls)
        loadingStatus = .finished
    }
}

struct Demo2View: View {
    @StateObject private var viewModel = Demo2ViewModel()
    
    var body: some View {
        if viewModel.loadingStatus == .loading {
            ProgressView()
                .task {
                    await viewModel.downloadImages(from: urls)
                }
        } else {
            ScrollView {
                HStack {
                    Spacer()
                }
                ForEach(viewModel.images) { image in
                    Image(uiImage: image.image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                }
            }
        }
    }
    
    var urls: [URL] {
        [
            URL(string: "https://www.andyibanez.com/fairesepages.github.io/tutorials/async-await/part3/1.png")!,
            URL(string: "https://www.andyibanez.com/fairesepages.github.io/tutorials/async-await/part3/2.png")!,
            URL(string: "https://www.andyibanez.com/fairesepages.github.io/tutorials/async-await/part3/3.png")!
        ]
    }
}

struct Demo2View_Previews: PreviewProvider {
    static var previews: some View {
        Demo2View()
    }
}
