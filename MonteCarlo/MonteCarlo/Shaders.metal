//
//  Shaders.metal
//  MonteCarlo
//
//  Created by Riku Takano on 2018/12/01.
//  Copyright © 2018 Riku Takano. All rights reserved.
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
};

vertex VertexOut basic_vertex_function(const device VertexIn *vertices [[ buffer(0) ]],
                                       uint vertexID [[ vertex_id  ]]) {
    VertexOut vOut;
    vOut.position = float4(vertices[vertexID].position,1);
    vOut.color = vertices[vertexID].color;
    return vOut;
}

fragment float4 basic_fragment_function(VertexOut vIn [[ stage_in ]]) {
    return vIn.color;
}

kernel void monte_carlo(const device float2 *inPoints [[ buffer(1) ]],
                        device bool *outBools [[ buffer(2) ]],
                        uint id [[ thread_position_in_grid ]]) {
    const float2 location = inPoints[id];
    const float x = location.x;
    const float y = location.y;
    outBools[id] = (sqrt((x * x) + (y * y)) < 1.0) ? true : false;
}
