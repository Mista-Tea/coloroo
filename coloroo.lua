--[[--------------------------------------------------------------------------
	File name:
		coloroo.lua
	
	Author:
		Mista-Tea ([IJWTB Thomas])
	
	File description:
		An object-oriented approach to using the Color() function. We've all
		 probably had instances where we wish we could quickly perform operations
		 on Colors without having to make custom or expensive functions to do it.
		 		 
		This script will allow you to use +, -, *, /, ==, >, >=, <, and <= on existing Colors
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
		- April 12th, 2014:	Created
		- April 14th, 2014: 	Added to GitHub
		- April 15th, 2014:		
			Added support for converting between RGB and HSV color spaces
			Added ColorObj:Set*, Add*, and Sub* convenience functions
		- April 16th, 2014:
			Added ColorObj:Copy()
			Added ColorObj:Mul* and Div* convenience functions
		- June, 2014:
			Color metatable officially supported by Garry's Mod (thanks _Kilburn!)
			Changed ColorOO to use the Color metatable
		- January 10th, 2015:
			Removed ColorAlpha, incompatible and no longer needed
----------------------------------------------------------------------------]]

--[[--------------------------------------------------------------------------
-- Namespace Tables
--------------------------------------------------------------------------]]--

local COLOR = FindMetaTable( "Color" )

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

--[[----------------------------------------------------------------------]]--
local function Clamp( num )

	return (num < 0 and 0) or (num > 255 and 255) or num

end
--[[----------------------------------------------------------------------]]--
function Color( r, g, b, a )
	
	return setmetatable( 
		{ 
			r = ( r and Clamp( r ) ) or 255,
			g = ( g and Clamp( g ) ) or 255,
			b = ( b and Clamp( b ) ) or 255,
			a = ( a and Clamp( a ) ) or 255 
		}, 
		COLOR 
	)
	
end
--[[--------------------------------------------------------------------------
-- Convenience Functions
--------------------------------------------------------------------------]]--
function COLOR:Copy()

	return Color( self.r, self.g, self.b, self.a )

end
--[[--------------------------------------------------------------------------
-- Arithmetic Functions
--------------------------------------------------------------------------]]--
function COLOR.__add( lhs, rhs )
	
	local lhsType = type( lhs )
	local rhsType = type( rhs )
	
	assert( operations[ lhsType ], "Attempt to add '" .. tostring( lhs ) .. "' to Color object (a " .. type( lhs ) .. " value)" )
	assert( operations[ rhsType ], "Attempt to add '" .. tostring( rhs ) .. "' to Color object (a " .. type( rhs ) .. " value)" )
	
	local r1, g1, b1, a1 = operations[ lhsType ]( lhs )
	local r2, g2, b2, a2 = operations[ rhsType ]( rhs )
	
	return Color(
		r1 + r2,
		g1 + g2,
		b1 + b2,
		a1 + a2
	)
	
end
--[[----------------------------------------------------------------------]]--
function COLOR.__sub( lhs, rhs )
	
	local lhsType = type( lhs )
	local rhsType = type( rhs )
	
	assert( operations[ lhsType ], "Attempt to subtract '" .. tostring( lhs ) .. "' to Color object (a " .. type( lhs ) .. " value)" )
	assert( operations[ rhsType ], "Attempt to subtract '" .. tostring( rhs ) .. "' to Color object (a " .. type( rhs ) .. " value)" )
	
	local r1, g1, b1, a1 = operations[ lhsType ]( lhs )
	local r2, g2, b2, a2 = operations[ rhsType ]( rhs )
	
	return Color( 
		r1 - r2, 
		g1 - g2, 
		b1 - b2,
		a1 - a2
	)

end
--[[----------------------------------------------------------------------]]--
function COLOR.__mul( lhs, rhs )
	
	local lhsType = type( lhs )
	local rhsType = type( rhs )
	
	assert( operations[ lhsType ], "Attempt to multiply '" .. tostring( lhs ) .. "' to Color object (a " .. type( lhs ) .. " value)" )
	assert( operations[ rhsType ], "Attempt to multiply '" .. tostring( rhs ) .. "' to Color object (a " .. type( rhs ) .. " value)" )
		
	local r1, g1, b1, a1 = operations[ lhsType ]( lhs )
	local r2, g2, b2, a2 = operations[ rhsType ]( rhs )
	
	return Color( 
		r1 * r2, 
		g1 * g2, 
		b1 * b2,
		a1 * a2
	)

