//
//  AddTournamentView.swift
//  MJS
//
//  Created by Robert Goedman on 3/25/24.
//

import SwiftUI
import SwiftData

struct AddTournamentView {
  @State private var fp: String = ""
  @State private var sp: String = ""
  @State private var tp: String = ""
  @State private var lp: String = ""
  @State var selectedRotation: RotateClockwiseType = .clockwise
  @State var selectedRuleSet: RuleSetType = .traditional
  @AppStorage("rotateClockwise") private var rotateClockwise: Bool = true
  @AppStorage("ruleSet") private var ruleSet: String = "Traditional"
  @Environment(\.scenePhase) private var scenePhase
  @FocusState private var focusedField
  @Environment(\.dismiss) private var dismiss
  @Environment(\.modelContext) private var context
}

extension AddTournamentView: View {
  var body: some View {
    VStack {
      Spacer()
      Text("Enter all 4 players, select rotation direction and rule set and press `save`.")
        .font(.title)
      Spacer()
      HStack {
        TextField("East wind player", text: $fp)
          .focused($focusedField)
          .multilineTextAlignment(.center)
          .font(.largeTitle)
      }
      HStack {
        TextField("Player to the right of East (South)", text: $sp)
          .multilineTextAlignment(.center)
          .font(.largeTitle)
      }
      HStack {
        TextField("Player to the right of South (West)", text: $tp)
          .multilineTextAlignment(.center)
          .font(.largeTitle)
      }
      HStack {
        TextField("Player to the right of West (North)", text: $lp)
          .multilineTextAlignment(.center)
          .font(.largeTitle)
      }
      Spacer()
      RotateClockwisePickerView(selectedRotation: $selectedRotation)
      Spacer()
      RuleSetPickerView(selectedRuleSet: $selectedRuleSet)
      Spacer()
      HStack {
        Spacer()
        Button("Cancel",
               role: .cancel) {
          dismiss()
        }
        .buttonStyle(.borderedProminent)
        Spacer()
        Button("Save",
               action: save)
        .disabled(fp.isEmpty || sp.isEmpty || tp.isEmpty || lp.isEmpty)
        .buttonStyle(.borderedProminent)
        Spacer()
      }
      .font(.largeTitle)
      Spacer()
    }
    .onAppear {
      focusedField = true
    }
  }
}

extension AddTournamentView {
  private func save() {
    focusedField = false
    let tournament = Tournament(fp, sp, tp, lp, fp, "East", fp)
    
    tournament.scheduleItem = 0
    tournament.players = [fp, sp, tp, lp]
    tournament.winds = ["East", "South", "West", "North"]
    let scores = [2000, 2000, 2000, 2000]
    tournament.playerTournamentScore = Dictionary(uniqueKeysWithValues: zip(tournament.players!, scores))
    tournament.playerGameScore = Dictionary(uniqueKeysWithValues: zip(tournament.players!, [0,0,0,0]))
    let tmp = tournament.windsAndPlayers(tournament.winds!, tournament.players!, 0)
    tournament.windsToPlayersInGame = Dictionary(uniqueKeysWithValues: zip(tmp.0, tmp.1))
    tournament.playersToWindsInGame = Dictionary(uniqueKeysWithValues: zip(tmp.1, tmp.0))
    tournament.currentWind = tmp.0[0]
    tournament.windPlayer = tmp.1[0]
    tournament.lastGame! += 1
    tournament.ruleSet = selectedRuleSet.description
    tournament.rotateClockwise = (selectedRotation == RotateClockwiseType.clockwise ? true : false)
    tournament.fpScores!.append(Score(fp, tournament.lastGame!, 2000))
    tournament.spScores!.append(Score(sp, tournament.lastGame!, 2000))
    tournament.tpScores!.append(Score(tp, tournament.lastGame!, 2000))
    tournament.lpScores!.append(Score(lp, tournament.lastGame!, 2000))
    context.insert(tournament)
    dismiss()
  }
}

//#Preview {
//  AddTournamentView()
//}
