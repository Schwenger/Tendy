//
//  CurrentWorkDayViews.swift
//  SimpleTimeTracker
//
//  Created by Maximilian Schwenger on 12.05.22.
//

import SwiftUI

extension Past {
  var clockInOutButtonLabel: Label<Text, Image> {
    let imageSuffix = self.canTriggerWork ? ".fill" : ""
    let inOut: String
    switch settings.clockState {
    case .Fresh: inOut = "In"
    case .ClockedIn, .InBreak: inOut = "Out"
    case .ClockedOut: inOut = "Back In"
    }
    let imagePrefix: String
    switch settings.clockState {
    case .Fresh: imagePrefix = "sunrise"
    case .ClockedIn, .InBreak: imagePrefix = "sunset"
    case .ClockedOut: imagePrefix = "moon"
    }
    
    return Label(LocalizedStringKey("Clock \(inOut)"), systemImage: imagePrefix + imageSuffix)
  }
  
  var breakInOutButtonLabel: Label<Text, Image> {
    let imageSuffix = self.canTriggerBreak ? ".fill" : ""
    let inOut = self.inBreak ? "End" : "Start"
    let imagePrefix = self.inBreak ? "play" : "cup.and.saucer"
    
    return Label(LocalizedStringKey("\(inOut) Break"), systemImage: imagePrefix + imageSuffix)
  }
}
