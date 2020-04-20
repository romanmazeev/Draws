//
//  TaskDataSource.swift
//  DrawerGame
//
//  Created by Roman Mazeev on 19.04.2020.
//  Copyright © 2020 Roman Mazeev. All rights reserved.
//

import Foundation

struct TaskDataSource {
    static var tasks: [String] {
        guard let path = Bundle.main.path(forResource: "classes", ofType: "txt") else { return [] }
        let data = try? String(contentsOfFile: path, encoding: .utf8)
        return data?.components(separatedBy: .newlines).filter { $0.count > 0 } ?? []
    }
}
