//
//  Shaders.metal
//  2-ComputeShader
//
//  Created by Riku Takano on 2018/12/07.
//  Copyright © 2018 Riku Takano. All rights reserved.
//

#include <metal_stdlib>
#import "Loki/loki_header.metal"
using namespace metal;

kernel void monte_carlo(constant uint &width [[ buffer(0) ]],
                        device bool *outBools [[ buffer(1) ]],
                        uint3 gid [[ thread_position_in_grid ]]) {
    uint global_gid = gid.x + gid.y * width;
    const float x = Loki(gid.x, gid.y, 0).rand();
    const float y = Loki(gid.x, gid.y, 1).rand();
    outBools[global_gid] = (sqrt((x * x) + (y * y)) < 1.0) ? true : false;
}

float4 hsv2rgb(float h, float s, float v) {
    float3 rgb = float3(v, v, v);
    h *= 6;
    int i = (int)h;
    float f = h - i;
    switch (i) {
        case 0:
            rgb.g *= 1 - s * (1 - f);
            rgb.b *= 1 - s;
            break;
        case 1:
            rgb.r *= 1 - s * f;
            rgb.b *= 1 - s;
            break;
        case 2:
            rgb.r *= 1 - s;
            rgb.b *= 1 - s * (1 - f);
            break;
        case 3:
            rgb.r *= 1 - s;
            rgb.g *= 1 - s * f;
            break;
        case 4:
            rgb.r *= 1 - s * (1 - f);
            rgb.g *= 1 - s;
            break;
        case 5:
            rgb.g *= 1 - s;
            rgb.b *= 1 - s * f;
    }
    return float4(rgb, 1);
}

kernel void mandelbrot(texture2d<float, access::write> output [[texture(0)]],
                       uint2 gid [[thread_position_in_grid]]){
    const int NCOLOR = 256;
    
    float width = output.get_width();
    float height = output.get_height();
    float2 c = float2(gid) / float2(width, height);
    
    float2 z = float2(0, 0);
    int n = 0;
    while (n < (NCOLOR * 2 - 1) && length(z) <= 2) {
        float2 z1 = float2(z.x * z.x - z.y * z.y + c.x, 2 * z.x * z.y + c.y);
        z = z1;
        n++;
    }
    float v = 1 - (float)n / NCOLOR;
    float4 out_color = hsv2rgb(fmod(v + 0.6 + (n % 5 * 0.03), 1.0), 1, v);
    output.write(out_color, gid);
}

