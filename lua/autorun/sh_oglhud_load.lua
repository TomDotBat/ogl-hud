
local function loadAddon()
    if CLIENT then
        OGLFramework.LoadDirectoryDelayed("ogl_hud")
        return
    end
    OGLFramework.LoadDirectory("ogl_hud")
end

if OGLFramework then loadAddon() return end

hook.Add("OGLFramework.FullyLoaded", "OGLHUD.Loader", loadAddon)
