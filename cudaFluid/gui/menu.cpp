#include "menu.h"
#include "../imgui/imgui.h"
#include "../imgui/imgui_impl_glfw.h"
#include "../imgui/imgui_impl_opengl3.h"
#include <vector>
#include <string>
#include <algorithm>
#include "../base/SPHConstantCu.cuh"

MenuManager::MenuManager() : 
    fluidType(0), skyBox(-1), ballForceIdx(-1),
	ballAttrInputBySlider(true), forceChanged(false), fpsBuffer(50)
{
    std::fill_n(forceScence, 3, false);
}

void MenuManager::addBall()
{
    ballFieldAttrs.emplace_back();
    ballFieldNames.emplace_back("ball" + std::to_string(ballFieldAttrs.size()));

	char* tmpStr = new char[ballFieldNames.back().size() + 1];
	std::copy(ballFieldNames.back().begin(), ballFieldNames.back().end(), tmpStr);
    ballFieldNamesCstr.push_back(tmpStr);

    ballForceIdx = static_cast<int>(ballFieldAttrs.size()) - 1;
}

void MenuManager::removeBall()
{
    if (ballForceIdx >= 0)
    {
		delete[] ballFieldNamesCstr[ballForceIdx];

        ballFieldAttrs.erase(ballFieldAttrs.begin() + ballForceIdx);
        ballFieldNames.erase(ballFieldNames.begin() + ballForceIdx);
        ballFieldNamesCstr.erase(ballFieldNamesCstr.begin() + ballForceIdx);
        ballForceIdx = -1;
    }
}

void MenuManager::showBallAttr()
{
    float maxBoundry = std::max(BOUNDRY_X, std::max(BOUNDRY_Y, BOUNDRY_Z));
    for (int i = 0; i < ballFieldAttrs.size(); ++i)
    {
        auto& currentBall = ballFieldAttrs[i];
        ImGui::Separator();
        ImGui::Text(ballFieldNames[i].c_str());
        if (ballAttrInputBySlider)
        {
            ImGui::PushID(i);
            ImGui::SliderFloat3("pos", currentBall.position, 0.0f, maxBoundry);
			ImGui::SliderFloat("Radius", &currentBall.radius, 0.0f, 200);
			ImGui::PopID();
        }
        else
        {
            ImGui::PushID(i);
            ImGui::InputFloat3("Position", currentBall.position);
            ImGui::InputFloat("Radius", &currentBall.radius);
			ImGui::PopID();
        }

        currentBall.position[0] = std::max(0.0f, std::min(currentBall.position[0], static_cast<float>(BOUNDRY_X)));
        currentBall.position[1] = std::max(0.0f, std::min(currentBall.position[1], static_cast<float>(BOUNDRY_Y)));
        currentBall.position[2] = std::max(0.0f, std::min(currentBall.position[2], static_cast<float>(BOUNDRY_Z)));
        currentBall.radius = std::max(0.0f, std::min(currentBall.radius, 200.0f));
    }
}

void MenuManager::menuFluidType()
{
    ImGui::Text("FLUID TYPE");
    ImGui::RadioButton(fluidTypeName[0], &fluidType, 0);
    ImGui::SameLine();
    ImGui::RadioButton(fluidTypeName[1], &fluidType, 1);
    ImGui::SameLine();
    ImGui::RadioButton(fluidTypeName[2], &fluidType, 2);
}

void MenuManager::menuSkyBox()
{
    ImGui::Text("SKY BOX");
    ImGui::RadioButton(skyBoxName[0], &skyBox, 0);
    ImGui::SameLine();
    ImGui::RadioButton(skyBoxName[1], &skyBox, 1);
    ImGui::SameLine();
    ImGui::RadioButton(skyBoxName[2], &skyBox, 2);
    ImGui::SameLine();
    ImGui::RadioButton(skyBoxName[3], &skyBox, 3);
}

void MenuManager::menuForceField()
{
    ImGui::Text("FORCE SCENE");
    ImGui::Checkbox(forceSceneTy[0], &forceScence[0]);
    ImGui::SameLine();
    ImGui::Checkbox(forceSceneTy[1], &forceScence[1]);
    ImGui::SameLine();
    ImGui::Checkbox(forceSceneTy[2], &forceScence[2]);
    ImGui::Checkbox("change immediately", &forceChanged);
}

void MenuManager::menuFluidColor()
{
    ImGui::ColorEdit3("fluid color", &fluidColor[0]);

    ImGui::Separator(); 
    ImGui::Text("Light color");
    ImGui::ColorEdit3("diffuse", &lightDiff[0]);
    ImGui::ColorEdit3("ambient", &lightAmbient[0]);
    ImGui::ColorEdit3("specular", &lightSpecular[0]);
}

void MenuManager::menuFPS()
{
    ImGui::Text("FPS: %.1f", ImGui::GetIO().Framerate);
	fpsBuffer.push(ImGui::GetIO().Framerate);
	ImGui::GetFrameHeight();
    ImGui::PlotLines("##FrameTime", fpsBuffer.Data(), fpsBuffer.Size(), 0, 0, FLT_MAX, FLT_MAX, ImVec2(-1, 60));
}

void MenuManager::menuAllBall()
{
    if (!forceScence[2])return;

    ImGui::Combo("ball", &ballForceIdx, ballFieldNamesCstr.data(), static_cast<int>(ballFieldNamesCstr.size()));

    if (ImGui::Button("add ball"))addBall();
    ImGui::SameLine();
    if (ImGui::Button("delete ball"))removeBall();
    ImGui::SameLine();
    ImGui::Checkbox("Slider", &ballAttrInputBySlider);

    showBallAttr();
}

void MenuManager::menuBeg()
{
    ImGui_ImplOpenGL3_NewFrame();
    ImGui_ImplGlfw_NewFrame();
    ImGui::NewFrame();

    ImGui::Begin("Control");

    ImGui::BeginTabBar("MyTabBar");
    if (ImGui::BeginTabItem("Main")) 
    {
        menuFPS();
        ImGui::Separator(); menuFluidType();
        ImGui::Separator(); menuSkyBox();
        ImGui::Separator(); menuForceField();
        ImGui::EndTabItem();
    }
    if (ImGui::BeginTabItem("Light")) 
    {
        menuFluidColor();
        ImGui::EndTabItem();
    }
    if (forceScence[2]&&ImGui::BeginTabItem("Ball"))
    {
        menuAllBall();
        ImGui::EndTabItem();
    }

    ImGui::EndTabBar();
}

void MenuManager::menuEnd()
{  
    ImGui::End();
    ImGui::Render();
	ImGui_ImplOpenGL3_RenderDrawData(ImGui::GetDrawData());
}

MenuManager& MenuManager::getInstance()
{
    static MenuManager instance;
    return instance;
}

int MenuManager::TypeFluid() const { return fluidType; }

int MenuManager::TypeSkyBox() const { return skyBox; }

const bool* MenuManager::TypeForceScence() const { return forceScence; }

const std::vector<BallFieldAttr>& MenuManager::BallFieldAttrs() const { return ballFieldAttrs; }

const glm::vec4& MenuManager::ColorFluid() const { return fluidColor; }

const glm::vec3& MenuManager::ColorLightDiff() const { return lightDiff; }

const glm::vec3& MenuManager::ColorLightAmbient() const { return lightAmbient; }

const glm::vec3& MenuManager::ColorLightSpecular() const { return lightSpecular; }

 bool MenuManager::ForceChangedPeek() {return forceChanged; }
