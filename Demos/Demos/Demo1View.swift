//
//  Demo1View.swift
//  Demos
//
//  Created by Andy Ibanez on 9/15/21.
//

import SwiftUI
import UIKit

private enum ImageError: Error {
    case badImage
}

@MainActor
private class Demo1ViewModel: ObservableObject {
    
    @Published var image1: UIImage?
    @Published var image2: UIImage?
    @Published var image3: UIImage?
    
    func downloadImage(url: URL) async throws -> UIImage {
        let session = URLSession(configuration: .ephemeral)
        let (data, _) = try await session.data(from: url, delegate: nil)
        guard let image = UIImage(data: data) else {
            throw ImageError.badImage
        }
        return image
    }
    
    func downloadAllImages() async {
        do {
            let url1 = URL(string: "https://www.andyibanez.com/fairesepages.github.io/tutorials/async-await/part3/1.png")!
            let url2 = URL(string: "https://www.andyibanez.com/fairesepages.github.io/tutorials/async-await/part3/2.png")!
            let url3 = URL(string: "https://www.andyibanez.com/fairesepages.github.io/tutorials/async-await/part3/3.png")!
            let img1 = try await downloadImage(url: url1)
            let img2 = try await downloadImage(url: url2)
            let img3 = try await downloadImage(url: url3)
            image1 = img1
            image2 = img2
            image3 = img3
        } catch {
            // Handle error
        }
    }
}

struct Demo1View: View {
    @StateObject private var viewModel = Demo1ViewModel()
    var body: some View {
        let columns: [GridItem] = [.init(.flexible()), .init(.flexible()), .init(.flexible())]
        ScrollView {
            LazyVGrid(
                columns: columns) {
                    if let img1 = viewModel.image1 {
                        Image(uiImage: img1)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else {
                        ProgressView()
                    }
                    
                    if let img2 = viewModel.image2 {
                        Image(uiImage: img2)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else {
                        ProgressView()
                    }
                    
                    if let img3 = viewModel.image3 {
                        Image(uiImage: img3)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else {
                        ProgressView()
                    }
                }
        }
        .task {
            await viewModel.downloadAllImages()
        }
    }
}

struct Demo1View_Previews: PreviewProvider {
    static var previews: some View {
        Demo1View()
    }
}
