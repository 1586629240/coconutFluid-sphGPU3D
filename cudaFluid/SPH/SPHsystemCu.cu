#include "SPHsystemCu.cuh"

void SPHsystemCu::intergrateEuler()
{
	SPHsystemCuKernel::intergrateEulerCuImpl << <gridDim, blockDim >> > (
		blockDim * gridDim, ballCount,
		args.timeInStep, balls.pos(), balls.vel(), balls.force(), balls.rho());
	cudaDeviceSynchronize();
}

void SPHsystemCu::computeForce()
{
	SPHsystemCuKernel::computeForceCuImpl << <gridDim, blockDim >> > (
		blockDim * gridDim, ballCount, 
		(balls.NY() + 2) * (balls.NX() + 2), (balls.NX() + 2),
		balls.offset(), balls.grididx(),
		args.smoothR, args.mass * SPIKY_GRAD * 0.5f, args.viscosity * args.mass * VISC_LAP,
		balls.pos(), balls.vel(), balls.force(), balls.rho(), balls.pre());
	cudaDeviceSynchronize();
}

void SPHsystemCu::computePressure()
{
	SPHsystemCuKernel::computePressureCuImpl << <gridDim, blockDim >> > (
		blockDim * gridDim, ballCount, 
		(balls.NY() + 2) * (balls.NX() + 2), (balls.NX() + 2),
		balls.offset(), balls.grididx(),
		args.smoothR2, args.mass, args.temperature, args.restDensity,
		balls.pos(), balls.pre(), balls.rho());
	cudaDeviceSynchronize();
}

void SPHsystemCu::resolveCollision()
{
	SPHsystemCuKernel::resolveCollisionCuImpl << <gridDim, blockDim >> > (
		blockDim * gridDim, ballCount,
		thrust::raw_pointer_cast(colliders.data()), colliders.size(),
		balls.vel(), balls.pos());
	cudaDeviceSynchronize();

	SPHsystemCuKernel::ColliderUpdate << <1, 1 >> > (
		thrust::raw_pointer_cast(colliders.data()), colliders.size());
	cudaDeviceSynchronize();
}

void SPHsystemCu::computeExtraForce()
{
	SPHsystemCuKernel::computeExtraForceCuImpl << <gridDim, blockDim >> > (
		blockDim * gridDim, ballCount, args.mass,
		thrust::raw_pointer_cast(fields.data()), fields.size(),
		balls.force(), balls.pos(), balls.rho());
	cudaDeviceSynchronize();

	SPHsystemCuKernel::ExtraForceUpdate << <1, 1 >> > (
		thrust::raw_pointer_cast(fields.data()), fields.size());
	cudaDeviceSynchronize();
}

SPHsystemCu::~SPHsystemCu()
{
	SPHsystemCuKernel::destoryFieldVec<< <1, 1 >> > (
		thrust::raw_pointer_cast(fields.data()), fields.size());
	cudaDeviceSynchronize();
	SPHsystemCuKernel::destoryColliderVec<< <1, 1 >> > (
		thrust::raw_pointer_cast(colliders.data()), colliders.size());
	cudaDeviceSynchronize();
	fields.clear(), colliders.clear();
}

SPHsystemCu::SPHsystemCu(
	const SPHarg& arg,
	size_t ballCount_, size_t ny, size_t nx, size_t nz,
	unsigned blockDim_, unsigned gridDim_)
	: args(arg), ballCount(ballCount_), balls(nx, ny, nz), blockDim(blockDim_), gridDim(gridDim_)
{
	size_t cnt = 0;
	SPHBalldata bd(ballCount_);
	for (float z = args.maxZ / 2; z <= args.maxZ - args.ballR * 2; z += args.ballR)
	{
		for (float x = args.ballR; x <= args.maxX - args.ballR * 2; x += args.ballR)
			for (float y = args.ballR; y < args.maxY - args.ballR * 2 && cnt < ballCount; y += args.ballR)
			{
				float jitter = static_cast<float>(rand()) / RAND_MAX;
				bd.pos[cnt] = vec3f(x + jitter, 10 + jitter, y);
				cnt++;
			}
		if (cnt >= ballCount) break;
	}

	ballCount = cnt;

	bd.resizeAll(ballCount);
	balls.FillBalls(bd);
}

void SPHsystemCu::update()
{
	balls.calcOffset();
	computePressure();
	computeForce();
	computeExtraForce();
	intergrateEuler();
	resolveCollision();
}

void SPHsystemCu::addForce(Field3dCu* devObj)
{
	fields.push_back(devObj);
}

void SPHsystemCu::addCollider(ColliderCu* devObj)
{
	colliders.push_back(devObj);
}

void SPHsystemCu::setField(devVec1d<Field3dCu*> fieldDev)
{
	SPHsystemCuKernel::destoryFieldVec << <1, 1 >> > (
		thrust::raw_pointer_cast(fields.data()), fields.size());
	cudaDeviceSynchronize();
	fields.clear();
	fields = fieldDev;
}

void SPHsystemCu::initDefaultSence()
{
	colliders.assign(1, nullptr);
	SPHsystemCuKernel::BoxBoundryFactory << <1, 1 >> > (
		args, thrust::raw_pointer_cast(colliders.data()));
	cudaDeviceSynchronize();
}

SPHarg& SPHsystemCu::arg() { return args; }

size_t SPHsystemCu::ballcnt() { return ballCount; }

size_t SPHsystemCu::gridnx() { return balls.NX(); }
size_t SPHsystemCu::gridny() { return balls.NY(); }
size_t SPHsystemCu::gridnz() { return balls.NZ(); }
devVec1d<vec3f>& SPHsystemCu::devPos() { return balls.devPos(); }
devVec1d<vec3f>& SPHsystemCu::devVel() { return balls.devVel(); }
devVec1d<float>& SPHsystemCu::devRho() { return balls.devRho(); }
devVec1d<float>& SPHsystemCu::devPre() { return balls.devPre(); }
devVec1d<vec3f>& SPHsystemCu::devForce() { return balls.devForce(); }

SPHsystemCu& SPHsystemCu::getInstance()
{
	static SPHsystemCu instance{ SPHarg{},MAX_BALL_CNT };
	return instance;
}