#pragma once
#include "../base/vec.cuh"
#include <stdexcept>

class Field3dCu
{
	bool activated = true;
protected:
	__device__ virtual vec3f sampleImpl(const vec3f& pos) = 0;
public:
	__device__ Field3dCu();;
	__device__ virtual ~Field3dCu() = 0;

	__device__ virtual void enable()final;
	__device__ virtual void disable()final;

	__device__ virtual vec3f sample(const vec3f& pos)final;

	__device__ virtual void update();
};

class Field3dPosCu : public Field3dCu
{
protected:
	float x = 0, y = 0, z = 0, r;
public:
	__device__ Field3dPosCu(float x_, float y_, float z_, float r_ = 100);
	__device__ virtual ~Field3dPosCu() = 0;

	__device__ void setRadius(float r);
	__device__ void update(float x_, float y_, float z_);
};

class gravityFieldCu : public Field3dCu
{
public:
	__device__ gravityFieldCu();
	__device__ ~gravityFieldCu();

	__device__ vec3f sampleImpl(const vec3f& pos) override;
};

class ballFieldCu : public Field3dPosCu
{
	float sign = 1;
	float strength = 200;
public:
	__device__ ballFieldCu(float x, float y, float z, float r = 100);
	__device__ ~ballFieldCu();

	__device__ void negative();
	__device__ void setStrength(float strength_);
	__device__ vec3f sampleImpl(const vec3f& pos) override;
};

class cycleFieldCu :public Field3dCu
{
public:
	__device__ cycleFieldCu();
	__device__ void update();

	__device__ vec3f sampleImpl(const vec3f& pos) override;
};