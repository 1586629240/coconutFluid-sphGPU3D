#pragma once
#include "glRenderBase.h"

class SkyBoxRender : public glRenderBase
{
public:
    SkyBoxRender(std::string cubePrefix);
    ~SkyBoxRender();

    void renderdColorMap(Camera& c) override;
    void renderdDepthMap(Camera& c) override;

private:
    GLuint cubemapTexture;
    GLuint skyboxVAO, skyboxVBO;

    void loadCubemap(const std::vector<std::string>& faces);
};