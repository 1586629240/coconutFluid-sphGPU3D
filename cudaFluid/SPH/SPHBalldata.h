#pragma once
#include <map>
#include <vector>
#include "../base/vec.cuh"

struct SPHBalldata
{
	std::vector<float> rho, pressure;
	std::vector<vec3f> force, pos, vel;

	size_t ballCnt = 0;
	std::map<size_t, bool, std::greater<size_t>> allocBucket;

	SPHBalldata();
	SPHBalldata(size_t n, bool isResize = true);
	void resizeAll(size_t n);
	void reserveAll(size_t n);
	void reallocateAll();
	void removeAll(size_t i);
	void zeroAll();

	void addBall(
		const float& rho_,
		const float& pressure_,
		const vec3f& force_,
		const vec3f& pos_,
		const vec3f& vel_);
};