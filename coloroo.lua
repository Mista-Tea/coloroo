--[[--------------------------------------------------------------------------
	File name:
		color.lua
	
	Author:
		Mista-Tea ([IJWTB Thomas])
	
	File description:
		An object-oriented approach to using the Color() function. We've all
		 probably had instances where we wish we could quickly perform operations
		 on Colors without having to make custom or expensive functions to do it.
		 		 
		This script will allow you to use +, -, *, /, ==, >, >=, <, and <= on existing Colors
		 by overriding the default Color() function to return an object whose metatable supports
		 arithmetic and relation operations.
		
		E.g.,
			Color() + Color()	and	Color() + 5
			Color() - Color()	and	Color() - 5
			Color() * Color()	and	Color() * 5
			Color() / Color()	and	Color() / 5
			
			Color() == Color()
			Color() >  Color()
			Color() >= Color()
			Color() <  Color()
			Color() <= Color()
		
		**EXAMPLE #1:
			Constructing Color objects
			
			Fields that aren't supplied will default to 255. 
			You can skip fields by supplying _ or nil as a parameter.
			
			Color()			==>	Makes White	(255,	255,	255,	255)
			Color( _, 0, 0 )	==>	Makes Red	(255,	0,	0,	255)
			Color( 0, _, 0 ) 	==>	Makes Green	(0,	255,	0,	255)
			color( 0, 0, _ ) 	==>	Makes Blue	(0,	0,	255,	255)
			
			print( Color() )		==>	(255,	255,	255,	255)
			print( Color( 0 ) )		==> 	(0,	255,	255,	255)
			print( Color( _, 0 ) )		==> 	(255,	0,	255,	255)
			print( Color( _, _, 0 ) )	==>	(255,	255,	0,	255)
			print( Color( _, _, _, 0 ) )	==> 	(255,	255,	255,	0)
		
		**EXAMPLE #2:
			Performing arithmetic and relational operations on 2 Color objects

			local lhs = Color()             -- by default, this creates (r=255, g=255, b=255, a=255)
			local rhs = Color(55, 55, 55)
	
			print( lhs ) 		==> (255,	255,	255,	255)
			print( rhs ) 		==> (55,	55,	55,	255)
			
			print( lhs + rhs ) 	==> (255,	255, 	255, 	255) because the values are clamped between 0 and 255
			print( lhs - rhs ) 	==> (200,	200, 	200, 	255)
			print( lhs * rhs ) 	==> (255,	255, 	255, 	255) because the values are clamped between 0 and 255
			print( lhs / rhs ) 	==> (5, 	5, 	5,	255) because the values are rounded to the nearest whole number
			
			print( lhs == rhs ) 	==> false  because lhs's r/g/b values are not all equal to rhs's
			
			print( lhs >  rhs )	==> true  because lhs's r/g/b values are all greater than rhs's
			print( lhs >= rhs )	==> true  same as above
			
			print( lhs <  rhs )	==> false because lhs's r/g/b values are all not less than rhs's
			print( lhs <= rhs )	==> false same as above
		
		**EXAMPLE #3:
			Performing arithmetic and relational operations on Color objects using numbers
			
			local c = Color(100, 100, 100)
			
			print( c + 5 ) 	==> (105,	105,	105,	255)
			print( c - 5 ) 	==> (95, 	95, 	95,	255)
			print( c * 2 ) 	==> (200, 	200,	200,	255)
			print( c / 2 ) 	==> (50, 	50,	50,	255)
			
			print( c == 5 ) ==> false because number types don't have the same __eq metamethod (will ALWAYS return false when equating with a non-table value)
			
			NOT SUPPORTED:
			
			print( c >  5 ) ==> attempt to compare number with table (not a supported operation)
			print( c >= 5 ) ==> attempt to compare number with table (not a supported operation)
			print( c <  5 ) ==> attempt to compare number with table (not a supported operation)
			print( c <= 5 ) ==> attempt to compare number with table (not a supported operation)		
			
			
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
			Added  Set*, Add*, and Sub* convenience functions
----------------------------------------------------------------------------]]

--[[--------------------------------------------------------------------------
-- Namespace Tables
--------------------------------------------------------------------------]]--

-- defines our metatable we'll assign to the Color objects
local meta = { r = 255, g = 255, b = 255, a = 255, h = 0, s = 0, v = 1 }
meta.__index = meta

