shader_type canvas_item;

uniform float pixel_size : hint_range(1.0, 64.0) = 8.0;

void fragment() {
    // Get the screen UV coordinates of the current pixel
    vec2 uv = UV;
    
    // Scale the UV coordinates to create the pixelation effect
    vec2 pixelated_uv = floor(uv * pixel_size) / pixel_size;

    // Sample the texture using the pixelated UV coordinates
    COLOR = texture(TEXTURE, pixelated_uv);
}
