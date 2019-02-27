//
//  Structures.swift
//  190229-AGI
//
//  Created by Riku Takano on 2019/02/20.
//  Copyright © 2019 Riku Takano. All rights reserved.
//

import MetalKit

struct Vertex {
    var position: float3
    var color: float4
}

//struct Pick {
//    var mouse_x: Float
//    var mouse_y: Float
//    var pick_id: UInt16
//}


struct AGI_static {
    var N: Int
    var h_dim: Int
    var layoutHD: Array<Float>
    var projection: Array<Float>
}
