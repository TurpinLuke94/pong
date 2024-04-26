--[[
	This is for CS50x 2020
	Games Track / Pong

	Author of the code & co-author of comments: Luke Turpin
	turpinluke@googlemail.com

	Co-author of comments: Colton Ogden
	cogden@cs50.harvard.edu

	Originally programmed by Atari in 1972. Features two
	paddles, controlled by players, with the goal of getting
	the ball past your opponent's edge. First to 10 points wins.

	This version is built to more closely resemble the NES than
	the original Pong machines or the Atari 2600 in terms of
	resolution, though in widescreen (16:9) so it looks nicer on 
	modern systems.
]]

--[[
	The "Class" library we're using will allow us to represent anything in
	our game as code, rather than keeping track of many disparate variables and
	methods.
	https://github.com/vrld/hump/blob/master/class.lua
]]
Class = require 'class'

--[[
	The "Push" library will allow us to draw our game at a virtual resolution, 
	instead of however large our window is; used to provide a more retro aesthetic.
	https://github.com/Ulydev/push
]]
push = require 'push'

--[[
	Our Ball class, which isn't much different than a Paddle structure-wise
	but which will mechanically function very differently.
]]
require 'Ball'

--[[
	Our Paddle class, which stores position and dimensions for each Paddle and the 
	logic for rendering them.
]]
require 'Paddle'

--	Constant values for the resolution that the application window will open with.
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

--[[
	Constant value for the virtual resolution that the 'push libary' will actually draw in the 
	application window which will give the game a more retro look to it.
]]
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

--	Constant value for the speeds at which we will move our paddlea, multiplied by dt in 'love.update()'.
SLOW_PADDLE_SPEED = 100
FAST_PADDLE_SPEED = 200

--	Runs when the game first starts up, only once; used to initialize the game.
function love.load()

	--[[
		Seeds the random number generator so that calls to 'math.random()' are always random.
		Use's the current time in seconds, since that will vary on startup every time.
	]]
	math.randomseed(os.time())

	--[[
		Sets love's default filter to "nearest-neighbor", which essentially
		means there will be no filtering of pixels (blurriness), which is
		important for the retro look.
	]]
	love.graphics.setDefaultFilter('nearest', 'nearest')

	--	Sets the title of our application window.
	love.window.setTitle('Pong')

	--	Initializes our application window with the virtual resolution set as constants earlier.
	push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
		fullscreen = false,
		vsync = true,
		resizable = true
	})

	--	Initializes our nice-looking retro text fonts from the font.ttf file including in the folder.
	smallFont = love.graphics.newFont('font.ttf', 8)
	largeFont = love.graphics.newFont('font.ttf', 16)
	scoreFont = love.graphics.newFont('font.ttf', 32)
	love.graphics.setFont(smallFont)

	--[[
		Sets up our sound effects from .wav files in the folder; later, we can just index this 
		table and call each entry's `play` method.
	]]
	sounds = {
		['paddle_hit'] = love.audio.newSource('Sounds/paddle_hit.wav', 'static'),
		['wall_hit'] = love.audio.newSource('Sounds/wall_hit.wav', 'static'),
		['score'] = love.audio.newSource('Sounds/score.wav', 'static'),
		['winner'] = love.audio.newSource('Sounds/winner.wav', 'static')
	}

	--[[
		Initializes the player paddles using the Paddle class we setup in 'Paddle.lua' which 
		we called (required) at the top of 'main.lua'.
	]]
	player1 = Paddle(5, VIRTUAL_HEIGHT / 2 - 10, 5, 20)
	player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT / 2 - 10, 5, 20)
	
	--[[
		Initializes the ball using the Ball class we setup in 'Ball.lua' which 
		we called (required) at the top of 'main.lua'.
	]]
	ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

	numberPlayers = 1
	selectSide = 'Left'

	--[[
		Initializes the variable that determines who's turn it is to serve. This will either be 1 or 2; 
		whomever is scored on gets to serve the following turn. It is set to 0 when the game first loads.
	]]
	servingPlayer = math.random(2)

	startTime = 0
	endTime = 0

	--	Initializes the score variables, used for rendering on the screen and keeping track of the winner.
	player1Score = 0
	player2Score = 0
	
	--[[
		Initializes the variable that keeps track of who won the game. This will either be 1 or 2; 
		whomever is the first to score 10 points.
	]]
	winningPlayer = 0

	--	Initializes the variable that keeps track of state the game is in.
	gameState = 'start'

	--	Initializes the variable that the FPS will be assigned to.
	fpsCount = 0
	
	--	Initializes the variable that is used to determine whether to show the FPS
	showFPS = false

