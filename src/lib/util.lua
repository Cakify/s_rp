S_RP.Util = {}
local Util = S_RP.Util

--[[---------------------------------------------------------
		Name: copy
		Desc: Copies a table
-----------------------------------------------------------]]

function Util.copy( tbl )
	local copy = tbl
	for k, v in pairs( tbl ) do
		copy[ k ] = v
	end
	return copy
end



do
	local netFuncs = {}

--[[---------------------------------------------------------
		Name: netReceive
		Desc: Calls a function if a message with specified name arrived
-----------------------------------------------------------]]

	function Util.netReceive( name, func )
		netFuncs[ name ] = func
	end


	hook.add( "net", "NetReceive", function( name, len, ply )
		if netFuncs[ name ] then
			netFuncs[ name ]( len, ply )
		end
	end )

end



do

	local globals = {}


	local function write( value )
		net.writeString( type( value ) )
		if type( value ) == "number" then
			net.writeFloat( value )
		elseif type( value ) == "string" then
			net.writeString( value )
		elseif type( value ) == "table" then
			net.writeTable( value )
		end
	end


	local function read()
		local valType = net.readString()
		if valType == "number" then
			return net.readFloat()
		elseif valType == "string" then
			return net.readString()
		elseif valType == "table" then
			return net.readTable()
		end
	end


	local function globalNew( name, value )
		net.start( "newGlobal" )
		net.writeString( name )
		write( value )
		net.send()
	end


	Util.netReceive( "newGlobal", function()
		local globalName = net.readString()
		globals[ globalName ] = read()
	end )

--[[---------------------------------------------------------
		Name: setGlobal
		Desc: Sets a global variable which is available on server and client
-----------------------------------------------------------]]
	function Util.setGlobal( name, value )
		globalNew( name, value )
	end


--[[---------------------------------------------------------
		Name: getGlobal
		Desc: Returns the value of a global variable
-----------------------------------------------------------]]

	function Util.getGlobal( name )
		return globals[ name ]
	end

end


--[[---------------------------------------------------------
		Name: sendLua
		Desc: Sends a lua script to client(s) and executes it
-----------------------------------------------------------]]


function Util.sendLua( code, ply )
    if not ( net.getBytesLeft() > 0 ) then
        timer.simple( 2, function()
            Util.sendLua( code, ply )
        end )
    else
    	net.start( "sendlua" )
    	net.writeString( code )
    	net.send( ply )
    end
end


Util.netReceive( "sendlua", function()
	local code = net.readString()
	local fn = loadstring( code )
	if type( fn ) == "string" then
		error( fn )
	else
		fn()
	end
end )



--[[---------------------------------------------------------
		Name: findPlayerByName
		Desc: Returns a player with the name
-----------------------------------------------------------]]
function Util.findPlayerByName( name )
	for _, ply in pairs( find.allPlayers() ) do
		if ply:getName():lower():find( name ) then return ply end
	end
end


--[[---------------------------------------------------------
   Name: explode(seperator ,string)
   Desc: Takes a string and turns it into a table
   Usage: explode( " ", "Seperate this string")
-----------------------------------------------------------]]
local totable = string.ToTable
local string_sub = string.sub
local string_gsub = string.gsub
local string_gmatch = string.gmatch
function Util.explode(separator, str, withpattern)
	if (separator == "") then return totable( str ) end

	local ret = {}
	local index,lastPosition = 1,1

	-- Escape all magic characters in separator
	if not withpattern then separator = separator:PatternSafe() end

	-- Find the parts
	for startPosition,endPosition in string_gmatch( str, "()" .. separator.."()" ) do
		ret[index] = string_sub( str, lastPosition, startPosition-1)
		index = index + 1

		-- Keep track of the position
		lastPosition = endPosition
	end

	-- Add last part by using the position we stored
	ret[index] = string_sub( str, lastPosition)
	return ret
end


--[[---------------------------------------------------------
	Name: Stack
	Desc: FILO Stack
-----------------------------------------------------------]]

Util.Stack = S_RP.class()

function Util.Stack:new()
	self.stack = {}
end

function Util.Stack:push( v )
	self.stack[ #self.stack + 1 ] = v
end

function Util.Stack:pop()
	local r = self.stack[ #self.stack ]
	self.stack[ #self.stack ] = nil
	return r
end
