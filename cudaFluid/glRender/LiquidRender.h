#pragma once
#include <GL/glew.h>
#include "../gl/shader.h"
#include "./ScreenRender.h"
#include "../gl/OffScreenBuffer.h"
#include "../gl/Camera.h"

class LiquidRender
{
    ScreenRender mesh;
    OffScreenBuffer screenBuffer;
    Shader liquidShader, blurShader;

	glm::vec4 liquidColor;
	glm::vec3 lightColor;
	glm::vec3 lightAmbient;
	glm::vec3 lightSpecular;

    void blurTexture(GLuint tex, glm::mat4 projectMat);

public:
    void notRenderNormal(bool flag);
    void setColor(const glm::vec4& fluidColor, const glm::vec3& lightColor, const  glm::vec3& lightAmbient, const glm::vec3& lightSpecular)
    {
        this->lightColor = lightColor;
        this->liquidColor = fluidColor;
		this->lightAmbient = lightAmbient;
		this->lightSpecular = lightSpecular;
    }
    LiquidRender();
    void draw(Camera& c, OffScreenBuffer& sphBuffer, OffScreenBuffer& bgBuffer);
    GLuint GetColorTexture();
};