end

--[[
	Called by LÖVE whenever we resize the screen; here, we just want to pass in the
	width and height to push so our virtual resolution can be resized as needed.
]]
function love.resize(w, h)
	
	push:resize(w, h)

end

--[[
	Runs every frame, with "dt" passed in, our delta time in seconds 
	since the last frame, which LÖVE2D supplies us.
]]
function love.update(dt)

	if gameState == 'serve' or gameState == 'first_serve' then
						
		if servingPlayer == 1 then
			ball.dx = math.random(100, 175)
		else
			ball.dx = math.random(-100, -175)
		end

		--	Before switching to play, initialize ball's y velocity
		ball.dy = math.random(-100, 100)

		player1:reset()
		player2:reset()

		if numberPlayers == 1 then
			if gameState == 'serve' then
				if selectSide == 'Left' then
					if servingPlayer == 2 then
						endTime = love.timer.getTime() - startTime
						if endTime > 5 then
							gameState = 'play'
							startTime = 0
							endTime = 0
						end
					end
				else
					if servingPlayer == 1 then
						endTime = love.timer.getTime() - startTime
						if endTime > 5 then
							gameState = 'play'
							startTime = 0
							endTime = 0
						end
					end
				end
			end
		end

	elseif gameState == 'play' then
		
		if numberPlayers == 1 then

			if selectSide == 'Left' then 

				if love.keyboard.isDown('w') then
					if love.keyboard.isDown('lshift') then
						player1.dy = -SLOW_PADDLE_SPEED
					else
						player1.dy = -FAST_PADDLE_SPEED
					end
				elseif love.keyboard.isDown('s') then
					if love.keyboard.isDown('lshift') then
						player1.dy = SLOW_PADDLE_SPEED
					else
						player1.dy = FAST_PADDLE_SPEED
					end
				else
					player1.dy = 0
				end

				if player2:ai(ball) == 'move_up' then
					player2.dy = math.max(ball.dy, -FAST_PADDLE_SPEED)
				elseif player2:ai(ball) == 'move_down' then
					player2.dy = math.min(ball.dy, FAST_PADDLE_SPEED)
				else
					player2.dy = 0
				end

			elseif selectSide == 'Right' then

				if player1:ai(ball) == 'move_up' then
					player1.dy = math.max(ball.dy, -FAST_PADDLE_SPEED)
				elseif player1:ai(ball) == 'move_down' then
					player1.dy = math.min(ball.dy, FAST_PADDLE_SPEED)
				else
					player1.dy = 0
				end

				if love.keyboard.isDown('up') then
					if love.keyboard.isDown('rshift') then
						player2.dy = -SLOW_PADDLE_SPEED
					else
						player2.dy = -FAST_PADDLE_SPEED
					end
				elseif love.keyboard.isDown('down') then
					if love.keyboard.isDown('rshift') then
						player2.dy = SLOW_PADDLE_SPEED
					else
						player2.dy = FAST_PADDLE_SPEED
					end
				else
					player2.dy = 0
				end

			end

		elseif numberPlayers == 2 then
		
			--	Movement of player 1's paddle when key is pressed.
			if love.keyboard.isDown('w') then
				if love.keyboard.isDown('lshift') then
					player1.dy = -SLOW_PADDLE_SPEED
				else
					player1.dy = -FAST_PADDLE_SPEED
				end
			elseif love.keyboard.isDown('s') then
				if love.keyboard.isDown('lshift') then
					player1.dy = SLOW_PADDLE_SPEED
				else
					player1.dy = FAST_PADDLE_SPEED
				end
			else
				player1.dy = 0
			end

			--	Movement of player 2's paddle when key is pressed.
			if love.keyboard.isDown('up') then
				if love.keyboard.isDown('rshift') then
					player2.dy = -SLOW_PADDLE_SPEED
				else
					player2.dy = -FAST_PADDLE_SPEED
				end
			elseif love.keyboard.isDown('down') then
				if love.keyboard.isDown('rshift') then
					player2.dy = SLOW_PADDLE_SPEED
				else
					player2.dy = FAST_PADDLE_SPEED
				end
			else
				player2.dy = 0
			end
		
		end

		--[[
			Detect ball collision with paddles, reversing the x direction of the ball if true and 
			slightly increasing it, then altering the y direction based on the position of collision.
		]]
		if ball:collides(player1) then

			sounds['paddle_hit']:play()
			ball.dx = -ball.dx * 1.05
			ball.x = player1.x + player1.width

			--	Keep velocity going in the same x direction, but randomize the y direction.
			if ball.dy < 0 then
				ball.dy = math.random(-10, -150)
			else
				ball.dy = math.random(10, 150)
			end

		end
	
		--[[
			Detect ball collision with paddles, reversing the x direction of the ball if true and 
			slightly increasing it, then altering the y direction based on the position of collision.
		]]
		if ball:collides(player2) then

			sounds['paddle_hit']:play()
			ball.dx = -ball.dx * 1.05
			ball.x = player2.x - ball.width

			--	Keep velocity going in the same x direction, but randomize the y direction.
			if ball.dy < 0 then
				ball.dy = math.random(-10, -150)
			else
				ball.dy = math.random(10, 150)
			end

		end

		--[[
			If we reach the left edge of the screen, 
			reset the ball and update the scores.
		]]
		if ball.x + ball.width < 0 then

			player2Score = player2Score + 1
			servingPlayer = 1
			sounds['score']:play()

			--[[
				If we've reached a score of 10, the game is over; set the 
				state to finish so we can show who the winner is.
			]]
			if player2Score == 10 then
				gameState = 'finish'
				sounds['winner']:play()
				winningPlayer = 2
			else
				gameState = 'serve'
				ball:reset(player1)
				if numberPlayers == 1 then
					if selectSide == 'Right' then
						startTime = love.timer.getTime()
					end
				end
			end

		end

		--[[
			If we reach the right edge of the screen, 
			reset the ball and update the scores.
		]]
		if ball.x > VIRTUAL_WIDTH then

			player1Score = player1Score + 1
			servingPlayer = 2
			sounds['score']:play()

			--[[
				If we've reached a score of 10, the game is over; set the 
				state to finish so we can show who the winner is.
			]]
			if player1Score == 10 then
				gameState = 'finish'
				sounds['winner']:play()
				winningPlayer = 1
			else
				gameState = 'serve'
				ball:reset(player2)
				if numberPlayers == 1 then
					if selectSide == 'Left' then
						startTime = love.timer.getTime()
					end
				end
			end

		end
	
		--[[
			Detect the upper screen boundary collision and reverse the y direction of 
			the ball if collided.
		]]
		if ball.y <= 0 then
			ball.y = 0
			ball.dy = -ball.dy
			sounds['wall_hit']:play()
		end
	
		--[[
			Detect the lower screen boundary collision and reverse the y direction of 
			the ball if collided.
		]]
		if ball.y >= VIRTUAL_HEIGHT - 4 then
			ball.y = VIRTUAL_HEIGHT - 4
			ball.dy = -ball.dy
			sounds['wall_hit']:play()
		end

		--[[
			Updates the position of the paddles for each player, scaled by delta time so 
			movement is framerate-independent, by calling the update function in 'Paddle.lua'.
		]]
		player1:update(dt)
		player2:update(dt)
	
		--[[
			Updates our ball based on its x velocity and y velocity, only if we're in play state; 
			scale the velocity by delta time so movement is framerate-independent.
		]]
		ball:update(dt)

	end

