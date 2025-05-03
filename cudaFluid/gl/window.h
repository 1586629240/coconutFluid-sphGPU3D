#pragma once
#include <GL/glew.h>
#include <GLFW/glfw3.h>
#include "camera.h"
#include <iostream>

GLFWwindow* initGL();
void processInput(GLFWwindow* window);
void mouse_button_callback(GLFWwindow* window);
void mouse_callback(GLFWwindow* window, double xpos, double ypos);
void scroll_callback(GLFWwindow* window, double xoffset, double yoffset);
void framebuffer_size_callback(GLFWwindow* window, int width, int height);
unsigned fps();

extern Camera camera;