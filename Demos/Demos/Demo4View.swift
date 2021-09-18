//
//  Demo4View.swift
//  Demos
//
//  Created by Andy Ibanez on 9/16/21.
//

import SwiftUI

struct Videogame: Identifiable {
    let id = UUID()
    let title: String
    let year: Int
}

actor VideogameManager {
    var videogames: [Videogame] = []
    
    nonisolated func printInfo() {
        print("We have a lot of games!")
    }
    
    func addVideogame(title: String, year: Int) {
        videogames += [Videogame(title: title, year: year)]
    }
    
    func fetchVideogames() -> [Videogame] {
        return videogames
    }
}

@MainActor
class Demo4ViewModel: ObservableObject {
    
    let manager = VideogameManager()
    
    @Published var videogames: [Videogame] = []
    
    func fetchVideogames() async {
        videogames = await manager.fetchVideogames()
    }
    
    func addVideogame(title: String, year: Int) async {
        await manager.addVideogame(title: title, year: year)
        await fetchVideogames()
    }
    
    func printInfo() {
        manager.printInfo()
    }
}

struct Demo4View: View {
    @StateObject private var viewModel = Demo4ViewModel()
    
    @State private var title = ""
    @State private var year = ""
    
    var body: some View {
        VStack {
            List(viewModel.videogames) { vg in
                HStack(spacing: 8) {
                    Text(vg.title)
                    Text("\(vg.year)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            Spacer()
            VStack {
                HStack {
                    Text("Title")
                    TextField("Title", text: $title)
                }
                HStack {
                    Text("Year")
                    TextField("Year", text: $year)
                }
                Button {
                    Task {
                        await viewModel.addVideogame(title: title, year: Int(year) ?? 0)
                        title = ""
                        year = ""
                    }
                } label: {
                    Text("Add New Game")
                }
                
            }
        }
    }
}

struct Demo4View_Previews: PreviewProvider {
    static var previews: some View {
        Demo4View()
    }
}