-- the list of acceptable types we can use to operate on the Color object.
-- this will return the rgba values if given a table,
-- or return a number repeated 4 times to represent rbga values if given a number
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

--[[--------------------------------------------------------------------------
--
--	Round( number )
--
--	A localized replacement for Garry's math.Round function. This eliminates the
--	 decimal place parameter to reduce a few unneeded operations since we're
--	 going to be rounding to the nearest whole number.
--
--]]--
local function Round( num )

	return math.floor( num + 0.5 )
  
end

--[[--------------------------------------------------------------------------
--
--	Clamp( number )
--
--	A localized replacement for Garry's math.Clamp function. This eliminates the
--	 low and high parameters because we know we'll be clamping the number between
--	 0 and 255.
--
--]]--
local function Clamp( num )

	return (num < 0 and 0) or (num > 255 and 255) or num

end



--[[--------------------------------------------------------------------------
--
-- 	Color( number=255, number=255, number=255, number=255 )
--
--	Creates a new Color object.
--
--	You can omit any parameters you want, such as doing:
--		Color()		==> returns Color(255,255,255,255)
--		Color( _, 0 ) 	==> returns Color(255,0,255,255)
--
--	If any of the fields are not provided, they will default to 255.
--	 This behavior differs from the Garry's Color(), which will only allow
-- 	 you to omit the Alpha parameter.
--]]--
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



--[[--------------------------------------------------------------------------
--
-- 	ColorAlpha( color, number )
--
--	A replacement for Garry's ColorAlpha function. 
--
--	This now acts as a wrapper function for meta:SetA(), which directly 
--	 modifies the Color object's alpha value.
--]]--
function ColorAlpha( c, a )

	return c:SetA( a )
	
end

--[[--------------------------------------------------------------------------
--
-- 	meta:SetAlpha( number )
--
--	Wrapper function for Color():SetA()
--
--	Sets this Color's 'a' value to the given number, rounded to the nearest whole number
--	 and clamped between 0 and 255.
--]]--
function meta:SetAlpha( a )
	
	return self:SetA( a )
	
end



--[[--------------------------------------------------------------------------
--
-- 	meta:SetR( number )
--
--	Sets this Color's 'r' value to the given number, rounded to the nearest whole number
--	 and clamped between 0 and 255.
--]]--
function meta:SetR( r )

	self.r = Round( Clamp( r ) )
	return self

end

--[[--------------------------------------------------------------------------
--
-- 	meta:SetG( number )
--
--	Sets this Color's 'g' value to the given number, rounded to the nearest whole number
--	 and clamped between 0 and 255.
--]]--
function meta:SetG( g )
	
	self.g = Round( Clamp( g ) )
	return self
	
end

--[[--------------------------------------------------------------------------
--
-- 	meta:SetB( number )
--
--	Sets this Color's 'b' value to the given number, rounded to the nearest whole number
--	 and clamped between 0 and 255.
--]]--
function meta:SetB( b )

	self.b = Round( Clamp( b ) )
	return self
	
end

--[[--------------------------------------------------------------------------
--
-- 	meta:SetA( number )
--
--	Sets this Color's 'a' value to the given number, rounded to the nearest whole number
--	 and clamped between 0 and 255.
--]]--
function meta:SetA( a )

	self.a = Round( Clamp( a ) )
	return self

end




--[[--------------------------------------------------------------------------
--
-- 	meta:AddR( number )
--
--	Increments this Color's 'r' value by the given number, rounded to the 
--	 nearest whole number and clamped between 0 and 255.
--
--	print( Color( 0, 0, 0 ):AddR( 255 ) ) ==> (255,	0,	0,	255)
--]]--
function meta:AddR( r )
	
	self.r = Round( Clamp( self.r + r ) )
	return self
	
end

--[[--------------------------------------------------------------------------
--
-- 	meta:AddG( number )
--
--	Increments this Color's 'g' value by the given number, rounded to the 
--	 nearest whole number and clamped between 0 and 255.
--
--	print( Color( 0, 0, 0 ):AddG( 255 ) ) ==> (0,	255,	0,	255)
--]]--
function meta:AddG( g )
	
	self.g = Round( Clamp( self.g + g ) )
	return self
	
end

