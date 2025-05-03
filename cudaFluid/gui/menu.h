#pragma once
#include <vector>
#include <string>
#include <glm/glm.hpp>

struct BallFieldAttr {

    float position[3] = { 250,50,250 };
    float radius = 50;
};

class fpsBuffer
{
private:
	int size;
	std::vector<float> data;
public:
	fpsBuffer(int size) : size(size)
	{
		data.resize(size);
	}
	void push(float value)
	{
		std::memcpy(data.data(), data.data() + 1, (size - 1) * sizeof(float));
		data[size - 1] = value;
	}
	float* Data()
	{
		return data.data();
	}
	int Size() const
	{
		return size;
	}
};

class MenuManager 
{
private:
    MenuManager();

    int skyBox;
    int fluidType;
    int ballForceIdx;

    bool forceChanged;
    bool forceScence[3];
    bool ballAttrInputBySlider;

    fpsBuffer fpsBuffer;

    glm::vec3 lightDiff = { 1,1,1 };
    glm::vec3 lightAmbient = { 1,1,1 };
    glm::vec3 lightSpecular = { 1,1,1 };
    glm::vec4 fluidColor = { .22, .59, .90,1 };

    std::vector<std::string> ballFieldNames;
    std::vector<BallFieldAttr> ballFieldAttrs;
    std::vector<char*> ballFieldNamesCstr;
public:
    const char* skyBoxName[4] = { "port", "pond", "pool", "sky" };
    const char* forceSceneTy[3] = { "g", "roll", "balls" };
    const char* fluidTypeName[4] = { "ball", "water", "normal" };

private:
    void addBall();
    void removeBall();
    void showBallAttr();
    void menuFluidType();
    void menuSkyBox();
    void menuForceField();
    void menuFluidColor();
    void menuFPS();
    void menuAllBall();
public:
    void menuBeg();
    void menuEnd();

    static MenuManager& getInstance();

    int TypeFluid() const;
    int TypeSkyBox() const;
    const bool* TypeForceScence() const;
    const std::vector<BallFieldAttr>& BallFieldAttrs() const;

	const glm::vec4& ColorFluid() const;
	const glm::vec3& ColorLightDiff() const;
	const glm::vec3& ColorLightAmbient() const;
	const glm::vec3& ColorLightSpecular() const;

    bool ForceChangedPeek();
};