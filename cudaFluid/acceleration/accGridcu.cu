#include "accGridcu.cuh"
#include <thrust/sort.h>
#include <thrust/gather.h>
#include <thrust/extrema.h>
#include <thrust/sequence.h>
#include <thrust/device_free.h>
#include <thrust/device_vector.h>
#include <thrust/device_malloc.h>
#include <thrust/scan.h>

struct CalcGridIdx
{
	const vec3f* pos;
	float dx, dy, dz;
	unsigned dimZ, dimY;

	CalcGridIdx(const vec3f* p, float dx_, float dy_, float dz_, unsigned dimZ_, unsigned dimY_);
	__device__ size_t operator()(size_t i) const;
};

accGridCu::accGridCu(int nx, int ny, int nz) : nx(nx), ny(ny), nz(nz)
{
	dx = BOUNDRY_X * 1. / nx;
	dy = BOUNDRY_Y * 1. / ny;
	dz = BOUNDRY_Z * 1. / nz;

	gridBallCnt = devVec1d<unsigned>((nx + 2) * (ny + 2) * (nz + 2));
	uniqueKey = devVec1d<unsigned>((nx + 2) * (ny + 2) * (nz + 2));
	baseOffset = devVec1d<unsigned>((nx + 2) * (ny + 2) * (nz + 2) + 1);
}

accGridCu::~accGridCu()
{
	thrust::device_free(cpyBufferv3f);
	thrust::device_free(cpyBufferv1f);
}

void accGridCu::FillBalls(SPHBalldata& balls)
{
	this->balls.convertFromHost(balls);
	gridIdx = devVec1d<unsigned>(balls.ballCnt);
	sortIdx = devVec1d<unsigned>(balls.ballCnt);
	cpyBufferv3f = thrust::device_malloc<vec3f>(balls.ballCnt);
	cpyBufferv1f = thrust::device_malloc<float>(balls.ballCnt);
	ballCnt = balls.ballCnt;
}

void accGridCu::calcGridIdx()
{
	const vec3f* posPtr = thrust::raw_pointer_cast(balls.posd.data());
	CalcGridIdx func(posPtr, dx, dy, dz, (nx + 2) * (ny + 2), nx + 2);
	thrust::transform(thrust::counting_iterator<size_t>(0), thrust::counting_iterator<size_t>(ballCnt), gridIdx.begin(), func);
}

void accGridCu::sortBallsByGridIdx()
{
	thrust::sequence(sortIdx.begin(), sortIdx.end());
	thrust::sort_by_key(gridIdx.begin(), gridIdx.end(), sortIdx.begin());

	auto vec3fBeg = cpyBufferv3f;
	auto vec3fEnd = vec3fBeg + ballCnt;
	auto floatBeg = cpyBufferv1f;
	auto floatEnd = floatBeg + ballCnt;

	thrust::gather(sortIdx.begin(), sortIdx.end(), balls.rhod.begin(), floatBeg);
	thrust::copy(floatBeg, floatEnd, balls.rhod.begin());
	thrust::gather(sortIdx.begin(), sortIdx.end(), balls.pred.begin(), floatBeg);
	thrust::copy(floatBeg, floatEnd, balls.pred.begin());
	thrust::gather(sortIdx.begin(), sortIdx.end(), balls.veld.begin(), vec3fBeg);
	thrust::copy(vec3fBeg, vec3fEnd, balls.veld.begin());
	thrust::gather(sortIdx.begin(), sortIdx.end(), balls.ford.begin(), vec3fBeg);
	thrust::copy(vec3fBeg, vec3fEnd, balls.ford.begin());
	thrust::gather(sortIdx.begin(), sortIdx.end(), balls.posd.begin(), vec3fBeg);
	thrust::copy(vec3fBeg, vec3fEnd, balls.posd.begin());
}

void accGridCu::calcOffset() 
{
	calcGridIdx();
	sortBallsByGridIdx();
	//calcGridIdx();

	thrust::fill(baseOffset.begin(), baseOffset.end(), 0u);
	auto newEnd = thrust::reduce_by_key(gridIdx.begin(), gridIdx.end(),thrust::make_constant_iterator(1u),uniqueKey.begin(), gridBallCnt.begin());
	int uniqueCnt = newEnd.first - uniqueKey.begin();

	thrust::scatter(gridBallCnt.begin(), gridBallCnt.begin() + uniqueCnt, uniqueKey.begin(), baseOffset.begin());
	thrust::exclusive_scan(baseOffset.begin(), baseOffset.end(), baseOffset.begin());
}

unsigned accGridCu::NX(){return nx;}
unsigned accGridCu::NY(){return ny;}
unsigned accGridCu::NZ(){return nz;}

unsigned accGridCu::getBallCnt(){return ballCnt;}

vec3f*    accGridCu::vel(){return thrust::raw_pointer_cast(balls.veld.data());}
vec3f*    accGridCu::pos(){return thrust::raw_pointer_cast(balls.posd.data());}
float*    accGridCu::rho(){return thrust::raw_pointer_cast(balls.rhod.data());}
float*    accGridCu::pre(){return thrust::raw_pointer_cast(balls.pred.data());}
vec3f*    accGridCu::force(){return thrust::raw_pointer_cast(balls.ford.data());}
unsigned* accGridCu::grididx() { return thrust::raw_pointer_cast(gridIdx.data());}
unsigned* accGridCu::offset() { return thrust::raw_pointer_cast(baseOffset.data()); }

devVec1d<vec3f>& accGridCu::devPos(){return balls.posd;}
devVec1d<vec3f>& accGridCu::devVel(){return balls.veld;}
devVec1d<float>& accGridCu::devRho(){return balls.rhod;}
devVec1d<float>& accGridCu::devPre(){return balls.pred;}
devVec1d<vec3f>& accGridCu::devForce(){return balls.ford;}

CalcGridIdx::CalcGridIdx(const vec3f* p, float dx_, float dy_, float dz_, unsigned dimZ_, unsigned dimY_)
	: pos(p), dx(dx_), dy(dy_), dz(dz_), dimZ(dimZ_), dimY(dimY_)
{
}

__device__ size_t CalcGridIdx::operator()(size_t i) const
{
	const vec3f& p = pos[i];

	unsigned hx = static_cast<unsigned>(p.x / dx) + 1;
	unsigned hy = static_cast<unsigned>(p.y / dy) + 1;
	unsigned hz = static_cast<unsigned>(p.z / dz) + 1;
	return hz * dimZ + hy * dimY + hx;
}
