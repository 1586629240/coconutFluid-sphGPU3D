#pragma once

#include "../base/vec.cuh"
#include "glRenderBase.h"
#include "./LiquidRender.h"

class FluidRender :public glRenderBase
{
private:
	float ballR;
	vec4f lightAttr; //{x,y,z,hue}

	unsigned ballCnt = 0, VBO;

    Shader fluidShader;
    ScreenRender screenRender;
    OffScreenBuffer fluidFrame;

    void drawSPHBalls();
    void setColorCamUniforms(Camera& c);
    void setFluidCamUniforms(Camera& c);

public:
    void renderdFluid(Camera& c);
	void renderdColorMap(Camera& c) override;

    OffScreenBuffer& getScreenBuffer();

	void setBallR(float r);
	void setLightAttr(vec4f lightAttr);
	void setBallPos(const float* rawData, unsigned vecDim, unsigned len);

	FluidRender();
	static FluidRender& getInstance();
	FluidRender(const FluidRender&) = delete;
	FluidRender& operator=(const FluidRender&) = delete;

	~FluidRender();
};