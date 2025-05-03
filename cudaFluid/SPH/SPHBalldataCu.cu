#include "SPHBalldataCu.cuh"
#include <thrust/fill.h>
SPHBalldataCu::SPHBalldataCu() {}

__host__ void SPHBalldataCu::convertFromHost(const SPHBalldata& hostData)
{
	ballCnt = hostData.ballCnt;

	idxs = devVec1d<size_t>(ballCnt);
	veld = hostData.vel;
	posd = hostData.pos;
	rhod = hostData.rho;
	ford = hostData.force;
	pred = hostData.pressure;
}