end

--[[
	Keyboard handling, called by LÖVE2D each frame; 
	passes in the key we pressed and triggers the neccessary code
]]
function love.keypressed(key)

	if gameState == 'start' then

		if key == '1' then

			if numberPlayers == 1 then
				numberPlayers = numberPlayers + 1
				selectSide = 'Both'
			else
				numberPlayers = numberPlayers - 1
				selectSide = 'Left'
			end

		end

		if key == '2' then

			if numberPlayers == 1 then
				if selectSide == 'Left' then
					selectSide = 'Right'
				else
					selectSide = 'Left'
				end
			end

		end

		if key == 'space' then

			gameState = 'first_serve'

		end

		if key == 'escape' then

			love.event.quit()

		end
	
	elseif gameState == 'first_serve' then

		if key == 'space' then

			gameState = 'play'

		end
		
		if key == 'escape' then

			gameState = 'start'
			ball:restart()
			player1Score = 0
			player2Score = 0
			servingPlayer = math.random(2)

		end

	elseif gameState == 'serve' then

		if servingPlayer == 1 then

			if key == 'tab' then
				gameState = 'play'
			end

		elseif servingPlayer == 2 then

			if key == 'enter' or key == 'return' then
				gameState = 'play'
			end

		end

		if key == 'escape' then

			gameState = 'start'
			ball:restart()
			player1Score = 0
			player2Score = 0
			servingPlayer = math.random(2)

		end

	elseif gameState == 'play' then

		if key == 'escape' then

			gameState = 'start'
			ball:restart()
			player1Score = 0
			player2Score = 0
			servingPlayer = math.random(2)

		end

	elseif gameState == 'finish' then

		if key == 'space' then

			--	Game is in a restart phase here and resets everything.
			gameState = 'start'
			ball:restart()
			player1Score = 0
			player2Score = 0
			servingPlayer = math.random(2)

		end

		if key == 'escape' then

			gameState = 'start'
			ball:restart()
			player1Score = 0
			player2Score = 0
			servingPlayer = math.random(2)

		end

	end

	--	If we press the letter f then it changes the 'showFPS' variable between false and true.
	if key == 'f' then

		if showFPS == false then
			--	Assigns the 'showFPS' variable with true.
			showFPS = true
		elseif showFPS == true then
			--	Assigns the 'showFPS' variable with false.
			showFPS = false
		end

	end

