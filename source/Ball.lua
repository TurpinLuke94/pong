--[[
	This is for CS50x 2020
	Games Track / Pong

	-- Ball Class --

	Author of the code & co-author of comments: Luke Turpin
	turpinluke@googlemail.com

	Co-author of comments: Colton Ogden
	cogden@cs50.harvard.edu
]]

--[[
	Represents a ball which will bounce back and forth between paddles
	and walls until it passes a left or right boundary of the screen,
	scoring a point for the opponent.
]]
Ball = Class{}

--[[
	The `init` function on our class is called just once, when the object
	is first created. Used to set up all variables in the class.

	Our ball should take an X and a Y, for positioning, as well as a width
	and height for its dimensions.

	Note that `self` is a reference to *this* object. Different objects can
	have their own x, y, width, and height values, thus serving as containers
	for data. In this sense, they're very similar to structs in C.
]]
function Ball:init(x, y, width, height)

	self.x = x
	self.y = y
	self.width = width
	self.height = height
	
	--[[
		These variables below are for keeping track of our velocity on both the
		X and Y axis, since the ball can move in two dimensions. 
	]]
	
	--[[
		The 'math.randon(2)' will either result in a value of 1 which will assign a random 
		number between -80 and -100 to 'self.dx' or the value of 2 which assigns a 
		random number between 80 and 100 to 'self.dx'.
	]]
	self.dx = 0
	
	--[[
		The 'math.randon(2)' will either result in a value of 1 which will assign -100
		to 'self.dy' or the value of 2 which assigns 100 to 'self.dy'.
	]]
	self.dy = 0

end

--[[
	Simply applies velocity to position, scaled by the delta time between frames.
]]
function Ball:update(dt)

	self.x = self.x + self.dx * dt
	self.y = self.y + self.dy * dt

end

--[[
	Expects a paddle as an argument and returns true or false, depending
	on whether their rectangles overlap.
]]
function Ball:collides(paddle)
	
	--[[
		Checks to see if the left edge of either, the ball or a paddle, is farther to the right
		than the right edge of the other.
	]]
	if self.x > paddle.x + paddle.width or self.x + self.width < paddle.x then
		return false
	
	--[[
		Checks to see if the bottom edge of either, the ball or a paddle, is higher than the
		top edge of the other.
	]]
	elseif self.y >= paddle.y + paddle.height or self.y + self.height <= paddle.y then
		return false
	else
		
	--  If the above aren't true, they're overlapping (colliding) so true is returned
		return true
	end

end

--[[
	
]]
function Ball:reset(paddle)

	if self.x + self.width < 0 then
		self.x = paddle.x + paddle.width + 10
	elseif self.x > VIRTUAL_WIDTH then
		self.x = paddle.x - self.width - 10
	end
	
	self.y = VIRTUAL_HEIGHT / 2 - self.height / 2
	
	--[[
		The 'math.randon(2)' will either result in a value of 1 which will assign -100
		to 'self.dx' or the value of 2 which assigns 100 to 'self.dx'.
	]]
	self.dx = 0

	--[[
		The 'math.randon(2)' will result in a value between -50 and 50 and will assign 
		the value to 'self.dy'.
	]]
	self.dy = 0

end

function Ball:restart()

	self.x = VIRTUAL_WIDTH / 2 - self.width / 2
	self.y = VIRTUAL_HEIGHT / 2 - self.height / 2
	self.dx = 0
	self.dy = 0

end

--[[
	The 'render' function to be called by our main function in `love.draw`. Uses
	LÖVE2D's `rectangle` function, which takes in a draw mode as the first
	argument as well as the position and dimensions for the rectangle.
]]
function Ball:render()

	love.graphics.rectangle('fill', self.x, self.y, 4, 4)

end