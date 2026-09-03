/*
 * Work around Aquamarine 0.14.0 terminating an EGL display shared by
 * Hyprland's VMware renderer. This mirrors aquamarine PR #373: only call
 * eglTerminate when EGL display reference tracking is available.
 */
#define _GNU_SOURCE

#include <dlfcn.h>
#include <string.h>

typedef void *EGLDisplay;
typedef unsigned int EGLBoolean;

#define EGL_EXTENSIONS 0x3055

typedef EGLBoolean (*egl_terminate_fn)(EGLDisplay display);
typedef const char *(*egl_query_string_fn)(EGLDisplay display, int name);

EGLBoolean eglTerminate(EGLDisplay display) {
    egl_query_string_fn query_string =
        (egl_query_string_fn)dlsym(RTLD_NEXT, "eglQueryString");
    const char *extensions = query_string ? query_string(display, EGL_EXTENSIONS) : NULL;

    if (!extensions || !strstr(extensions, "EGL_KHR_display_reference"))
        return 1;

    egl_terminate_fn terminate =
        (egl_terminate_fn)dlsym(RTLD_NEXT, "eglTerminate");
    return terminate ? terminate(display) : 1;
}
