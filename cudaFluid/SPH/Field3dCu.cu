#include "Field3dCu.cuh"

__device__ float t;

__device__ vec3f Field3dCu::sampleImpl(const vec3f& pos) 
{
	return vec3f::Zero();
}

Field3dCu::Field3dCu() {}

Field3dCu::~Field3dCu() {}

__device__ void Field3dCu::enable() { activated = true; }

__device__ void Field3dCu::disable() { activated = false; }

__device__ vec3f Field3dCu::sample(const vec3f& pos) 
{
	if (activated)return sampleImpl(pos);
	else return vec3f::Zero();
}

__device__ void Field3dCu::update() {}

Field3dPosCu::Field3dPosCu(float x_, float y_, float z_, float r_)
{
	r = r_;
	x = x_, y = y_, z = z_;
}

Field3dPosCu::~Field3dPosCu() {}

__device__ void Field3dPosCu::setRadius(float r) { this->r = r; }

__device__ void Field3dPosCu::update(float x_, float y_, float z_) { x = x_, y = y_, z = z_; }

gravityFieldCu::gravityFieldCu() {}

gravityFieldCu::~gravityFieldCu() {}

__device__ vec3f gravityFieldCu::sampleImpl(const vec3f& pos)
{
	return vec3f(0, -9.8, 0);
}

ballFieldCu::ballFieldCu(float x, float y, float z, float r) : Field3dPosCu(x, y, z, r) {}

ballFieldCu::~ballFieldCu() {}

__device__ void ballFieldCu::negative() { sign = -sign; }

__device__ void ballFieldCu::setStrength(float strength_) { strength = strength_; }

__device__ vec3f ballFieldCu::sampleImpl(const vec3f& pos)
{
	vec3f dir = vec3f(x, y, z) - pos.real();
	float dist = dir.norm();
	if (dist < r) return dir / (dist + 1e-6) * strength * sign;
	else return vec3f(0, 0, 0);
}

cycleFieldCu::cycleFieldCu() {}

__device__ void cycleFieldCu::update()
{
	t += 0.001;
}

__device__ vec3f cycleFieldCu::sampleImpl(const vec3f& pos)
{
	return vec3f{ -9.8 * sin(t),-9.8 * cos(t),0 };
}
