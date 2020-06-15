
local function loadAddon()
    OGLFramework.LoadDirectory("ogl_hud")
end

if OGLFramework then loadAddon() return end

hook.Add("OGLFramework.FullyLoaded", "OGLHUD.Loader", loadAddon)
