//
//  Types.swift
//  SwiftIndex
//
//  Created by Riku Takano on 2018/11/19.
//  Copyright © 2018 Riku Takano. All rights reserved.
//

import MetalKit

struct Vertex {
    var position: float3
    var color: float4
}

struct ModelConstraints {
    var modelMatrix = matrix_identity_float4x4
}

struct SceneConstraints {
    var projectionMatrix = matrix_identity_float4x4
}

protocol Constraintable {
    func scale(axis: float3)
    
    func translate(direction: float3)
    
    func rotate(angle: Float, axis: float3)
}
