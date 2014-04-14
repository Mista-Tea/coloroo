--[[--------------------------------------------------------------------------
	File name:
		coloroo.lua
	
	Author:
		Mista-Tea ([IJWTB Thomas])
	
	File description:
		An object-oriented approach to using the Color() function. We've all
		 probably had instances where we wish we could quickly perform operations
		 on colors without having to make custom or expensive functions to do it.
		 		 
		This script will allow you to use +, -, *, /, ==, >, >=, <, and <= on existing colors
		 by overriding the default Color() function to return an object whose metatable supports
		 arithmetic and relation operations.

	License:
		The MIT License (MIT)

		Copyright (c) 2014 Mista-Tea

		Permission is hereby granted, free of charge, to any person obtaining a copy
		of this software and associated documentation files (the "Software"), to deal
		in the Software without restriction, including without limitation the rights
		to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
		copies of the Software, and to permit persons to whom the Software is
		furnished to do so, subject to the following conditions:

		The above copyright notice and this permission notice shall be included in all
		copies or substantial portions of the Software.

		THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
		IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
		FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
		AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
		LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
		OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
		SOFTWARE.

	Changelog:
		- Created April 12th, 2014
		- Added to GitHub April 14th, 2014
----------------------------------------------------------------------------]]

--[[--------------------------------------------------------------------------
-- Namespace Tables
--------------------------------------------------------------------------]]--

local meta = { __index = meta, r = 255, g = 255, b = 255, a = 255 }

local operations = {
	table  = function( col ) return col.r, col.g, col.b, col.a end,
	number = function( num ) return num,     num,   num, num   end,
}

--[[--------------------------------------------------------------------------
-- Localized Functions & Variables
--------------------------------------------------------------------------]]--

local setmetatable = setmetatable
local tostring     = tostring
local string       = string
local assert       = assert
local math         = math
local type         = type

--[[--------------------------------------------------------------------------
-- Namespace Functions
--------------------------------------------------------------------------]]--

local function Round( num )

	return math.floor( num + 0.5 )
  
end
--[[----------------------------------------------------------------------]]--
local function Clamp( num )

	return (num < 0 and 0) or (num > 255 and 255) or num

end
--[[----------------------------------------------------------------------]]--
function Color( r, g, b, a )
	
	return setmetatable( 
		{ 
			r = ( r and Round( Clamp( r, 0, 255 ) ) ) or 255,
			g = ( g and Round( Clamp( g, 0, 255 ) ) ) or 255,
			b = ( b and Round( Clamp( b, 0, 255 ) ) ) or 255,
			a = ( a and Round( Clamp( a, 0, 255 ) ) ) or 255 
		}, 
		meta 
	)
	
end
--[[----------------------------------------------------------------------]]--
function ColorAlpha( c, a )

	return Color( c.r, c.g, c.b, a )
	
end
--[[----------------------------------------------------------------------]]--
function meta.__add( c1, c2 )
	
	local c1Type = type( c1 )
	local c2Type = type( c2 )
	
	assert( operations[ c1Type ], "Attempt to add '" .. tostring( c1 ) .. "' to Color object (a " .. type( c1 ) .. " value)" )
	assert( operations[ c2Type ], "Attempt to add '" .. tostring( c2 ) .. "' to Color object (a " .. type( c2 ) .. " value)" )
	
	local r1, g1, b1, a1 = operations[ c1Type ]( c1 )
	local r2, g2, b2, a2 = operations[ c2Type ]( c2 )
	
	return Color(
		Round( Clamp( r1 + r2 ) ),
		Round( Clamp( g1 + g2 ) ),
		Round( Clamp( b1 + b2 ) )
		--Round( Clamp( a1 + a2 ) )
	)
	
