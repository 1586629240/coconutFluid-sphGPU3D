#include <thrust/device_vector.h>
#include "../base/vec.cuh"
#include "SPHBalldata.h"

template<class ty>
using devVec1d = thrust::device_vector<ty>;

struct SPHBalldataCu
{
	size_t ballCnt = 0;
	devVec1d<size_t> idxs;
	devVec1d<float> rhod, pred;
	devVec1d<vec3f> posd, veld, ford;

	__host__ SPHBalldataCu();
	__host__ void convertFromHost(const SPHBalldata& hostData);
};