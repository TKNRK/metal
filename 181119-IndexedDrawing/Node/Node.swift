//
//  Node.swift
//  SwiftIndex
//
//  Created by Riku Takano on 2018/11/19.
//  Copyright © 2018 Riku Takano. All rights reserved.
//

import MetalKit

class Node {
    var childern: [Node] = []
    
    func add(child: Node) {
        childern.append(child)
    }
    
    func render(commandEncoder: MTLRenderCommandEncoder, deltaTime: Float) {
        childern.forEach{ $0.render(commandEncoder: commandEncoder, deltaTime: deltaTime) }
    }
}
