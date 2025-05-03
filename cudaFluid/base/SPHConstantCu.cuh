#pragma once
#include <cmath>

constexpr int H = 6;
constexpr double DAMP = -0.5;
constexpr int BOUNDRY_X = 500;
constexpr int BOUNDRY_Y = 500;
constexpr int BOUNDRY_Z = 500;
constexpr float VISCOSITY = 200.f;
constexpr float TEMPRATURE = 2000.f;
constexpr float RESTDENSITY = 300.f;
constexpr double TIMEINSTEP = 0.00007;
constexpr double PI = 3.14159265358979323846;
constexpr unsigned MAX_BALL_CNT=80000;

#define POW5(x) ((x)*(x)*(x)*(x)*(x))
#define POW6(x) ((x)*(x)*(x)*(x)*(x)*(x))
#define POW9(x) ((x)*(x)*(x)*(x)*(x)*(x)*(x)*(x)*(x))

constexpr double SPIKY = 15. / (PI * POW6(H));
constexpr double VISC_LAP = 45.f / (PI * POW5(H));
constexpr double SPIKY_GRAD = -45.f / (PI * POW6(H));
constexpr double POLY6 = 315.f / (64.f * PI * POW9(H));
constexpr double POLY6_GRAD = -945 / (32 * PI * POW9(H));