end
--[[----------------------------------------------------------------------]]--
function COLOR.__div( lhs, rhs )
	
	local lhsType = type( lhs )
	local rhsType = type( rhs )
	
	assert( operations[ lhsType ], "Attempt to divide '" .. tostring( lhs ) .. "' to Color object (a " .. type( lhs ) .. " value)" )
	assert( operations[ rhsType ], "Attempt to divide '" .. tostring( rhs ) .. "' to Color object (a " .. type( rhs ) .. " value)" )
	
	local r1, g1, b1, a1 = operations[ lhsType ]( lhs )
	local r2, g2, b2, a2 = operations[ rhsType ]( rhs )
	
	return Color( 
		( r1 == 0 or r2 == 0 and 0 ) or r1 / r2, 
		( g1 == 0 or g2 == 0 and 0 ) or g1 / g2, 
		( b1 == 0 or b2 == 0 and 0 ) or b1 / b2,
		( a1 == 0 or a2 == 0 and 0 ) or a1 / a2
	)

end
--[[--------------------------------------------------------------------------
-- Relational Functions
--------------------------------------------------------------------------]]--
function COLOR.__eq( lhs, rhs )
	
	return
		lhs.r == rhs.r and
		lhs.g == rhs.g and
		lhs.b == rhs.b and
		lhs.a == rhs.a
end
--[[----------------------------------------------------------------------]]--
function COLOR.__lt( lhs, rhs )

	local _, _, lhsV = lhs:ToHSV()
	local _, _, rhsV = rhs:ToHSV()
	
	return lhsV < rhsV
	
end

function COLOR.__le( lhs, rhs )

	local _, _, lhsV = lhs:ToHSV()
	local _, _, rhsV = rhs:ToHSV()
	
	return lhsV <= rhsV
	
end
--[[--------------------------------------------------------------------------
-- String Functions
--------------------------------------------------------------------------]]--
function COLOR.__tostring( lhs )

	return string.format( "(%u,\t%u,\t%u,\t%u)", lhs.r, lhs.g, lhs.b, lhs.a )

end
--[[--------------------------------------------------------------------------
-- HSV <==> RGB Conversion Functions
--------------------------------------------------------------------------]]--
function ColorToHSV( c )

	local r = c.r / 255 
	local g = c.g / 255 
	local b = c.b / 255 
	local a = c.a
	
	local max = math.max( r, g, b )
	local min = math.min( r, g, b )
	
	local h, s, v = 0, 0, max

	local delta = max - min
		
	if ( max == 0 ) then
		return h, s, v, a
	else
		s = delta / max
	end
	
	if ( min == max ) then 
		h = 0
	else
		if     ( r == max ) then h =     ( g - b ) / delta
		elseif ( g == max ) then h = 2 + ( b - r ) / delta
		else                     h = 4 + ( r - g ) / delta
		end
		
		h = h * 60
		h = ( h < 0 and (h + 360) ) or h
	end
	
	return h, s, v, a
	
end
--[[----------------------------------------------------------------------]]--
local sectors = {
	[0] = function( v, p, q, t ) return v, t, p end,
	[1] = function( v, p, q, t ) return q, v, p end,
	[2] = function( v, p, q, t ) return p, v, t end,
	[3] = function( v, p, q, t ) return p, q, v end,
	[4] = function( v, p, q, t ) return t, p, v end,
	[5] = function( v, p, q, t ) return v, p, q end,
}

function HSVToColor( h, s, v, a )
	
	local r, g, b
	
	if ( s == 0 ) then
	
		r, g, b = v, v, v
		
	else

		h = h / 60
		local i = math.floor( h )
		local f = h - i
		local p = v * ( 1 - s )
		local q = v * ( 1 - s * f )
		local t = v * ( 1 - s * ( 1 - f ) )
		
		i = i % 6
		
		r, g, b = sectors[ i ]( v, p, q, t )
	
	end
	
	return Color( r*255, g*255, b*255, a )
	
end
--[[----------------------------------------------------------------------]]--
function COLOR:ToHSV()

	return ColorToHSV( self )
	
end
--[[----------------------------------------------------------------------]]--
function HSVToRGB( h, s, v, a )

	local c = HSVToColor( h, s, v, a )

	return c.r, c.g, c.b, c.a
	
end

--[[----------------------------------------------------------------------]]--
function RGBToHSV( r, g, b, a )

	return Color( r, g, b, a ):ToHSV()
	
end
--[[--------------------------------------------------------------------------
-- Setting Functions
--------------------------------------------------------------------------]]--
function COLOR:SetAlpha( a )
	
	return self:SetA( a )
	
