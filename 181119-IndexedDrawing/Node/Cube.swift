//
//  Cube.swift
//  SwiftIndex
//
//  Created by Riku Takano on 2018/11/19.
//  Copyright © 2018 Riku Takano. All rights reserved.
//

import MetalKit

class Cube: Primitive {
    
    let pi: Float32 = 3.14 * 2
    let N = 100
    
    override func buildVertices() {
        vertices = [
            Vertex(position: float3(0, 0, 0), color: float4(1, 1, 1, 1)),
        ]
        indices = []
        indices_vertex = []

        var angle: Float32 = 0
        let delta: Float32 = pi / Float32(N)
        for i in 0..<N {
            angle += delta
            vertices.append(Vertex(position: float3(sin(angle), cos(angle), 0), color: float4(1, 1, 1, 1)))
            indices.append(0)
            indices.append(UInt16(i+1))
            indices_vertex.append(UInt16(i+1))
        }

    }
}
