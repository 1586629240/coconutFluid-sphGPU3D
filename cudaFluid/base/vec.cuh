#pragma once
#include <cuda_runtime.h>
#include <corecrt_math.h>

struct vec3i
{
	int x, y, z, w;
	__host__ __device__ vec3i();
	__host__ __device__ vec3i(int x, int y, int z);

	__host__ __device__ int& operator[](int i);
};

class vec3f
{
public:
	float x, y, z;
	__host__ __device__ vec3f(double x, double y, double z);
	__host__ __device__ vec3f();

	__host__ __device__ float norm()const;
	__host__ __device__ float squaredNorm();
	__host__ __device__ void normalize();
	__host__ __device__ vec3f normalized();
	__host__ __device__ vec3f& operator=(const vec3f& v);
	__host__ __device__ vec3f real()const;
	__host__ __device__ static vec3f Zero();
	__host__ __device__ vec3f operator+(const vec3f& v)const;
	__host__ __device__ vec3f operator-(const vec3f& v)const;
	__host__ __device__ vec3f operator-()const;
	__host__ __device__ vec3f operator*(float f)const;
	__host__ __device__ vec3f operator/(float f)const;
	__host__ __device__ float dot(const vec3f& v)const;
	__host__ __device__ vec3f cross(const vec3f& v)const;
	__host__ __device__ vec3f& operator+=(const vec3f& v);
	__host__ __device__ vec3f& operator-=(const vec3f& v);
	__host__ __device__ vec3f& operator*=(float f);
	__host__ __device__ vec3f& operator/=(float f);
	__host__ __device__ float& operator[](int i);
};

struct vec4f
{
	float x, y, z, w;
	__host__ __device__ vec4f();
	__host__ __device__ vec4f(float x, float y, float z, float w);

	__host__ __device__ float* data();
	__host__ __device__ static vec4f Zero();
	__host__ __device__ int& operator[](int i);
};

struct vec4d
{
	double x, y, z, w;
	__host__ __device__ vec4d();
	__host__ __device__ vec4d(double x, double y, double z, double w);

	__host__ __device__ double* data();
	__host__ __device__ static vec4f Zero();
	__host__ __device__ double& operator[](int i);
};