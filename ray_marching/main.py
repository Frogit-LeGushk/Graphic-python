import moderngl_window as mglw

class App(mglw.WindowConfig):
    gl_version = (3, 3)
    window_size = (1920, 1080)
    resource_dir = 'programs'
    
    def __init__(self, **args):
        super().__init__(**args)
        self.quad_fs = mglw.geometry.quad_fs()
        self.program = self.load_program(
            vertex_shader='vertex.glsl', 
            fragment_shader='fragment.glsl'
        )
        # uniforms
        self.program["u_resolution"] = self.window_size
        
    def render(self, time, frametime):
        self.ctx.clear()
        self.quad_fs.render(self.program)
        
    def mouse_position_event(self, x, y, dx, dy):
        self.program["u_mouse"] = (x, y)

if __name__ == '__main__':
    App.run()