--[[--------------------------------------------------------------------------
--
-- 	meta:AddB( number )
--
--	Increments this Color's 'b' value by the given number, rounded to the 
--	 nearest whole number and clamped between 0 and 255.
--
--	print( Color( 0, 0, 0 ):AddR( 255 ) ) ==> (0,	0,	255,	255)
--]]--
function meta:AddB( b )
	
	self.b = Round( Clamp( self.b + b ) )
	return self
	
end

--[[--------------------------------------------------------------------------
--
-- 	meta:AddA( number )
--
--	Increments this Color's 'a' value by the given number, rounded to the 
--	 nearest whole number and clamped between 0 and 255.
--
--	print( Color( 0, 0, 0, 0 ):AddA( 255 ) ) ==> (0,	0,	0,	255)
--]]--
function meta:AddA( a )
	
	self.a = Round( Clamp( self.a + a ) )
	return self
	
end




--[[--------------------------------------------------------------------------
--
-- 	meta:SubR( number )
--
--	Decrements this Color's 'a' value by the given number, rounded to the 
--	 nearest whole number and clamped between 0 and 255.
--
--	print( Color():SubR( 255 ) ) ==> (0,	255,	255,	255)
--]]--
function meta:SubR( r )

	self.r = Round( Clamp( self.r - r ) )
	return self
	
end

--[[--------------------------------------------------------------------------
--
-- 	meta:SubG( number )
--
--	Decrements this Color's 'a' value by the given number, rounded to the 
--	 nearest whole number and clamped between 0 and 255.
--
--	print( Color():SubG( 255 ) ) ==> (255,	0,	255,	255)
--]]--
function meta:SubG( g )

	self.g = Round( Clamp( self.g - g ) )
	return self
	
end

--[[--------------------------------------------------------------------------
--
-- 	meta:SubB( number )
--
--	Decrements this Color's 'a' value by the given number, rounded to the 
--	 nearest whole number and clamped between 0 and 255.
--
--	print( Color():SubB( 255 ) ) ==> (255,	255,	0,	255)
--]]--
function meta:SubB( b )

	self.b = Round( Clamp( self.b - b ) )
	return self
	
end

--[[--------------------------------------------------------------------------
--
-- 	meta:SubA( number )
--
--	Decrements this Color's 'a' value by the given number, rounded to the 
--	 nearest whole number and clamped between 0 and 255.
--
--	print( Color():SubA( 255 ) ) ==> (255,	255,	255,	0)
--]]--
function meta:SubA( a )

	self.a = Round( Clamp( self.a - a ) )
	return self
	
end



--[[--------------------------------------------------------------------------
--
-- 	Color1 + Color2
--	Color  + number
--	number + Color
--
--	Defines the behavior when attempting to add a value to a Color object.
--	 You can add 2 Color objects together, which will individually add their rgb fields together.
--	 You can also add a number to a Color object, which will add the number to each of the rgb fields.
--
--	Operand ordering does not matter when adding. See below for an example.
--
--	E.g.,
--		Color(5,5,5) + Color(5,5,5)	==> Color(10,10,10) -- adding 5 to 5 produces 10
--		Color(5,5,5) + 5		==> Color(10,10,10) -- adding 5 to 5 produces 10
--		5 + Color(5,5,5)		==> Color(10,10,10) -- we can reverse the operand ordering without issue
--
--]]--
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

--[[--------------------------------------------------------------------------
--
-- 	Color1 - Color2
--	Color  - number
--  	number - Color
--
--	Defines the behavior when attempting to subtract a value from a Color object.
--	 You can subtract 2 Color objects together, which will individually subtract their rgb fields together.
--	 You can also subtract a number from a Color object, which will subtract the number to each of the rgb fields.
--
--	***Operand ordering DOES matter when subtracting. See below for an example.
--
--	E.g.,
--		Color(5,5,5) - Color(2,2,2)	==> Color(3,3,3) -- subtracting 2 from 5 produces 3
--		Color(5,5,5) - 2		==> Color(3,3,3) -- subtracting 2 from 5 produces 3
--		2 - Color(5,5,5)		==> Color(0,0,0) -- IMPORTANT! This tries to subtract 5 from 2 (AKA -3), which will be clamped to 0!
--
--]]--
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

