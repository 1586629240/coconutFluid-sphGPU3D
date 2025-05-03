#include "vec.cuh"

vec3f::vec3f(double x, double y, double z) : x(x), y(y), z(z) {}

vec3f::vec3f() : x(0), y(0), z(0) {}

__host__ __device__ float vec3f::norm()const
{
	return sqrtf(x * x + y * y + z * z);
}

__host__ __device__ float vec3f::squaredNorm()
{
	return (x * x + y * y + z * z);
}

__host__ __device__ void vec3f::normalize()
{
	float n = norm() + 1e-5;
	x /= n;
	y /= n;
	z /= n;
}

__host__ __device__ vec3f vec3f::normalized()
{
	float n = norm() + 1e-5;
	return vec3f(x / n, y / n, z / n);
}

__host__ __device__ vec3f& vec3f::operator=(const vec3f& v)
{
	x = v.x;
	y = v.y;
	z = v.z;
	return *this;
}

__host__ __device__ vec3f vec3f::real() const
{
	return vec3f(x, y, z);
}

__host__ __device__ vec3f vec3f::Zero()
{
	return vec3f();
}

__host__ __device__ vec3f vec3f::operator+(const vec3f& v)const
{
	return vec3f(x + v.x, y + v.y, z + v.z);
}

__host__ __device__ vec3f vec3f::operator-(const vec3f& v)const
{
	return vec3f(x - v.x, y - v.y, z - v.z);
}

__host__ __device__ vec3f vec3f::operator-()const
{
	return vec3f(-x, -y, -z);
}

__host__ __device__ vec3f vec3f::operator*(float f)const
{
	return vec3f(x * f, y * f, z * f);
}

__host__ __device__ vec3f vec3f::operator/(float f)const
{
	return vec3f(x / f, y / f, z / f);
}

__host__ __device__ float vec3f::dot(const vec3f& v)const
{
	return v.x * x + v.y * y + v.z * z;
}

__host__ __device__ vec3f vec3f::cross(const vec3f& v)const
{
	return vec3f(y * v.z - z * v.y, z * v.x - x * v.z, x * v.y - y * v.x);
}

__host__ __device__ vec3f& vec3f::operator+=(const vec3f& v)
{
	x += v.x;
	y += v.y;
	z += v.z;
	return *this;
}

__host__ __device__ vec3f& vec3f::operator-=(const vec3f& v)
{
	x -= v.x;
	y -= v.y;
	z -= v.z;
	return *this;
}

__host__ __device__ vec3f& vec3f::operator*=(float f)
{
	x *= f;
	y *= f;
	z *= f;
	return *this;
}

__host__ __device__ vec3f& vec3f::operator/=(float f)
{
	x /= f;
	y /= f;
	z /= f;
	return *this;
}

__host__ __device__ float& vec3f::operator[](int i)
{
	return ((float*)this)[i];
}

vec3i::vec3i() : x(0), y(0), z(0), w(0) {}

vec3i::vec3i(int x, int y, int z) : x(x), y(y), z(z), w(0) {}

__host__ __device__ int& vec3i::operator[](int i) { return ((int*)this)[i]; }

vec4f::vec4f() : x(0), y(0), z(0), w(0) {}

vec4f::vec4f(float x, float y, float z, float w) : x(x), y(y), z(z), w(w) {}

__host__ __device__ float* vec4f::data() { return (float*)this; }

__host__ __device__ vec4f vec4f::Zero() { return vec4f(); }

__host__ __device__ int& vec4f::operator[](int i) { return ((int*)this)[i]; }

vec4d::vec4d() : x(0), y(0), z(0), w(0) {}

vec4d::vec4d(double x, double y, double z, double w) : x(x), y(y), z(z), w(w) {}

__host__ __device__ double* vec4d::data() { return (double*)this; }

__host__ __device__ vec4f vec4d::Zero() { return vec4f(); }

__host__ __device__ double& vec4d::operator[](int i) { return ((double*)this)[i]; }
