//
//  ContentView.swift
//  iosevka
//
//  Created by Zaymon Antonio on 5/10/2023.
//

import SwiftUI

struct ContentView: View {
  var gameBoard = GameBoard(size: 4)

  var body: some View {
    GameBoardView(gameBoard: gameBoard)
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      ContentView()
    }.padding(16)
  }
}
