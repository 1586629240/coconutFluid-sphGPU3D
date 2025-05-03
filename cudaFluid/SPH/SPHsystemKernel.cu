#include "SPHsystemCu.cuh"

/*
注：换成double后*rSubsmR>0会出问题，导致出现nan
*/

namespace SPHsystemCuKernel 
{
	__device__ void visitGrid(
		int times, unsigned dimZ, unsigned dimY, unsigned gridID,
		unsigned* baseOffset, unsigned& beg, unsigned& end)
	{
		gridID += ((times / 3 - 1) * dimZ + (times % 3 - 1) * dimY);
		beg = baseOffset[gridID - 1], end = baseOffset[gridID + 2];
	}

	__global__ void computeExtraForceCuImpl(
		unsigned threadCnt, unsigned ballCnt, float mass,
		Field3dCu** fields, unsigned fieldCnt,
		vec3f* force, vec3f* pos, float* rho)
	{
		unsigned idx = blockIdx.x * blockDim.x + threadIdx.x;
		for (; idx < ballCnt; idx += threadCnt)
		{
			const float forcCoeff = mass / rho[idx];
			for (int i = 0; i < fieldCnt; i++)
				force[idx] += fields[i]->sample(pos[idx]) * forcCoeff;
		}
	}

	__global__ void ExtraForceUpdate(Field3dCu** fields, unsigned fieldCnt)
	{
		for (int i = 0; i < fieldCnt; i++)fields[i]->update();
	}

	__global__ void intergrateEulerCuImpl(
		unsigned threadCnt, unsigned ballCnt,
		double dt, vec3f* pos, vec3f* vel, vec3f* force, float* rho)
	{
		unsigned idx = blockIdx.x * blockDim.x + threadIdx.x;
		for (; idx < ballCnt; idx += threadCnt)
		{
			vel[idx] += force[idx] * dt / rho[idx];
			pos[idx] += vel[idx] * dt;
		}
	}

	__global__ void resolveCollisionCuImpl(
		unsigned threadCnt, unsigned ballCnt,
		ColliderCu** Colliders, unsigned ColliderCnt,
		vec3f* vel, vec3f* pos)
	{
		unsigned idx = blockIdx.x * blockDim.x + threadIdx.x;
		for (; idx < ballCnt; idx += threadCnt)
		{
			for (int i = 0; i < ColliderCnt; i++)
				Colliders[i]->collision(pos[idx], vel[idx]);
		}
	}

	__global__ void ColliderUpdate(ColliderCu** Colliders, unsigned ColliderCnt)
	{
		for (int i = 0; i < ColliderCnt; i++)Colliders[i]->update();
	}

	__global__ void computeForceCuImpl(
		unsigned threadCnt, unsigned ballCnt, unsigned dimZ, unsigned dimY,
		unsigned* baseOffset, unsigned* gridIdx,  // gridDim, +2
		float smoothR, float fpCoeff, float fvCoeff,
		vec3f* pos, vec3f* vel, vec3f* force, float* rho, float* pre)
	{
		unsigned idx = blockIdx.x * blockDim.x + threadIdx.x;
		for (; idx < ballCnt; idx += threadCnt)
		{
			vec3f fp, fv;
			const vec3f pos_i = pos[idx];
			const float pre_i = pre[idx];
			const vec3f vel_i = vel[idx];

			for (int i = 0; i < 9; i++)
			{
				unsigned beg, end;
				visitGrid(i, dimZ, dimY, gridIdx[idx], baseOffset, beg, end);

				for (unsigned j = beg; j < end; j++)
				{
					const vec3f rij = pos_i - pos[j];

					const float rijNorm = rij.norm();
					const float invRhoj = 1.0f / rho[j];
					const float smrSubR = fmaxf(smoothR - rijNorm, 0.0f);

					const vec3f velocity_diff = vel[j] - vel_i;
					const float smrSubR3 = smrSubR * smrSubR * smrSubR;
					const float pressure_term = (pre_i + pre[j]) * invRhoj;

					fp += rij / (rijNorm + 1e-6f) * (pressure_term * smrSubR3);
					fv += velocity_diff * (invRhoj * smrSubR);
				}
			}
			fp *= fpCoeff;
			fv *= fvCoeff;
			force[idx] = fp + fv;
		}
	}

	__global__ void computePressureCuImpl(
		unsigned threadCnt, unsigned ballCnt, unsigned dimZ, unsigned dimY,
		unsigned* baseOffset, unsigned* gridIdx,
		float smoothR2, float mass, float temperature, float restDensity,
		vec3f* pos, float* pressure, float* rho)
	{
		unsigned idx = blockIdx.x * blockDim.x + threadIdx.x;
		for (; idx < ballCnt; idx += threadCnt)
		{
			float rho_ = 0;
			unsigned beg, end;
			for (int i = 0; i < 9; i++)
			{
				visitGrid(i, dimZ, dimY, gridIdx[idx], baseOffset, beg, end);
				for (unsigned j = beg; j < end; j++)
				{
					float rSubSMR2 = smoothR2 - (pos[idx] - pos[j]).squaredNorm();
					rho_ += rSubSMR2 * rSubSMR2 * rSubSMR2 * (rSubSMR2 > 0);
				}
			}
			rho[idx] = rho_ * mass * POLY6;
			pressure[idx] = temperature * (rho[idx] - restDensity);
		}
	}

	__global__ void destoryColliderVec(ColliderCu** b, unsigned blen)
	{
		for (unsigned i = 0; i < blen; i++)delete b[i];
	}

	__global__ void destoryFieldVec(Field3dCu** a, unsigned alen)
	{
		for (unsigned i = 0; i < alen; i++)delete a[i];
	}

	__global__ void BoxBoundryFactory(SPHarg args, ColliderCu** b)
	{
		b[0] = new BoundryColliderCu(args);
	}

	__global__ void BallFieldFactory(Field3dCu** b)
	{
		b[0] = new ballFieldCu(250, 50, 250, 50);
	}

	__global__ void BallFieldFactory(Field3dCu** b, float x, float y, float z, float r)
	{
		b[0] = new ballFieldCu(x, y, z, r);
	}

	__global__ void CycleFieldFactory(Field3dCu** b)
	{
		b[0] = new cycleFieldCu();
	}

	__global__ void GravityFieldFactory(Field3dCu** g)
	{
		g[0] = new gravityFieldCu();
	}
};