#pragma once
#include "menu.h"
#include "../SPH/SPHsystemCu.cuh"
#include "../glRender/worldRender.h"
#include "../glRender/LiquidRender.h"

void procForceUpdate(MenuManager& m, SPHsystemCu& sphSys);
void procSkyBoxUpdate(MenuManager& m, WorldRender& world);
void procColorUpdate(const MenuManager& m, LiquidRender& r);

void procRenderdUpdate(
	MenuManager& m, 
	std::function<void()> renderBall, 
	std::function<void()> renderLiquid, 
	std::function<void()> renderNormal);