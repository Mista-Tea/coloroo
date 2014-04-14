--[[--------------------------------------------------------------------------
	File name:
		color.lua
	
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

local meta = { r = 255, g = 255, b = 255, a = 255 }
meta.__index = meta

local operations = {
	table  = function( col ) return col.r, col.g, col.b, col.a end,
	number = function( num ) return num,     num,   num,   num end,
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
			r = ( r and Round( Clamp( r ) ) ) or 255,
			g = ( g and Round( Clamp( g ) ) ) or 255,
			b = ( b and Round( Clamp( b ) ) ) or 255,
			a = ( a and Round( Clamp( a ) ) ) or 255 
		}, 
		meta 
	)
	
end
--[[----------------------------------------------------------------------]]--
function ColorAlpha( c, a )

	return Color( c.r, c.g, c.b, a )
	
end
--[[----------------------------------------------------------------------]]--
function meta.__add( lhs, rhs )
	
	local lhsType = type( lhs )
	local rhsType = type( rhs )
	
	assert( operations[ lhsType ], "Attempt to add '" .. tostring( lhs ) .. "' to Color object (a " .. type( lhs ) .. " value)" )
	assert( operations[ rhsType ], "Attempt to add '" .. tostring( rhs ) .. "' to Color object (a " .. type( rhs ) .. " value)" )
	
	local r1, g1, b1, a1 = operations[ lhsType ]( lhs )
	local r2, g2, b2, a2 = operations[ rhsType ]( rhs )
	
	return Color(
		r1 + r2, 
		g1 + g2, 
		b1 + b2 
	)
	
end
--[[----------------------------------------------------------------------]]--
function meta.__sub( lhs, rhs )
	
	local lhsType = type( lhs )
	local rhsType = type( rhs )
	
	assert( operations[ lhsType ], "Attempt to subtract '" .. tostring( lhs ) .. "' to Color object (a " .. type( lhs ) .. " value)" )
	assert( operations[ rhsType ], "Attempt to subtract '" .. tostring( rhs ) .. "' to Color object (a " .. type( rhs ) .. " value)" )
	
	local r1, g1, b1, a1 = operations[ lhsType ]( lhs )
	local r2, g2, b2, a2 = operations[ rhsType ]( rhs )
	
	return Color( 
		r1 - r2, 
		g1 - g2, 
		b1 - b2 
	)

end
--[[----------------------------------------------------------------------]]--
function meta.__mul( lhs, rhs )
	
	local lhsType = type( lhs )
	local rhsType = type( rhs )
	
	assert( operations[ lhsType ], "Attempt to multiply '" .. tostring( lhs ) .. "' to Color object (a " .. type( lhs ) .. " value)" )
	assert( operations[ rhsType ], "Attempt to multiply '" .. tostring( rhs ) .. "' to Color object (a " .. type( rhs ) .. " value)" )
		
	local r1, g1, b1, a1 = operations[ lhsType ]( lhs )
	local r2, g2, b2, a2 = operations[ rhsType ]( rhs )
	
	return Color( 
		r1 * r2, 
		g1 * g2, 
		b1 * b2 
	)

end
--[[----------------------------------------------------------------------]]--
function meta.__div( lhs, rhs )
	
	local lhsType = type( lhs )
	local rhsType = type( rhs )
	
	assert( operations[ lhsType ], "Attempt to divide '" .. tostring( lhs ) .. "' to Color object (a " .. type( lhs ) .. " value)" )
	assert( operations[ rhsType ], "Attempt to divide '" .. tostring( rhs ) .. "' to Color object (a " .. type( rhs ) .. " value)" )
	
	local r1, g1, b1, a1 = operations[ lhsType ]( lhs )
	local r2, g2, b2, a2 = operations[ rhsType ]( rhs )
	
	return Color( 
		r1 / r2, 
		g1 / g2, 
		b1 / b2 
	)

end
--[[----------------------------------------------------------------------]]--
function meta.__eq( lhs, rhs )
	
	return
		lhs.r == rhs.r and
		lhs.g == rhs.g and
		lhs.b == rhs.b
end
--[[----------------------------------------------------------------------]]--
function meta.__lt( lhs, rhs )

	return
		lhs.r < rhs.r and
		lhs.g < rhs.g and
		lhs.b < rhs.b
	
end
--[[----------------------------------------------------------------------]]--
function meta.__le( lhs, rhs )

	return
		lhs.r <= rhs.r and
		lhs.g <= rhs.g and
		lhs.b <= rhs.b
	
end
--[[----------------------------------------------------------------------]]--
function meta.__tostring( lhs )

	return string.format( "(%u,\t%u,\t%u,\t%u)", lhs.r, lhs.g, lhs.b, lhs.a )

end