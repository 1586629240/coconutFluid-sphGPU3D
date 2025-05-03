#include "gl/window.h"
#include "glRender/boxRender.h"
#include "SPH/SPHsystemCu.cuh"
#include <thrust/host_vector.h>
#include "gui/menuActProc.cuh"
#include "glRender/ballRender.h"
#include "glRender/fluidRender.h"

GLFWwindow* window = initGL();
LiquidRender liquidRender;
ScreenRender screenRender;
auto& world = WorldRender::getInstance();
auto& sphSys = SPHsystemCu::getInstance();
auto& fluidRender = FluidRender::getInstance();
auto sphRender = std::make_shared<ballRender>();

void renderLiquid()
{
    world.menuOffScreen(camera);
    fluidRender.renderdFluid(camera);
	liquidRender.notRenderNormal(true);
    liquidRender.draw(camera, fluidRender.getScreenBuffer(), world.getScreenBuffer());
    screenRender.draw(liquidRender.GetColorTexture(), 0);
}

void renderBalls()
{
	world.addObject("sph", sphRender);
	world.menuOnScreen(camera);
	world.removeObject("sph");
}

void renderNormal()
{
    world.menuOffScreen(camera);
    fluidRender.renderdFluid(camera);
    liquidRender.notRenderNormal(false);
    liquidRender.draw(camera, fluidRender.getScreenBuffer(), world.getScreenBuffer());
    screenRender.draw(liquidRender.GetColorTexture(), 0);
}

int rendering()
{
    sphSys.initDefaultSence();
    fluidRender.setBallR(sphSys.arg().ballR);
    thrust::host_vector<vec3f> host(sphSys.ballcnt());

    world.addObject("box", std::make_shared<boxRender>(vec4f{ 62.5f,20.f,62.5f,1.f }));

	auto menu=MenuManager::getInstance();
    while (!glfwWindowShouldClose(window))
    {
        menu.menuBeg();
        processInput(window);

        for (int i = 0; i < 10; i++)sphSys.update();

        host = sphSys.devPos();
        fluidRender.setBallPos((float*)host.data(), 3, host.size());
		sphRender->setBallPos((float*)host.data(), 3, host.size());

        procSkyBoxUpdate(menu, world);
        procForceUpdate(menu, sphSys);
		procColorUpdate(menu, liquidRender);
		procRenderdUpdate(menu, renderBalls, renderLiquid, renderNormal);

        menu.menuEnd();
        glfwSwapBuffers(window);
        glfwPollEvents();
    }

    glfwTerminate();
    return 0;
}

#include <ctime>

int profile()
{
    auto& sphSys = SPHsystemCu::getInstance();
    thrust::host_vector<vec3f> host(sphSys.ballcnt());
    sphSys.initDefaultSence();

    sphSys.update();
    return 0;
}

int main(int argc, const char* argv[])
{
     if (argc != 1)
         return profile();
     return rendering();
}