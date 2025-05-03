#pragma once
#include <string>
#include "SPHargCu.cuh"
#include "Field3dCu.cuh"
#include "ColliderCu.cuh"
#include "../acceleration/accGridCu.cuh"
#include <device_launch_parameters.h>

class SPHsystemCu
{
	SPHarg args;
	accGridCu balls;
	size_t ballCount;

	devVec1d<Field3dCu*> fields;
	devVec1d<ColliderCu*> colliders;

	unsigned blockDim, gridDim;
public:
	SPHsystemCu(
		const SPHarg& arg, size_t ballCount_,
		size_t ny = 100, size_t nx = 100, size_t nz = 100,
		unsigned blockDim_ = 128, unsigned gridDim_ = 128);
	~SPHsystemCu();
	void update();

	void initDefaultSence();
	void addForce(Field3dCu* devObj); //devObj 使用new在device上分配，所有权转移到SPHsystemCu
	void addCollider(ColliderCu* devObj);
	void setField(devVec1d<Field3dCu*> fieldDev);

	SPHarg& arg();
	size_t ballcnt();

	size_t gridnx();
	size_t gridny();
	size_t gridnz();

	devVec1d<vec3f>& devPos();
	devVec1d<vec3f>& devVel();
	devVec1d<float>& devRho();
	devVec1d<float>& devPre();
	devVec1d<vec3f>& devForce();

	static SPHsystemCu& getInstance();
	SPHsystemCu(const SPHsystemCu&) = delete;
	SPHsystemCu& operator=(const SPHsystemCu&) = delete;

private:
	void intergrateEuler();
	void computeForce();
	void computePressure();
	void resolveCollision();

	void computeExtraForce();
};

namespace SPHsystemCuKernel {
	__device__ void visitGrid(
		int times, unsigned dimZ, unsigned dimY, unsigned gridID,
		unsigned* baseOffset, unsigned& beg, unsigned& end);

	__global__ void computeExtraForceCuImpl(
		unsigned threadCnt, unsigned ballCnt, float mass,
		Field3dCu** fields, unsigned fieldCnt, vec3f* force, vec3f* pos, float* rho);

	__global__ void intergrateEulerCuImpl(
		unsigned threadCnt, unsigned ballCnt, double dt,
		vec3f* pos, vec3f* vel, vec3f* force, float* rho);

	__global__ void resolveCollisionCuImpl(
		unsigned threadCnt, unsigned ballCnt,
		ColliderCu** Colliders, unsigned ColliderCnt, vec3f* vel, vec3f* pos);

	__global__ void computeForceCuImpl(
		unsigned threadCnt, unsigned ballCnt, unsigned dimZ, unsigned dimY,
		unsigned* baseOffset, unsigned* gridIdx,
		float smoothR, float mass, float viscosity, 
		vec3f* pos, vec3f* vel, vec3f* force, float* rho, float* pre);

	__global__ void computePressureCuImpl(
		unsigned threadCnt, unsigned ballCnt, unsigned dimZ, unsigned dimY,
		unsigned* baseOffset, unsigned* gridIdx,
		float smoothR2, float mass, float temperature, float restDensity,
		vec3f* pos, float* pressure, float* rho);

	__global__ void BallFieldFactory(Field3dCu** b);
	__global__ void BallFieldFactory(Field3dCu** b, float x, float y, float z, float r);

	__global__ void CycleFieldFactory(Field3dCu** b);
	__global__ void GravityFieldFactory(Field3dCu** g);
	__global__ void BoxBoundryFactory(SPHarg args, ColliderCu** b);
	__global__ void ExtraForceUpdate(Field3dCu** fields, unsigned fieldCnt);
	__global__ void ColliderUpdate(ColliderCu** Colliders, unsigned ColliderCnt);

	__global__ void destoryFieldVec(Field3dCu** a, unsigned alen);
	__global__ void destoryColliderVec(ColliderCu** b, unsigned blen);
};