--[[--------------------------------------------------------------------------
--
--	Color1 * Color2
--	Color  * number
--	number * Color
--
--	Defines the behavior when attempting to multiply a Color object by a value.
--	 You can multiply 2 Color objects together, which will individually multiply their rgb fields together.
--	 You can also multiply a Color object by a number, which will multiply the number to each of the rgb fields.
--
--	Operand ordering does not matter when multiplying. See below for an example.
--
--	E.g.,
--		Color(5,5,5) * Color(2,2,2)	==> Color(10,10,10) -- multiplying 5 by 2 produces 10
--		Color(5,5,5) * 2		==> Color(10,10,10) -- multiplying 5 by 2 produces 10
--		2 * Color(5,5,5)		==> Color(10,10,10) -- we can reverse the operand ordering without issue 
--
--]]--
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

--[[--------------------------------------------------------------------------
--
-- 	Color1 / Color2
--	Color  / number
--	number / Color
--
--	Defines the behavior when attempting to divide a Color object by a value.
--	 You can divide 2 Color objects together, which will individually divide their rgb fields together.
--	 You can also divide a Color object by a number, which will each of the rgb fields by the number.
--
--	***Operand ordering DOES matter when dividing. See below for an example.
--
--	E.g.,
--		Color(10,10,10) / Color(5,5,5)	==> Color(2,2,2) -- dividing 10 by 5 produces 2
--		Color(10,10,10) / 5		==> Color(2,2,2) -- dividing 10 by 5 produces 2
--		5 / Color(10,10,10)		==> Color(1,1,1) -- IMPORTANT! This tries to divide 5 by 10 (AKA 0.5), which will be rounded up to 1!
--
--]]--
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

--[[--------------------------------------------------------------------------
--
-- 	Color1 == Color2
--
--	Defines the behavior when comparing 2 Color objects together by comparing 
--	 their rgb fields individually.
--	 
--	It should be noted that this function will never be called when comparing a
--	 non-Color object with a Color object. It will ALWAYS return false in that case. 
--
--	See the below excerpt from the Lua manual:
--
--	"An equality comparison never raises an error, but if two objects have different 
--	 metamethods, the equality operation results in false, without even calling any 
--	 metamethod. Again, this behavior mimics the common behavior of Lua, which always 
--	 classifies strings as different from numbers, regardless of their values. 
--	 
--	Lua calls the equality metamethod only when the two objects being compared 
--	 share this metamethod."
--
--	Source: http://www.lua.org/pil/13.2.html
--]]--
function meta.__eq( lhs, rhs )
	
	return
		lhs.r == rhs.r and
		lhs.g == rhs.g and
		lhs.b == rhs.b
end

--[[--------------------------------------------------------------------------
--
-- 	Color1 < Color2
--
--	Defines the behavior when seeing if one Color object is less than another Color object
--
--	***This function is designed with the assumption that the Color object with 
--	 smaller values than the other Color object will be smaller overall.
--
--	***This indirectly implies that if Color A's 'r' and 'g' fields are less than
--	 the Color B's 'r' and 'g', comparing A < B will return false if A's 'b' field
--	 is greater than B's 'b' field. See below for an example.
--
--	E.g.,
--		Color(0,0,0) < Color()		==> true,  because 0 < 255, 0 < 255, 0 < 255
--		Color(0,0,1) < Color(255,255,0)	==> false, because A's 'b' (1) is not less than B's 'b' (0)
--
--	As such, you should take caution when using these functions. 
--]]--
function meta.__lt( lhs, rhs )

	return
		lhs.r < rhs.r and
		lhs.g < rhs.g and
		lhs.b < rhs.b
	
end

--[[--------------------------------------------------------------------------
--
-- 	Color1 <= Color2
--
--	Defines the behavior when seeing if one Color object is less than or equal to another Color object
--
--	***This function is designed with the assumption that the Color object with 
--	 smaller values than the other Color object will be smaller overall.
--
--	***This indirectly implies that if Color A's 'r' and 'g' fields are less than
--	 the Color B's 'r' and 'g', comparing A <= B will return false if A's 'b' field
--	 is greater than B's 'b' field. See below for an example.
--
--	E.g.,
--		Color(0,0,0) <= Color()			==> true,  because 0 <= 255, 0 <= 255, 0 <= 255
--		Color(0,0,1) <= Color(255,255,0)	==> false, because A's 'b' (1) is not less than or equal B's 'b' (0)
--
--	As such, you should take caution when using these functions. 
--]]--
function meta.__le( lhs, rhs )

	return
		lhs.r <= rhs.r and
		lhs.g <= rhs.g and
		lhs.b <= rhs.b
	
