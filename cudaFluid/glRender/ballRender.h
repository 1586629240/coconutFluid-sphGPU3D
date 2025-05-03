#pragma once
#include "../base/vec.cuh"
#include "glRenderBase.h"

class ballRender :public glRenderBase
{
	vec4f lightAttr;
	unsigned ballCnt = 0, VBO;

public:
	ballRender();
	void setBallPos(const float* rawData, unsigned vecDim, unsigned len);
	void setLightAttr(vec4f lightAttr);
	void renderdColorMap(Camera& c) override;
};