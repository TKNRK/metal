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
    vOut.pointsize = 5;
    return vOut;
}

fragment float4 basic_fragment_function(VertexOut vIn [[ stage_in ]]) {
    return vIn.color;
}


// Computation subroutine
kernel void compute(device VertexIn *vertices [[ buffer(0) ]],
                    device float *layout_hd [[ buffer(1) ]],
                    device float *projection [[ buffer(2) ]],
                    constant int &N [[ buffer(3) ]],
                    constant int &h_dim [[ buffer(4) ]],
                    uint gid [[ thread_position_in_grid ]]) {
    float pos_x = 0, pos_y = 0;

    for (int i=0; i < h_dim; i++) {
        pos_x += layout_hd[h_dim * gid + i] * projection[i];
        pos_y += layout_hd[h_dim * gid + i] * projection[i + h_dim];
    }

    vertices[gid].position = float3(pos_x * 0.3, pos_y * 0.3, 0);
}




