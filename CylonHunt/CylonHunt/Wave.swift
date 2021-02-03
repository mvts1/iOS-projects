//
//  Wave.swift
//  CylonHunt
//
//  Created by Onur Mavitas on 28.01.2021.
//

import SpriteKit

struct Wave: Codable {
    struct WaveEnemy: Codable {
        let position: Int
        let xOffset: CGFloat
        let moveStraight: Bool
    }
    
    let name: String
    let enemies: [WaveEnemy]
    
}
