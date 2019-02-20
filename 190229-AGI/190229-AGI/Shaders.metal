//
//  Shaders.metal
//  190229-AGI
//
//  Created by Riku Takano on 2019/02/20.
//  Copyright © 2019 Riku Takano. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float3 position;
    float4 color;
};

struct VertexOut {
    float4 position [[ position ]];
    float4 color;
    float pointsize [[ point_size ]];
};

vertex VertexOut basic_vertex_function(const device VertexIn *vertices [[ buffer(0) ]],
                                       uint vertexID [[ vertex_id  ]]) {
    VertexOut vOut;
    vOut.position = float4(vertices[vertexID].position,1);
    vOut.color = vertices[vertexID].color;
    vOut.pointsize = 20;
    return vOut;
}

fragment float4 basic_fragment_function(VertexOut vIn [[ stage_in ]]) {
    return vIn.color;
}


// Computation subroutine
//kernel void compute(constant uint &N [[ buffer(0) ]],
//                    device VertexIn *layoutHD [[ buffer(1) ]],
//                    device VertexIn *projection [[ buffer(2) ]],
//                    device VertexIn *vertices [[ buffer(3) ]],
//                    uint gid [[ thread_position_in_grid ]]) {
//    vertices[gid].position = layoutHD[gid * N] * projection[gid];
//}




