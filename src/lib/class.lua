--[[---------------------------------------------------------
    Name: class.lua
    Desc: Creates a class
    Usage: Declare the "new" method to create a constructor
-----------------------------------------------------------]]


local function callConstructor( class, obj, ... )
    local meta = getmetatable(class)
    if meta.__super then
        if class.superArgs then
            callConstructor( meta.__super, obj, class.superArgs( ... ) )
        else
            callConstructor( meta.__super, obj )
        end
    end
    if class.new then
        class.new( obj, ... )
    end
end

local function instantiate( class, ... )
    local cl = setmetatable( {}, {
        __index = class
    } )
    callConstructor( class, cl, ... )
    return cl
end


function S_RP.class( superclass )
    local cl = {}
    setmetatable( cl, {
        __index = function( self, key )
            if key ~= "new" and superclass then
                return superclass[ key ]
            end
        end,
        __super = superclass,
        __call = instantiate,
    } )
    return cl
end
