//
//  Constants.swift
//  Annotator
//
//  Created by Philip Kluz on 2018-11-25.
//  Copyright © 2018 Philip Kluz. All rights reserved.
//

import Foundation

internal let defaultDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd-HH:mm:ss.SSSZ"
    return formatter
}()