end



--[[--------------------------------------------------------------------------
--
-- 	print( col ) ==> (number, number, number, number)
--
--	Defines the behavior when retrieving a string representation of this Color object.
--	 For convenience, the rgba fields are all returned surrounded in a pair of parenthesis
--	 and tab separate to improve readability.
--
--	This behavior differs from the table returned by Garry's Color() function.
--	 Whereas his implementation is solely a table containing r,g,b,a fields, 
--	 which required you to use PrintTable or a for-loop to see the contents,
--	 this Color object will allow you to use print( col ) and see the individual contents.
--
--	Garry's:	print( Color(255,255,255) ) ==> table: 0x123abc
--	This:		print( Color(255,255,255) ) ==>	(255,	255,	255,	255)
--]]--
function meta.__tostring( lhs )

	return string.format( "(%u,\t%u,\t%u,\t%u)", lhs.r, lhs.g, lhs.b, lhs.a )

end



--[[--------------------------------------------------------------------------
--
--	meta:ToHSV()
--
--	Returns the HSV color space and current Alpha of this Color object.
--
--	E.g.,
--		print( Color():ToHSV() ) 		==> 0, 0, 1, 255
--		print( Color(255,0,0,0):ToHSV() )	==> 0, 1, 1, 0
--
--	Wikipedia resource: http://en.wikipedia.org/wiki/HSL_and_HSV
--
--	Created with the help of:
--	 http://www.cs.rit.edu/~ncs/color/t_convert.html
--	 https://github.com/EmmanuelOga/columns/blob/master/utils/color.lua
--]]--
function meta:ToHSV()

	r = self.r / 255 
	g = self.g / 255 
	b = self.b / 255 
	a = self.a
	
	local max = math.max(r, g, b)
	local min = math.min(r, g, b)
	
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

--[[--------------------------------------------------------------------------
--
--	HSVToColor( number, number, number, number )
--
--	A replacement for Garry's HSVToColor() function.
--	 This function will now return a Color object instead of Garry's Color() table.
--
--	Wikipedia resource: http://en.wikipedia.org/wiki/HSL_and_HSV
--
--	Created with the help of:
--	 http://www.cs.rit.edu/~ncs/color/t_convert.html
--	 https://github.com/EmmanuelOga/columns/blob/master/utils/color.lua
--]]--
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

--[[--------------------------------------------------------------------------
--
--	ColorToHSV( Color object )
--
--	Wrapper function for Color():ToHSV()
--
--	Returns the HSVA color space of the given Color object
--
--	E.g.,
--		print( ColorToHSV( Color() ) ) 		==>	0,	0,	1,	255
--		print( ColorToHSV( Color(0,0,0,0) ) 	==>	0,	0,	0,	0
--]]--
function ColorToHSV( color )

	return color:ToHSV()
	
end

--[[--------------------------------------------------------------------------
--
--	HSVToRGB( number, number, number, number=255 )
--
--	Wrapper function for HSVToColor()
--
--	Returns the RGBA color space from the given HSVA values.
--	 If the Alpha parameter is not given, 255 will be returned by default.
--
--	E.g.,
--		print( HSVToRGB( 0, 0, 1 ) )	==> 255, 255, 255, 255
--		print( HSVToRGB( 0, 0, 0 ) ) 	==> 0, 0, 0, 255
--
--		print( HSVToRGB( 0, 0, 0, 0 ) )	==> 255, 0, 0, 0
--
--		print( HSVToRGB
--]]--
function HSVToRGB( h, s, v, a )

	local c = HSVToColor( h, s, v, a )

	return c.r, c.g, c.b, c.a
	
end

--[[--------------------------------------------------------------------------
--
--	RGBToHSV( number=255, number=255, number=255, number=255 )
--
--	Wrapper function for Color():ToHSV()
--
--	Returns the HSVA color space from the given RGBA values.
--	 Any parameters that are not supplied will default to 255.
--
--	E.g.,
--		print( RGBToHSV( 255, 255, 255 ) )	==> 0, 0, 1, 255
--		print( RGBToHSV( 0, 0, 0 ) ) 		==> 0, 0, 0, 255
--
--		print( RGBToHSV( _, _, _, 0 ) )		==> 0, 0, 1, 0
--]]--
function RGBToHSV( r, g, b, a )

	return Color( r, g, b, a ):ToHSV()
	
end