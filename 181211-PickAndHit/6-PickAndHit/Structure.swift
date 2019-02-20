//
//  Structure.swift
//  6-PickAndHit
//
//  Created by Riku Takano on 2019/02/14.
//  Copyright © 2019 Riku Takano. All rights reserved.
//


import MetalKit

struct Vertex {
    var position: float3
    var color: float4
}

struct Pick {
    var mouse_x: Float
    var mouse_y: Float
    var pick_id: UInt16
}
