#include "window.h"
#include "../imgui/imgui.h"

#include "../imgui/imgui_impl_glfw.h"

#include "../imgui/imgui_impl_opengl3.h"

static bool mouseDrag = false;
static double lastX, lastY;
Camera camera(glm::vec3(10, 25, 25));

GLFWwindow* initGL()
{
    glfwInit();
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);

#ifdef __APPLE__
    glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);
#endif

    GLFWwindow* window = glfwCreateWindow(1920, 1080, "LearnOpenGL", NULL, NULL);
    if (window == NULL)
    {
        std::cout << "Failed to create GLFW window" << std::endl;
        glfwTerminate();
        return nullptr;
    }

    glfwMakeContextCurrent(window);
    glfwSetWindowTitle(window, "cudaSPH By Ciji");
    glfwSetScrollCallback(window, scroll_callback);
    glfwSetCursorPosCallback(window, mouse_callback);
    glfwSetFramebufferSizeCallback(window, framebuffer_size_callback);

    glewExperimental = GL_TRUE;
    if (glewInit() != GLEW_OK) {
        std::cout << "Failed to initialize GLEW" << std::endl;
    }

    IMGUI_CHECKVERSION();
    ImGui::CreateContext();

    ImGuiIO& io = ImGui::GetIO();
    ImGui::StyleColorsLight();

    ImGui_ImplGlfw_InitForOpenGL(window, true);
    ImGui_ImplOpenGL3_Init();

    glEnable(GL_CULL_FACE);
    glEnable(GL_DEPTH_TEST);

    return window;
}

void setImGuiAlpha(float alpha)
{
	ImGuiStyle& style = ImGui::GetStyle();
	style.Alpha = alpha;
}

void processInput(GLFWwindow* window)
{
    if (glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS)
        glfwSetWindowShouldClose(window, true);

    if (glfwGetKey(window, GLFW_KEY_W) == GLFW_PRESS)
        camera.processKeyDown(FORWARD);
    if (glfwGetKey(window, GLFW_KEY_S) == GLFW_PRESS)
        camera.processKeyDown(BACKWARD);
    if (glfwGetKey(window, GLFW_KEY_A) == GLFW_PRESS)
        camera.processKeyDown(LEFT);
    if (glfwGetKey(window, GLFW_KEY_D) == GLFW_PRESS)
        camera.processKeyDown(RIGHT);


    if (ImGui::GetIO().WantCaptureMouse)
    {
        glfwSetInputMode(window, GLFW_CURSOR, GLFW_CURSOR_NORMAL);
        setImGuiAlpha(1.0);
    }
    else
    {
        mouse_button_callback(window);
        setImGuiAlpha(0.3);
    }
}

void mouse_button_callback(GLFWwindow* window) 
{
    if (glfwGetMouseButton(window, GLFW_MOUSE_BUTTON_LEFT) == GLFW_PRESS)
        mouseDrag = true;
    else if (glfwGetMouseButton(window, GLFW_MOUSE_BUTTON_LEFT) == GLFW_RELEASE)
        mouseDrag = false;

    if (mouseDrag)
    {
        glfwSetInputMode(window, GLFW_CURSOR, GLFW_CURSOR_DISABLED);
		glfwGetCursorPos(window, &lastX, &lastY);
    }
    else
        glfwSetInputMode(window, GLFW_CURSOR, GLFW_CURSOR_NORMAL);
}

void framebuffer_size_callback(GLFWwindow* window, int width, int height)
{
    glViewport(0, 0, width, height);
}

unsigned fps()
{
    static int ticks = -1;
    ticks++;
    static double _lastTime = glfwGetTime();

    static double fps = 0;
    if (ticks == 60)
    {
        double deltaTime = glfwGetTime() - _lastTime;
        _lastTime = glfwGetTime();
        fps = ticks / deltaTime;
        ticks = 0;
    }
    return fps;
}

void mouse_callback(GLFWwindow* window, double xposIn, double yposIn)
{
    if (!mouseDrag)return;

    static bool firstMouse = true;

    float xpos = static_cast<float>(xposIn);
    float ypos = static_cast<float>(yposIn);

    if (firstMouse)
    {
        lastX = xpos;
        lastY = ypos;
        firstMouse = false;
    }

    float xoffset = xpos - lastX;
    float yoffset = lastY - ypos;

    lastX = xpos;
    lastY = ypos;

    camera.processMouseMove(xoffset, yoffset);
}

void scroll_callback(GLFWwindow* window, double xoffset, double yoffset)
{
    if (!mouseDrag)return;
    camera.processMouseScroll(static_cast<float>(yoffset));
}