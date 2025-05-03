#version 330 core
out vec4 FragColor;

in vec3 position;

float lerp(float a, float b, float f)
{
    return a + f * (b - a);
}

void main()
{
    float gray = lerp(0.40,0.15,position.x)+0.2;
    FragColor = vec4(gray,gray,gray,1);
}