#include "../base/SPHConstantCu.cuh"
#include "../SPH/SPHBalldataCu.cuh"
#include <thrust/iterator/constant_iterator.h>

class accGridCu
{
	int nx, ny, nz;
	float dx, dy, dz;
	unsigned ballCnt;
	SPHBalldataCu balls;

	thrust::device_ptr<vec3f> cpyBufferv3f;
	thrust::device_ptr<float> cpyBufferv1f;
	devVec1d<unsigned> gridBallCnt, uniqueKey;
	devVec1d<unsigned> gridIdx, sortIdx, baseOffset;

	void calcGridIdx();
	void sortBallsByGridIdx();

public:

	accGridCu(int nx, int ny, int nz);
	~accGridCu();

	void calcOffset();
	void FillBalls(SPHBalldata& balls);

	unsigned getBallCnt();
	
	vec3f* vel();
	vec3f* pos();
	vec3f* force();
	float *rho();
	float* pre();
	unsigned* offset();
	unsigned* grididx();


	devVec1d<vec3f>& devPos();
	devVec1d<vec3f>& devVel();
	devVec1d<float>& devRho();
	devVec1d<float>& devPre();
	devVec1d<vec3f>& devForce();

	unsigned NX();
	unsigned NY();
	unsigned NZ();
};