end

--[[
	Called after update by LÖVE2D, used to draw anything to the screen, 
	updated or otherwise.
]]
function love.draw()

	--	Applies the virtual resolution and renders it.
	push:apply('start')

	--[[
		Clears the screen with a specific color using RGBA; in this case, a color similar 
		to some versions of the original Pong. (0 = Black and 1 = White)
	]]
	love.graphics.clear(40 / 255, 45 / 255, 52 / 255, 255 / 255)

	--	If the 'showFPS' variable value is equal to 'true' then the FPS counter will be displayed.
	if showFPS == true then
		--	Calls the 'displayFPS' function.
		displayFPS()
	else
		--	Assigns the value 0 (frames per second) to the 'FPS' variable.
		fpsCount = 0
	end
	
	if gameState == 'start' then

		love.graphics.setFont(largeFont)
		love.graphics.printf("Welcome To Pong!", 0, VIRTUAL_HEIGHT / 2 - 50, 
			VIRTUAL_WIDTH, 'center')
		love.graphics.printf("Press The 'Space' Key To Confirm The Settings", 0, VIRTUAL_HEIGHT / 2 - 20, 
			VIRTUAL_WIDTH, 'center')
		love.graphics.setFont(smallFont)
		love.graphics.printf("Number Of Players: " .. tostring(numberPlayers) .. 
			"	(Press The '1' Key To Change)", 0, VIRTUAL_HEIGHT / 2 + 10, VIRTUAL_WIDTH, 'center')
		love.graphics.printf("Control Of Paddle: " .. tostring(selectSide) .. 
			"	(Press The '2' Key To Change)", 0, VIRTUAL_HEIGHT / 2 + 20, VIRTUAL_WIDTH, 'center')

	elseif gameState == 'first_serve' then

		love.graphics.setFont(largeFont)
		love.graphics.printf("Press The 'Space' Key To Start The Game", 0, 10, VIRTUAL_WIDTH, 'center')

	elseif gameState == 'play' then

		--	No UI message will appear.

	elseif gameState == 'serve' then

		love.graphics.setFont(smallFont)
		
		if numberPlayers == 1 then

			if selectSide == 'Left' then
				if servingPlayer == 1 then
					love.graphics.printf("It Is Your Serve!", 0, 10, VIRTUAL_WIDTH, 'center')
					love.graphics.printf("Press The 'Tab' Key To Serve", 0, 20, VIRTUAL_WIDTH, 'center')
				else
					love.graphics.printf("It Is The Computer's Serve", 0, 10, VIRTUAL_WIDTH, 'center')
					love.graphics.printf("The Computer Will Serve Automatically", 
						0, 20, VIRTUAL_WIDTH, 'center')
				end
			else
				if servingPlayer == 1 then
					love.graphics.printf("It Is The Computer's Serve", 0, 10, VIRTUAL_WIDTH, 'center')
					love.graphics.printf("The Computer Will Serve Automatically", 
						0, 20, VIRTUAL_WIDTH, 'center')
				else
					love.graphics.printf("It Is Your Serve!", 0, 10, VIRTUAL_WIDTH, 'center')
					love.graphics.printf("Press The 'Enter' Key To Serve", 0, 20, VIRTUAL_WIDTH, 'center')
				end
			end

		else

			if servingPlayer == 1 then
				love.graphics.printf("Player " .. tostring(servingPlayer) .. "'s Serve!", 
					0, 10, VIRTUAL_WIDTH, 'center')
				love.graphics.printf("Press The 'Tab' Key To Serve", 0, 20, VIRTUAL_WIDTH, 'center')
			else
				love.graphics.printf("Player " .. tostring(servingPlayer) .. "'s Serve!", 
					0, 10, VIRTUAL_WIDTH, 'center')
				love.graphics.printf("Press The 'Enter' Key To Serve", 0, 20, VIRTUAL_WIDTH, 'center')
			end

		end
	
	elseif gameState == 'finish' then

		--	UI message appears saying who has won the game and how to start a new game.
		if numberPlayers == 1 then

			if winningPlayer == 1 then

				if selectSide == 'Left' then

					love.graphics.setFont(largeFont)
					love.graphics.printf("You Won The Game!", 0, 10, VIRTUAL_WIDTH, 'center')
					love.graphics.setFont(smallFont)
					love.graphics.printf("Press The 'Space' Key To Return To The Main Menu", 0, 30, 
						VIRTUAL_WIDTH, 'center')

				else

					love.graphics.setFont(largeFont)
					love.graphics.printf("The Computer Won The Game!", 0, 10, VIRTUAL_WIDTH, 'center')
					love.graphics.setFont(smallFont)
					love.graphics.printf("Press The 'Space' Key To Return To The Main Menu", 0, 30, 
						VIRTUAL_WIDTH, 'center')

				end

			elseif winningPlayer == 2 then

				if selectSide == 'Left' then

					love.graphics.setFont(largeFont)
					love.graphics.printf("The Computer Won The Game!", 0, 10, VIRTUAL_WIDTH, 'center')
					love.graphics.setFont(smallFont)
					love.graphics.printf("Press The 'Space' Key To Return To The Main Menu", 0, 30, 
						VIRTUAL_WIDTH, 'center')

				else

					love.graphics.setFont(largeFont)
					love.graphics.printf("You Won The Game!", 
						0, 10, VIRTUAL_WIDTH, 'center')
					love.graphics.setFont(smallFont)
					love.graphics.printf("Press The 'Space' Key To Return To The Main Menu", 0, 30, 
						VIRTUAL_WIDTH, 'center')

				end

			end

		else

			love.graphics.setFont(largeFont)
			love.graphics.printf("Player " .. tostring(winningPlayer) .. " Wins!", 
				0, 10, VIRTUAL_WIDTH, 'center')
			love.graphics.setFont(smallFont)
			love.graphics.printf("Press The 'Space' Key To Return To The Main Menu", 
				0, 30, VIRTUAL_WIDTH, 'center')

		end

	end

	if gameState ~= 'finish' and gameState ~= 'start' then
		--	Renders the paddles for each player by calling the render function in 'Paddle.lua'.
		player1:render()
		player2:render()
	
		--	Renders the ball by calling the render function in 'Ball.lua'.
		ball:render()

		if gameState == 'serve' then

			if servingPlayer == 1 then
				player1:highlight()
			else
				player2:highlight()
			end

		end

	end

	--	If the 'gameState' variable value is not equal to 'play' then the scores are displayed.
	if gameState == 'serve' or gameState == 'finish' then
		--	Calls the 'displayScore' function.
		displayScore()
	end

	--	Stops the virtual resolution from being applied to the application window.
	push:apply('end')