end
--[[----------------------------------------------------------------------]]--
function meta.__sub( c1, c2 )
	
	local c1Type = type( c1 )
	local c2Type = type( c2 )
	
	assert( operations[ c2Type ], "Attempt to subtract '" .. tostring( c1 ) .. "' to Color object (a " .. type( c1 ) .. " value)" )
	assert( operations[ c2Type ], "Attempt to subtract '" .. tostring( c2 ) .. "' to Color object (a " .. type( c2 ) .. " value)" )
	
	local r1, g1, b1, a1 = operations[ c1Type ]( c1 )
	local r2, g2, b2, a2 = operations[ c2Type ]( c2 )
	
	return Color(
		Round( Clamp( r1 - r2 ) ),
		Round( Clamp( g1 - g2 ) ),
		Round( Clamp( b1 - b2 ) )
		--Round( Clamp( a1 - a2 ) )
	)

end
--[[----------------------------------------------------------------------]]--
function meta.__mul( c1, c2 )
	
	local c1Type = type( c1 )
	local c2Type = type( c2 )
	
	assert( operations[ c2Type ], "Attempt to multiply '" .. tostring( c1 ) .. "' to Color object (a " .. type( c1 ) .. " value)" )
	assert( operations[ c2Type ], "Attempt to multiply '" .. tostring( c2 ) .. "' to Color object (a " .. type( c2 ) .. " value)" )
		
	local r1, g1, b1, a1 = operations[ c1Type ]( c1 )
	local r2, g2, b2, a2 = operations[ c2Type ]( c2 )
	
	return Color(
		Round( Clamp( r1 * r2 ) ),
		Round( Clamp( g1 * g2 ) ),
		Round( Clamp( b1 * b2 ) )
		--Round( Clamp( a1 * a2 ) )
	)

end
--[[----------------------------------------------------------------------]]--
function meta.__div( c1, c2 )
	
	local c1Type = type( c1 )
	local c2Type = type( c2 )
	
	assert( operations[ c2Type ], "Attempt to divide '" .. tostring( c1 ) .. "' to Color object (a " .. type( c1 ) .. " value)" )
	assert( operations[ c2Type ], "Attempt to divide '" .. tostring( c2 ) .. "' to Color object (a " .. type( c2 ) .. " value)" )
	
	local r1, g1, b1, a1 = operations[ c1Type ]( c1 )
	local r2, g2, b2, a2 = operations[ c2Type ]( c2 )
	
	return Color(
		Round( Clamp( r1 / r2 ) ),
		Round( Clamp( g1 / g2 ) ),
		Round( Clamp( b1 / b2 ) )
		--Round( Clamp( a1 / a2 ) )
	)

end
--[[----------------------------------------------------------------------]]--
function meta.__eq( c1, c2 )
	
	return
		c1.r == c2.r and
		c1.g == c2.g and
		c1.b == c2.b --and
		--c1.a == c2.a

end
--[[----------------------------------------------------------------------]]--
function meta.__gt( c1, c2 )

	return
		c1.r > c2.r and
		c1.g > c2.g and
		c1.b > c2.b --and
		--c1.a > c2.a
	
end
--[[----------------------------------------------------------------------]]--
function meta.__ge( c1, c2 )

	return
		c1.r >= c2.r and
		c1.g >= c2.g and
		c1.b >= c2.b --and
		--c1.a >= c2.a
	
end
--[[----------------------------------------------------------------------]]--
function meta.__lt( c1, c2 )

	return
		c1.r < c2.r and
		c1.g < c2.g and
		c1.b < c2.b --and
		--c1.a < c2.a
	
end
--[[----------------------------------------------------------------------]]--
function meta.__le( c1, c2 )

	return
		c1.r <= c2.r and
		c1.g <= c2.g and
		c1.b <= c2.b --and
		--c1.a <= c2.a
	
end
--[[----------------------------------------------------------------------]]--
function meta.__tostring( c1 )

	return string.format( "(%u,\t%u,\t%u,\t%u)", c1.r, c1.g, c1.b, c1.a )

end
