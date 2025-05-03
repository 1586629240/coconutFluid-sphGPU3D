#include "ballRender.h"

ballRender::ballRender() :glRenderBase("./assert/object/ball.obj", "./assert/shader/ball.vert", "./assert/shader/ball.frag")
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
}

void ballRender::setBallPos(const float* rawData, unsigned vecDim, unsigned len)
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

void ballRender::setLightAttr(vec4f lightAttr)
{
	this->lightAttr = lightAttr;
}

void ballRender::renderdColorMap(Camera& c)
{
	glClearColor(0.1, 0.1, 0.1, 1.0);
	glEnable(GL_DEPTH_TEST);
	shader.use();
	glm::mat4 projection = c.getProjectionMatrix();
	glm::mat4 view = c.GetViewMatrix();

	shader.setVec4("lightAttr", glm::make_vec4(lightAttr.data()));
	shader.setMat4f("projection", glm::value_ptr(projection));
	shader.setMat4f("view", glm::value_ptr(view));

	glBindBuffer(GL_ARRAY_BUFFER, VBO);
	for (unsigned int i = 0; i < obj.meshes.size(); i++)
	{
		glBindVertexArray(obj.meshes[i].VAO);
		glDrawElementsInstanced(GL_TRIANGLES, static_cast<unsigned int>(obj.meshes[i].indices.size()), GL_UNSIGNED_INT, 0, ballCnt);
	}
	glBindVertexArray(0);
}
