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
			
			Color()		 ==> Makes White	(255,	255,	255,	255)
			Color( _, 0, 0 ) ==> Makes Red		(255,	0,	0,	255)
			Color( 0, _, 0 ) ==> Makes Green	(0,	255,	0,	255)
			color( 0, 0, _ ) ==> Makes Blue		(0,	0,	255,	255)
			
			print( Color() )		==> (255,	255,	255,	255)
			print( Color( 0 ) )		==> (0,		255,	255,	255)
			print( Color( _, 0 ) )		==> (255,	0,	255,	255)
			print( Color( _, _, 0 ) )	==> (255,	255,	0,	255)
			print( Color( _, _, _, 0 ) )	==> (255,	255,	255,	0)
		
		**EXAMPLE #2:
			Performing arithmetic and relational operations on 2 Color objects

			local c1 = Color()             -- by default, this creates (r=255, g=255, b=255, a=255)
			local c2 = Color(55, 55, 55)
	
			print( c1 ) 	==> (255,	255,	255,	255)
			print( c2 ) 	==> (55,	55,	55,	255)
			
			print( c1 + c2 ) ==> (255,	255, 	255, 	255) because the values are clamped between 0 and 255
			print( c1 - c2 ) ==> (200,	200, 	200, 	255)
			print( c1 * c2 ) ==> (255,	255, 	255, 	255) because the values are clamped between 0 and 255
			print( c1 / c2 ) ==> (5, 	5, 	5, 	255) because the values are rounded to the nearest whole number
			
			print( c1 == c2 ) ==> false  because c1's r/g/b values are not all equal to c2's
			
			print( c1 >  c2 ) ==> true  because c1's r/g/b values are all greater than c2's
			print( c1 >= c2 ) ==> true  same as above
			
			print( c1 <  c2 ) ==> false because c1's r/g/b values are all not less than c2's
			print( c1 <= c2 ) ==> false same as above
		
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
		- Created April 12th, 2014
		- Added to GitHub April 14th, 2014
----------------------------------------------------------------------------]]

--[[--------------------------------------------------------------------------
-- Namespace Tables
--------------------------------------------------------------------------]]--

-- defines our metatable we'll assign to the color objects
local meta = { __index = meta, r = 255, g = 255, b = 255, a = 255 }

-- the list of acceptable types we can use to operate on the color object.
-- this will return the rgba values if given a table,
-- or return a number repeated 4 times to represent rbga values if given a number
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
			r = ( r and Round( Clamp( r, 0, 255 ) ) ) or 255,
			g = ( g and Round( Clamp( g, 0, 255 ) ) ) or 255,
			b = ( b and Round( Clamp( b, 0, 255 ) ) ) or 255,
			a = ( a and Round( Clamp( a, 0, 255 ) ) ) or 255 
		}, 
		meta 
	)
	
end

--[[--------------------------------------------------------------------------
--
-- 	ColorAlpha( color, number )
--
--	A replacement for Garry's ColorAlpha function. This will return a new Color
--	 object instead of just a table like the original function would.
--
--	Color() already handles clamping the alpha value, so we don't need to worry
--	 about it here.
--]]--
function ColorAlpha( c, a )

	return Color( c.r, c.g, c.b, a )
	
end

