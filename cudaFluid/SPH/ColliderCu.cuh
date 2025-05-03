#pragma once
#include "../base/vec.cuh"
#include "SPHargCu.cuh"
#include <stdexcept>

class ColliderCu
{
	bool activated = true;
protected:
	__device__ __host__ virtual void collisionImpl(vec3f& pos, vec3f& vel) = 0;
public:

	__device__ __host__ virtual bool show();
	__device__ __host__ virtual void enable()final;
	__device__ __host__ virtual void disable()final;
	__device__ __host__ virtual bool isActivated()final;

	__device__ __host__ virtual void collision(vec3f& pos, vec3f& vel);

	__device__ __host__ virtual void update();
};

class BoundryColliderCu : public ColliderCu
{
	float damping, ballR, maxX, maxY, maxZ;

public:
	__device__ __host__ BoundryColliderCu(const SPHarg& args);

	__device__ __host__ void setArgs(const SPHarg& args);
protected:
	__device__ __host__ void collisionImpl(vec3f& pos, vec3f& vel) override;
};

class CycleBoundryColliderCu : public ColliderCu
{
	float damping, ballR, maxX, maxY;

public:
	__device__ __host__ CycleBoundryColliderCu(const SPHarg& args);

	void setArgs(const SPHarg& args);
protected:
	__device__ __host__ void collisionImpl(vec3f& pos, vec3f& vel) override;
};

class CircleColliderCu : public ColliderCu
{
	float ballR;
	vec3f center;
public:

	__device__ __host__ bool show();
	__device__ __host__ float Radius();
	__device__ __host__ vec3f& Center();

	__device__ __host__ CircleColliderCu(const vec3f& center_, float ballR_ = 100);

protected:
	__device__ __host__ void collisionImpl(vec3f& pos, vec3f& vel) override;
};