end

--	Renders the current FPS.
function displayFPS()
	
	--	Assigns the current FPS (frames per second) to the 'FPS' variable.
	fpsCount = love.timer.getFPS()
	love.graphics.setFont(smallFont)
	
	--[[
		Displays the FPS in certain colours; 20 or less then it displays the FPS in red, above 20 
		and 40 or less then it is displayed in yellow, anything above 40 is displayed in green.
	]]
	if fpsCount < 20 then
		love.graphics.setColor(1, 0, 0, 1)
		love.graphics.print("FPS: " .. tostring(fpsCount), 10, 10)
	elseif fpsCount >= 20 and fpsCount < 40 then
		love.graphics.setColor(1, 1, 0, 1)
		love.graphics.print("FPS: " .. tostring(fpsCount), 10, 10)
	else
		love.graphics.setColor(0, 1, 0, 1)
		love.graphics.print("FPS: " .. tostring(fpsCount), 10, 10)
	end
	
	--	Sets the colour used to render back to white.
	love.graphics.setColor(1, 1, 1, 1)

end

--	Simply draws the score to the screen using variables we have set.
function displayScore()
		
	--	Need to switch font to draw before actually printing.
	love.graphics.setFont(scoreFont)
	
	--	Draw the score to the left and right of the center of the screen.
	love.graphics.printf(player1Score, VIRTUAL_WIDTH / 4, VIRTUAL_HEIGHT / 2 - 16, 
		VIRTUAL_WIDTH / 4, 'center')
	love.graphics.printf(":", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
	love.graphics.printf(player2Score, VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2 - 16, 
		VIRTUAL_WIDTH / 4, 'center')

end