#pragma once

#include "../base/vec.cuh"
#include "glRenderBase.h"

class boxRender :public glRenderBase
{
	unsigned VBO;
	Shader depthShader;
	vec4f lightAttr;

public:
	boxRender(vec4f lightAttr);
	~boxRender() = default;

	void renderdColorMap(Camera& c) override;
	void renderdDepthMap(Camera& c) override;
	void setAttribute(vec4f pos);
};

