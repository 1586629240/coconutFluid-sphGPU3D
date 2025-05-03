#include "fluidRender.h"

void FluidRender::drawSPHBalls()
{
	glBindBuffer(GL_ARRAY_BUFFER, VBO);
	for (unsigned int i = 0; i < obj.meshes.size(); i++)
	{
		glBindVertexArray(obj.meshes[i].VAO);
		glDrawElementsInstanced(GL_TRIANGLES, static_cast<unsigned int>(obj.meshes[i].indices.size()), GL_UNSIGNED_INT, 0, ballCnt);
	}
	glBindVertexArray(0);
}

void FluidRender::setColorCamUniforms(Camera& c) //just for only draw balls
{
	shader.use();
	glm::mat4 projection = c.getProjectionMatrix();
	glm::mat4 view = c.GetViewMatrix();

	shader.setVec4("lightAttr", glm::make_vec4(lightAttr.data()));
	shader.setMat4f("projection", glm::value_ptr(projection));
	shader.setMat4f("view", glm::value_ptr(view));
}

void FluidRender::setFluidCamUniforms(Camera& c)
{
	float densityLowerBound = 1.0f / (8.0f * pow(ballR, 3.0f)) * 0.001f;
	glm::mat4 projection = c.getProjectionMatrix();
	glm::mat4 view = c.GetViewMatrix();

	fluidShader.use();
	fluidShader.setFloat("farPlane", 0.1);
	fluidShader.setFloat("nearPlane", 1000);
	fluidShader.setFloat("pointScale", 0.2);
	fluidShader.setFloat("pointSize", 4.0f * ballR);
	fluidShader.setFloat("densityLowerBound", densityLowerBound);
	fluidShader.setMat4f("viewMatrix", glm::value_ptr(view));
	fluidShader.setMat4f("projectMatrix", glm::value_ptr(projection));
}

FluidRender::FluidRender() :
	glRenderBase("./assert/object/ball.obj", "./assert/shader/ball.vert", "./assert/shader/ball.frag"),
	fluidShader("./assert/shader/sphFluid.vert", "./assert/shader/sphFluid.frag"),
	fluidFrame(1920, 1080)
{
	glGenBuffers(1, &VBO);
	glBindBuffer(GL_ARRAY_BUFFER, VBO);

	for (unsigned int i = 0; i < obj.meshes.size(); i++)
	{
		glBindVertexArray(obj.meshes[i].VAO);

		glEnableVertexAttribArray(3);
		glVertexAttribPointer(3, 3, GL_FLOAT, GL_FALSE, sizeof(vec3f), (void*)0);
		glVertexAttribDivisor(3, 1);

		glBindVertexArray(0);
	}
	lightAttr = vec4f::Zero();
	ballR = 1000;
}

OffScreenBuffer& FluidRender::getScreenBuffer()
{
	return fluidFrame;
}

FluidRender& FluidRender::getInstance()
{
	static FluidRender instance;
	return instance;
}

void FluidRender::setBallR(float r)
{
	ballR = r;
}

void FluidRender::setLightAttr(vec4f lightAttr)
{
	this->lightAttr = lightAttr;
}

void FluidRender::setBallPos(const float* rawData, unsigned vecDim, unsigned len)
{
	if (vecDim == 3)
	{
		ballCnt = len;
		glBindBuffer(GL_ARRAY_BUFFER, VBO);
		glBufferData(GL_ARRAY_BUFFER, ballCnt * sizeof(vec3f), rawData, GL_STATIC_DRAW);
	}
	else
		throw std::runtime_error("vecDim must be 3");
}

FluidRender::~FluidRender()
{
	glDeleteBuffers(1, &VBO);
}

void FluidRender::renderdFluid(Camera& c)
{
	fluidFrame.bind();

	glEnable(GL_DEPTH_TEST);
	glEnable(GL_STENCIL_TEST);
	glDisable(GL_BLEND);
	glClear(GL_DEPTH_BUFFER_BIT);
	glEnable(GL_PROGRAM_POINT_SIZE);
	glEnable(GL_VERTEX_PROGRAM_POINT_SIZE);

	fluidShader.use();
	setFluidCamUniforms(c);
	drawSPHBalls();
	glDisable(GL_PROGRAM_POINT_SIZE);

	fluidFrame.unbind();
}

void FluidRender::renderdColorMap(Camera& c)
{
	glClearColor(0.1, 0.1, 0.1, 1.0);
	setColorCamUniforms(c);
	drawSPHBalls();
}