#include "ColliderCu.cuh"

__device__ __host__ void ColliderCu::collisionImpl(vec3f& pos, vec3f& vel) {}

__device__ __host__ bool ColliderCu::show() { return false; }

__device__ __host__ void ColliderCu::enable() { activated = true; }

__device__ __host__ void ColliderCu::disable() { activated = false; }

__device__ __host__ bool ColliderCu::isActivated() { return activated; }

__device__ __host__ void ColliderCu::collision(vec3f& pos, vec3f& vel) {
	if (activated)collisionImpl(pos, vel);
}

__device__ __host__ void ColliderCu::update() {}

BoundryColliderCu::BoundryColliderCu(const SPHarg& args)
{
	setArgs(args);
}

__device__ __host__ void BoundryColliderCu::setArgs(const SPHarg& args)
{
	damping = args.damping;
	ballR = args.ballR;
	maxX = args.maxX;
	maxY = args.maxY;
	maxZ = args.maxZ;
}

__device__ __host__ void BoundryColliderCu::collisionImpl(vec3f& pos, vec3f& vel)
{
	if (pos.x < ballR)
	{
		vel.x *= damping;
		pos.x = ballR;
	}
	else if (pos.x > maxX - ballR)
	{
		vel.x *= damping;
		pos.x = maxX - ballR;
	}

	if (pos.y < ballR)
	{
		vel.y *= damping;
		pos.y = ballR;
	}
	else if (pos.y > maxY - ballR)
	{
		vel.y *= damping;
		pos.y = maxY - ballR;
	}

	if (pos.z < ballR)
	{
		vel.z *= damping;
		pos.z = ballR;
	}
	else if (pos.z > maxZ - ballR)
	{
		vel.z *= damping;
		pos.z = maxZ - ballR;
	}
}

CycleBoundryColliderCu::CycleBoundryColliderCu(const SPHarg& args)
{
	setArgs(args);
}

void CycleBoundryColliderCu::setArgs(const SPHarg& args)
{
	damping = args.damping;
	ballR = args.ballR;
	maxX = args.maxX;
	maxY = args.maxY;
}

__device__ __host__ void CycleBoundryColliderCu::collisionImpl(vec3f& pos, vec3f& vel)
{
	if (pos.x < ballR)
	{
		vel.x *= -1;
		pos.x = ballR;
	}
	else if (pos.x > maxX - ballR)
	{
		vel = vec3f::Zero();
		pos.x -= (maxX - ballR);
		pos.y = rand() % BOUNDRY_Y;
	}

	if (pos.y < ballR)
	{
		vel.y *= damping;
		pos.y = ballR;
	}
	else if (pos.y > maxY - ballR)
	{
		vel.y *= damping;
		pos.y = maxY - ballR;
	}
}

__device__ __host__ bool CircleColliderCu::show() { return isActivated(); }

__device__ __host__ float CircleColliderCu::Radius() { return ballR; }

__device__ __host__ vec3f& CircleColliderCu::Center() { return center; }

CircleColliderCu::CircleColliderCu(const vec3f& center_, float ballR_)
{
	ballR = ballR_;
	center = center_;
}

__device__ __host__ void CircleColliderCu::collisionImpl(vec3f& pos, vec3f& vel)
{
	vec3f dir = center - pos;
	float dist = dir.norm();
	if (dist < ballR)
	{
		pos -= dir.normalized() * (ballR - dist);
		vel = -vel;
	}
}
