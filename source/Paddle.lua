--[[
	This is for CS50x 2020
	Games Track / Pong

	-- Paddle Class --

	Author of the code & co-author of comments: Luke Turpin
	turpinluke@googlemail.com

	Co-author of comments: Colton Ogden
	cogden@cs50.harvard.edu
]]

--[[
	Represents a paddle that can move up and down. Used in the main
	program to deflect the ball back toward the opponent.
]]
Paddle = Class{}

--[[
	The `init` function on our class is called just once, when the object
	is first created. Used to set up all variables in the class.

	Our Paddle should take an X and a Y, for positioning, as well as a width
	and height for its dimensions.

	Note that `self` is a reference to *this* object. Different objects can
	have their own x, y, width, and height values, thus serving as containers
	for data. In this sense, they're very similar to structs in C.
]]
function Paddle:init(x, y, width, height)

	self.x = x
	self.y = y
	self.width = width
	self.height = height
	self.dy = 0

end

function Paddle:ai(ball)

	if ball.y < self.y + self.height / 2 then
		return 'move_up'
	elseif ball.y > self.y + self.height / 2 then
		return 'move_down'
	end

end

function Paddle:update(dt)

	if self.dy < 0 then
		
		--[[
			The 'math.max' ensures that we're the greater of 0 or the player's
			current calculated Y position when pressing up so that the paddle
			doesn't disappear off our screen; the movement calculation is simply our
			previously-defined paddle speed scaled by dt
		]]
		self.y = math.max(0, self.y + self.dy * dt)
	else
		
		--[[
			Similar to above, the 'math.min' ensures we don't go any farther than the 
			bottom of the screen minus the paddle's height (or else it will go partially 
			below, since position is based on its top left corner)
		]]
		self.y = math.min(VIRTUAL_HEIGHT - self.height, self.y + self.dy * dt)
	end

end

function Paddle:reset()

	self.y = VIRTUAL_HEIGHT / 2 - self.height / 2
	self.dy = 0

end

--[[
	The 'render' function to be called by our main function in `love.draw`. Uses
	LÖVE2D's `rectangle` function, which takes in a draw mode as the first
	argument as well as the position and dimensions for the rectangle.
]]
function Paddle:render()
	
	love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)

end

function Paddle:highlight()

	love.graphics.rectangle('line', self.x - 2, self.y - 2, self.width + 4, self.height + 3)

end