koptilnya_holo_builder_sh_lib = {}
local lib = koptilnya_holo_builder_sh_lib

lib.Net = {
    MESSAGE_NAME_PREFIX = "koptilnya_holo_builder_",
    NetworkMessageName = function(name)
        return string.format("%s%s", lib.Net.MESSAGE_NAME_PREFIX, name)
    end
}

koptilnya_holo_builder_sh_lib = lib
