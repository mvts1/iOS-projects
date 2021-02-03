//
//  EnemyType.swift
//  CylonHunt
//
//  Created by Onur Mavitas on 28.01.2021.
//

import SpriteKit

struct EnemyType: Codable {
    let name: String
    let shields: Int
    let speed: CGFloat //speed is stored as CGFloat in SpriteKit
    let powerUpChance: Int
}
