#include "menuActProc.cuh"
#include <thrust/device_vector.h>
#include "../SPH/Field3dCu.cuh"
#include "../glRender/skyBoxRender.h"

void procSkyBoxUpdate(MenuManager& m, WorldRender& world)
{
	static int skyBoxValue = -1;
	if (skyBoxValue == m.TypeSkyBox())return;

	skyBoxValue = m.TypeSkyBox();
	world.setObject("skyBox", std::make_shared<SkyBoxRender>(m.skyBoxName[skyBoxValue]));
}

void procRenderdUpdate(MenuManager& m, std::function<void()>renderBall, std::function<void()>renderLiquid, std::function<void()>renderNormal)
{
	switch (m.TypeFluid())
	{
	case 0:
		renderBall(); break;
	case 1:
		renderLiquid(); break;
	case 2:
		renderNormal(); break;
	default:break;
	}
}

void procColorUpdate(const MenuManager& m, LiquidRender& r)
{
	r.setColor(m.ColorFluid(), m.ColorLightDiff(), m.ColorLightAmbient(), m.ColorLightSpecular());
}

void procForceUpdate(MenuManager& m, SPHsystemCu& sphSys)
{
	if (!m.ForceChangedPeek())return;

	static bool oldForceScence[3];
	const bool* forceScence = m.TypeForceScence();

	auto& ballFieldAttrs = m.BallFieldAttrs();
	thrust::device_vector<Field3dCu*> fieldDev;

	unsigned fieldCount = forceScence[0] + forceScence[1];

	if (forceScence[2])
		fieldDev.assign(fieldCount + ballFieldAttrs.size(), nullptr);
	else
		fieldDev.assign(fieldCount, nullptr);

	if (forceScence[0])
	{
		SPHsystemCuKernel::GravityFieldFactory << <1, 1 >> > (
			thrust::raw_pointer_cast(fieldDev.data()));
		cudaDeviceSynchronize();
	}
	if (forceScence[1])
	{
		SPHsystemCuKernel::CycleFieldFactory << <1, 1 >> > (
			thrust::raw_pointer_cast(fieldDev.data() + forceScence[0]));
		cudaDeviceSynchronize();
	}
	if (forceScence[2])
		for (int i = 0; i < ballFieldAttrs.size(); i++)
		{
			auto& attr = ballFieldAttrs[i];
			SPHsystemCuKernel::BallFieldFactory << <1, 1 >> > (
				thrust::raw_pointer_cast(fieldDev.data() + i + fieldCount),
				attr.position[0], attr.position[1], attr.position[2], attr.radius);
			cudaDeviceSynchronize();
		}

	sphSys.setField(fieldDev);
}