end
--[[----------------------------------------------------------------------]]--
function COLOR:SetR( r )

	self.r = Clamp( r )
	return self

end
--[[----------------------------------------------------------------------]]--
function COLOR:SetG( g )
	
	self.g = Clamp( g )
	return self
	
end
--[[----------------------------------------------------------------------]]--
function COLOR:SetB( b )

	self.b = Clamp( b )
	return self
	
end
--[[----------------------------------------------------------------------]]--
function COLOR:SetA( a )

	self.a = Clamp( a )
	return self

end
--[[--------------------------------------------------------------------------
-- Addition Functions
--------------------------------------------------------------------------]]--
function COLOR:AddR( r )
	
	assert( math.abs( r ) == r, "Parameter should be a positive number" )
	
	self.r = Clamp( self.r + r )
	return self
	
end
--[[----------------------------------------------------------------------]]--
function COLOR:AddG( g )

	assert( math.abs( g ) == g, "Parameter should be a positive number" )
	
	self.g = Clamp( self.g + g )
	return self
	
end
--[[----------------------------------------------------------------------]]--
function COLOR:AddB( b )
	
	assert( math.abs( b ) == b, "Parameter should be a positive number" )
	
	self.b = Clamp( self.b + b )
	return self
	
end
--[[----------------------------------------------------------------------]]--
function COLOR:AddA( a )
	
	assert( math.abs( a ) == a, "Parameter should be a positive number" )
	
	self.a = Clamp( self.a + a )
	return self
	
end
--[[--------------------------------------------------------------------------
-- Subtraction Functions
--------------------------------------------------------------------------]]--
function COLOR:SubR( r )

	assert( math.abs( r ) == r, "Parameter should be a positive number" )

	self.r = Clamp( self.r - r )
	return self
	
end
--[[----------------------------------------------------------------------]]--
function COLOR:SubG( g )
	
	assert( math.abs( g ) == g, "Parameter should be a positive number" )
	
	self.g = Clamp( self.g - g )
	return self
	
end
--[[----------------------------------------------------------------------]]--
function COLOR:SubB( b )

	assert( math.abs( b ) == b, "Parameter should be a positive number" )
	
	self.b = Clamp( self.b - b )
	return self
	
end
--[[----------------------------------------------------------------------]]--
function COLOR:SubA( a )
	
	assert( math.abs( a ) == a, "Parameter should be a positive number" )
	
	self.a = Clamp( self.a - a )
	return self
	
end
--[[--------------------------------------------------------------------------
-- Multiplication Functions
--------------------------------------------------------------------------]]--
function COLOR:MulR( r )

	assert( math.abs( r ) == r, "Parameter should be a positive number" )

	self.r = Clamp( self.r * r )
	return self
	
end
--[[----------------------------------------------------------------------]]--
function COLOR:MulG( g )
	
	assert( math.abs( g ) == g, "Parameter should be a positive number" )
	
	self.g = Clamp( self.g * g )
	return self
	
end
--[[----------------------------------------------------------------------]]--
function COLOR:MulB( b )

	assert( math.abs( b ) == b, "Parameter should be a positive number" )
	
	self.b = Clamp( self.b * b )
	return self
	
end
--[[----------------------------------------------------------------------]]--
function COLOR:MulA( a )
	
	assert( math.abs( a ) == a, "Parameter should be a positive number" )
	
	self.a = Clamp( self.a * a )
	return self
	
end
--[[--------------------------------------------------------------------------
-- Division Functions
--------------------------------------------------------------------------]]--
function COLOR:DivR( r )

	assert( math.abs( r ) == r, "Parameter should be a positive number" )

	self.r = ( r == 0 and 0 ) or Clamp( self.r / r )
	return self
	
end
--[[----------------------------------------------------------------------]]--
function COLOR:DivG( g )
	
	assert( math.abs( g ) == g, "Parameter should be a positive number" )
	
	self.g = ( g == 0 and 0 ) or Clamp( self.g / g )
	return self
	
end
--[[----------------------------------------------------------------------]]--
function COLOR:DivB( b )

	assert( math.abs( b ) == b, "Parameter should be a positive number" )
	
	self.b = ( b == 0 and 0 ) or Clamp( self.b / b )
	return self
	
end
--[[----------------------------------------------------------------------]]--
function COLOR:DivA( a )
	
	assert( math.abs( a ) == a, "Parameter should be a positive number" )
	
	self.a = ( a == 0 and 0 ) or Clamp( self.a / a )
	return self
	
end