--[[--------------------------------------------------------------------------
--
-- 	color1 + color2
--	color  + number
--	number + color
--
--	Defines the behavior when attempting to add a value to a color object.
--	 You can add 2 color objects together, which will individually add their rgb fields together.
--	 You can also add a number to a color object, which will add the number to each of the rgb fields.
--
--	Operand ordering does not matter when adding. See below for an example.
--
--	E.g.,
--		Color(5,5,5) + Color(5,5,5) 	==> Color(10,10,10) -- adding 5 to 5 produces 10
--		Color(5,5,5) + 5		==> Color(10,10,10) -- adding 5 to 5 produces 10
--		5 + Color(5,5,5)		==> Color(10,10,10) -- we can reverse the operand ordering without issue
--
--]]--
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
--[[--------------------------------------------------------------------------
--
-- 	color1 - color2
--	color  - number
--  number - color
--
--	Defines the behavior when attempting to subtract a value from a color object.
--	 You can subtract 2 color objects together, which will individually subtract their rgb fields together.
--	 You can also subtract a number from a color object, which will subtract the number to each of the rgb fields.
--
--	***Operand ordering DOES matter when subtracting. See below for an example.
--
--	E.g.,
--		Color(5,5,5) - Color(2,2,2) 	==> Color(3,3,3) -- subtracting 2 from 5 produces 3
--		Color(5,5,5) - 2		==> Color(3,3,3) -- subtracting 2 from 5 produces 3
--		2 - Color(5,5,5)		==> Color(0,0,0) -- IMPORTANT! This tries to subtract 5 from 2 (AKA -3), which will be clamped to 0!
--
--]]--
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
--[[--------------------------------------------------------------------------
--
--	color1 * color2
--	color  * number
--	number * color
--
--	Defines the behavior when attempting to multiply a color object by a value.
--	 You can multiply 2 color objects together, which will individually multiply their rgb fields together.
--	 You can also multiply a color object by a number, which will multiply the number to each of the rgb fields.
--
--	Operand ordering does not matter when multiplying. See below for an example.
--
--	E.g.,
--		Color(5,5,5) * Color(2,2,2) 	==> Color(10,10,10) -- multiplying 5 by 2 produces 10
--		Color(5,5,5) * 2		==> Color(10,10,10) -- multiplying 5 by 2 produces 10
--		2 * Color(5,5,5)		==> Color(10,10,10) -- we can reverse the operand ordering without issue 
--
--]]--
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
--[[--------------------------------------------------------------------------
--
-- 	color1 / color2
--	color  / number
--	number / color
--
--	Defines the behavior when attempting to divide a color object by a value.
--	 You can divide 2 color objects together, which will individually divide their rgb fields together.
--	 You can also divide a color object by a number, which will each of the rgb fields by the number.
--
--	***Operand ordering DOES matter when dividing. See below for an example.
--
--	E.g.,
--		Color(10,10,10) / Color(5,5,5) 	==> Color(2,2,2) -- dividing 10 by 5 produces 2
--		Color(10,10,10) / 5		==> Color(2,2,2) -- dividing 10 by 5 produces 2
--		5 / Color(10,10,10)		==> Color(1,1,1) -- IMPORTANT! This tries to divide 5 by 10 (AKA 0.5), which will be rounded up to 1!
--
--]]--
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
--[[--------------------------------------------------------------------------
--
-- 	color1 == color2
--
--	Defines the behavior when comparing 2 color objects together by comparing 
--	 their rgb fields individually.
--	 
--	It should be noted that this function will never be called when comparing a
--	 non-color object with a color object. It will ALWAYS return false in that case. 
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
function meta.__eq( c1, c2 )
	
	return
		c1.r == c2.r and
		c1.g == c2.g and
		c1.b == c2.b --and
		--c1.a == c2.a

end
--[[--------------------------------------------------------------------------
--
-- 	color1 > color2
--
--	Defines the behavior when seeing if one color object is greater than another color object.
--
--	***This function is designed with the assumption that the color object with 
--	 larger values than the other color object will be larger overall.
--
--	***This indirectly implies that if color A's 'r' and 'g' fields are greater than
--	 the color B's 'r' and 'g', comparing A > B will return false if A's 'b' field
--	 is less than B's 'b' field. See below for an example.
--
--	E.g.,
--		Color() > Color(0,0,0)		==> true,  because 255 > 0, 255 > 0, 255 > 0
--		Color(255,255,0) > Color(0,0,1)	==> false, because A's 'b' (0) is not greater than B's 'b' (1)
--
--	As such, you should take caution when using these functions. 
--]]--
function meta.__gt( c1, c2 )

	return
		c1.r > c2.r and
		c1.g > c2.g and
		c1.b > c2.b --and
		--c1.a > c2.a
	
end
--[[--------------------------------------------------------------------------
--
-- 	color1 >= color2
--
--	Defines the behavior when seeing if one color object is greater than or the equal to another color object.
--
--	***This function is designed with the assumption that the color object with 
--	 larger values than the other color object will be larger overall.
--
--	***This indirectly implies that if color A's 'r' and 'g' fields are greater than
--	 the color B's 'r' and 'g', comparing A >= B will return false if A's 'b' field
--	 is less than B's 'b' field. See below for an example.
--
--	E.g.,
--		Color() >= Color()		 ==> true,  because 255 >= 255, 255 >= 255, 255 >= 255
--		Color() >= Color(0,0,0)		 ==> true,  because 255 > 0, 255 > 0, 255 > 0
--		Color(255,255,0) >= Color(0,0,1) ==> false, because A's 'b' (0) is not greater than or equal to B's 'b' (1)
--
--	As such, you should take caution when using these functions. 
--]]--
function meta.__ge( c1, c2 )

	return
		c1.r >= c2.r and
		c1.g >= c2.g and
		c1.b >= c2.b --and
		--c1.a >= c2.a
	
end
--[[--------------------------------------------------------------------------
--
-- 	color1 < color2
--
--	Defines the behavior when seeing if one color object is less than another color object
--
--	***This function is designed with the assumption that the color object with 
--	 smaller values than the other color object will be smaller overall.
--
--	***This indirectly implies that if color A's 'r' and 'g' fields are less than
--	 the color B's 'r' and 'g', comparing A < B will return false if A's 'b' field
--	 is greater than B's 'b' field. See below for an example.
--
--	E.g.,
--		Color(0,0,0) < Color()		==> true,  because 0 < 255, 0 < 255, 0 < 255
--		Color(0,0,1) < Color(255,255,0)	==> false, because A's 'b' (1) is not less than B's 'b' (0)
--
--	As such, you should take caution when using these functions. 
--]]--
function meta.__lt( c1, c2 )

	return
		c1.r < c2.r and
		c1.g < c2.g and
		c1.b < c2.b --and
		--c1.a < c2.a
	
end
--[[--------------------------------------------------------------------------
--
-- 	color1 <= color2
--
--	Defines the behavior when seeing if one color object is less than or equal to another color object
--
--	***This function is designed with the assumption that the color object with 
--	 smaller values than the other color object will be smaller overall.
--
--	***This indirectly implies that if color A's 'r' and 'g' fields are less than
--	 the color B's 'r' and 'g', comparing A <= B will return false if A's 'b' field
--	 is greater than B's 'b' field. See below for an example.
--
--	E.g.,
--		Color(0,0,0) <= Color()		 ==> true,  because 0 <= 255, 0 <= 255, 0 <= 255
--		Color(0,0,1) <= Color(255,255,0) ==> false, because A's 'b' (1) is not less than or equal B's 'b' (0)
--
--	As such, you should take caution when using these functions. 
--]]--
function meta.__le( c1, c2 )

	return
		c1.r <= c2.r and
		c1.g <= c2.g and
		c1.b <= c2.b --and
		--c1.a <= c2.a
	
end
--[[--------------------------------------------------------------------------
--
-- 	print( col ) ==> (number, number, number, number)
--
--	Defines the behavior when retrieving a string representation of this color object.
--	 For convenience, the rgba fields are all returned surrounded in a pair of parenthesis
--	 and tab separate to improve readability.
--
--	This behavior differs from the table returned by Garry's Color() function.
--	 Whereas his implementation is solely a table containing r,g,b,a fields, 
--	 which required you to use PrintTable or a for-loop to see the contents,
--	 this color object will allow you to use print( col ) and see the individual contents.
--
--	Garry's:	print( Color(255,255,255) ) ==> table: 0x123abc
--	This:		print( Color(255,255,255) ) ==>	(255,	255,	255,	255)
--]]--
function meta.__tostring( c1 )

	return string.format( "(%u,\t%u,\t%u,\t%u)", c1.r, c1.g, c1.b, c1.a )

end
