
return function()
	--[[
		Math library, with slight modifications 
		by William Horn
	]]

	local pow = math.pow
	local sin = math.sin
	local cos = math.cos
	local pi = math.pi
	local sqrt = math.sqrt
	local abs = math.abs
	local asin  = math.asin

	-- Modifications start

	local Math = {}
	Math.tweens = {}

	Math.tau = math.pi*2
	Math.zeroVec3 = Vector3.new(0, 0, 0)
	Math.zeroCFrame = CFrame.new(0, 0, 0)

	function Math.newseed()
		math.randomseed(tick())
	end

	function Math.roundToNth(n, nth)
		local factor = pow(10, nth)
		return math.floor(n*factor + 0.5)/factor
	end

	function Math.roundToInt(n)
		return math.floor(n + 0.5)
	end

	function Math.roundTens(n)
		return math.floor(n*10 + 0.5)/10
	end

	function Math.roundHunds(n)
		return math.floor(n*100 + 0.5)/100
	end

	function Math.roundThous(n)
		return math.floor(n*1000 + 0.5)/1000
	end

	function Math.lerp(a, b, p)
		return a + (b - a)*p
	end

	-- Szudzik's pairing function
	function Math.uniquePair(a, b)
		return a > b and a*a + a + b or b*b + a
	end

	--[[
		@desc: Returns a value's percentage from min to max
		Example: getPercentFrom(1, 10, 7) -> 0.7
	]]
	function Math.getPercentFrom(min, max, value)
		return (value - min)/(max - min)
	end

	--- Modifications end

	local function linear(t, b, c, d)
		return c*t/d + b
	end

	local function inQuad(t, b, c, d)
		t = t/d
		return c*pow(t, 2) + b
	end

	local function outQuad(t, b, c, d)
		t = t/d
		return -c*t*(t - 2) + b
	end

	local function inOutQuad(t, b, c, d)
		t = t/d*2
		if t < 1 then
			return c/2*pow(t, 2) + b
		else
			return -c/2*((t - 1)*(t - 3) - 1) + b
		end
	end

	local function outInQuad(t, b, c, d)
		if t < d/2 then
			return outQuad (t*2, b, c/2, d)
		else
			return inQuad((t*2) - d, b + c/2, c/2, d)
		end
	end

	local function inCubic (t, b, c, d)
		t = t/d
		return c*pow(t, 3) + b
	end

	local function outCubic(t, b, c, d)
		t = t/d - 1
		return c*(pow(t, 3) + 1) + b
	end

	local function inOutCubic(t, b, c, d)
		t = t/d*2
		if t < 1 then
			return c/2*t*t*t + b
		else
			t = t - 2
			return c/2*(t*t*t + 2) + b
		end
	end

	local function outInCubic(t, b, c, d)
		if t < d/2 then
			return outCubic(t*2, b, c/2, d)
		else
			return inCubic((t*2) - d, b + c/2, c/2, d)
		end
	end

	local function inQuart(t, b, c, d)
		t = t/d
		return c*pow(t, 4) + b
	end

	local function outQuart(t, b, c, d)
		t = t/d - 1
		return -c*(pow(t, 4) - 1) + b
	end

	local function inOutQuart(t, b, c, d)
		t = t/d*2
		if t < 1 then
			return c/2*pow(t, 4) + b
		else
			t = t - 2
			return -c/2*(pow(t, 4) - 2) + b
		end
	end

	local function outInQuart(t, b, c, d)
		if t < d/2 then
			return outQuart(t*2, b, c/2, d)
		else
			return inQuart((t*2) - d, b + c/2, c/2, d)
		end
	end

	local function inQuint(t, b, c, d)
		t = t/d
		return c*pow(t, 5) + b
	end

	local function outQuint(t, b, c, d)
		t = t/d - 1
		return c*(pow(t, 5) + 1) + b
	end

	local function inOutQuint(t, b, c, d)
		t = t/d*2
		if t < 1 then
			return c/2*pow(t, 5) + b
		else
			t = t - 2
			return c/2*(pow(t, 5) + 2) + b
		end
	end

	local function outInQuint(t, b, c, d)
		if t < d/2 then
			return outQuint(t*2, b, c/2, d)
		else
			return inQuint((t*2) - d, b + c/2, c/2, d)
		end
	end

	local function inSine(t, b, c, d)
		return -c*cos(t/d*(pi/2)) + c + b
	end

	local function outSine(t, b, c, d)
		return c*sin(t/d*(pi/2)) + b
	end

	local function inOutSine(t, b, c, d)
		return -c/2*(cos(pi*t/d) - 1) + b
	end

	local function outInSine(t, b, c, d)
		if t < d/2 then
			return outSine(t*2, b, c/2, d)
		else
			return inSine((t*2) -d, b + c/2, c/2, d)
		end
	end

	local function inExpo(t, b, c, d)
		if t == 0 then
			return b
		else
			return c*pow(2, 10*(t/d - 1)) + b - c*0.001
		end
	end

	local function outExpo(t, b, c, d)
		if t == d then
			return b + c
		else
			return c*1.001*(-pow(2, -10*t/d) + 1) + b
		end
	end

	local function inOutExpo(t, b, c, d)
		if t == 0 then return b end
		if t == d then return b + c end
		t = t/d*2
		if t < 1 then
			return c/2*pow(2, 10*(t - 1)) + b - c*0.0005
		else
			t = t - 1
			return c/2*1.0005*(-pow(2, -10*t) + 2) + b
		end
	end

	local function outInExpo(t, b, c, d)
		if t < d/2 then
			return outExpo(t*2, b, c/2, d)
		else
			return inExpo((t*2) - d, b + c/2, c/2, d)
		end
	end

	local function inCirc(t, b, c, d)
		t = t/d
		return(-c*(sqrt(1 - pow(t, 2)) - 1) + b)
	end

	local function outCirc(t, b, c, d)
		t = t/d - 1
		return(c*sqrt(1 - pow(t, 2)) + b)
	end

	local function inOutCirc(t, b, c, d)
		t = t/d*2
		if t < 1 then
			return -c/2*(sqrt(1 - t*t) - 1) + b
		else
			t = t - 2
			return c/2*(sqrt(1 - t*t) + 1) + b
		end
	end

	local function outInCirc(t, b, c, d)
		if t < d/2 then
			return outCirc(t*2, b, c/2, d)
		else
			return inCirc((t*2) - d, b + c/2, c/2, d)
		end
	end

	local function inElastic(t, b, c, d, a, p)
		if t == 0 then return b end

		t = t/d

		if t == 1  then return b + c end
		if not p then p = d*0.3 end
		
		local s

		if not a or a < abs(c) then
			a = c
			s = p/4
		else
			s = p/(2*pi)*asin(c/a)
		end

		t = t - 1
		return -(a*pow(2, 10*t)*sin((t*d - s)*(2*pi)/p)) + b
	end

	local function outElastic(t, b, c, d, a, p)
		if t == 0 then return b end

		t = t/d

		if t == 1 then return b + c end
		if not p then p = d*0.3 end
		local s

		if not a or a < abs(c) then
			a = c
			s = p/4
		else
			s = p/(2*pi)*asin(c/a)
		end

		return a*pow(2, -10*t)*sin((t*d - s)*(2*pi)/p) + c + b
	end

	local function inOutElastic(t, b, c, d, a, p)
		if t == 0 then return b end

		t = t/d*2

		if t == 2 then return b + c end

		if not p then p = d*(0.3*1.5) end
		if not a then a = 0 end
		local s

		if not a or a < abs(c) then
			a = c
			s = p/4
		else
			s = p/(2*pi)*asin(c/a)
		end

		if t < 1 then
			t = t - 1
			return -0.5*(a*pow(2, 10*t)*sin((t*d - s)*(2*pi)/p)) + b
		else
			t = t - 1
			return a*pow(2, -10*t)*sin((t*d - s)*(2*pi)/p )*0.5 + c + b
		end
	end

	local function outInElastic(t, b, c, d, a, p)
		if t < d/2 then
			return outElastic(t*2, b, c/2, d, a, p)
		else
			return inElastic((t*2) - d, b + c/2, c/2, d, a, p)
		end
	end

	local function inBack(t, b, c, d, s)
		if not s then s = 1.70158 end
		t = t/d
		return c*t*t*((s + 1)*t - s) + b
	end

	local function outBack(t, b, c, d, s)
		if not s then s = 1.70158 end
		t = t/d - 1
		return c*(t*t*((s + 1)*t + s) + 1) + b
	end

	local function inOutBack(t, b, c, d, s)
		if not s then s = 1.70158 end
		s = s*1.525
		t = t/d*2
		if t < 1 then
			return c/2*(t*t*((s + 1)*t - s)) + b
		else
			t = t - 2
			return c/2*(t*t*((s + 1)*t + s) + 2) + b
		end
	end

	local function outInBack(t, b, c, d, s)
		if t < d/2 then
			return outBack(t*2, b, c/2, d, s)
		else
			return inBack((t*2) - d, b + c/2, c/2, d, s)
		end
	end

	local function outBounce(t, b, c, d)
		t = t/d
		if t < 1/2.75 then
			return c*(7.5625*t*t) + b
		elseif t < 2/2.75 then
			t = t - (1.5/2.75)
			return c*(7.5625*t*t + 0.75) + b
		elseif t < 2.5/2.75 then
			t = t - (2.25/2.75)
			return c*(7.5625*t*t + 0.9375) + b
		else
			t = t - (2.625/2.75)
			return c*(7.5625*t*t + 0.984375) + b
		end
	end

	local function inBounce(t, b, c, d)
		return c - outBounce(d - t, 0, c, d) + b
	end

	local function inOutBounce(t, b, c, d)
		if t < d/2 then
			return inBounce(t*2, 0, c, d)*0.5 + b
		else
			return outBounce(t*2 - d, 0, c, d)*0.5 + c*.5 + b
		end
	end

	local function outInBounce(t, b, c, d)
		if t < d/2 then
			return outBounce(t*2, b, c/2, d)
		else
			return inBounce((t*2) - d, b + c/2, c/2, d)
		end
	end

	Math.tweens.linear = linear
	Math.tweens.inQuad = inQuad
	Math.tweens.outQuad = outQuad
	Math.tweens.inOutQuad = inOutQuad
	Math.tweens.outInQuad = outInQuad
	Math.tweens.inCubic = inCubic
	Math.tweens.outCubic = outCubic
	Math.tweens.inOutCubic = inOutCubic
	Math.tweens.outInCubic = outInCubic
	Math.tweens.inQuart = inQuart
	Math.tweens.outQuart = outQuart
	Math.tweens.inOutQuart = inOutQuart
	Math.tweens.outInQuart = outInQuart
	Math.tweens.inQuint = inQuint
	Math.tweens.outQuint = outQuint
	Math.tweens.inOutQuint = inOutQuint
	Math.tweens.outInQuint = outInQuint
	Math.tweens.inSine = inSine
	Math.tweens.outSine = outSine
	Math.tweens.inOutSine = inOutSine
	Math.tweens.outInSine = outInSine
	Math.tweens.inExpo = inExpo
	Math.tweens.outExpo = outExpo
	Math.tweens.inOutExpo = inOutExpo
	Math.tweens.outInExpo = outInExpo
	Math.tweens.inCirc = inCirc
	Math.tweens.outCirc = outCirc
	Math.tweens.inOutCirc = inOutCirc
	Math.tweens.outInCirc = outInCirc
	Math.tweens.inElastic = inElastic
	Math.tweens.outElastic = outElastic
	Math.tweens.inOutElastic = inOutElastic
	Math.tweens.outInElastic = outInElastic
	Math.tweens.inBack = inBack
	Math.tweens.outBack = outBack
	Math.tweens.inOutBack = inOutBack
	Math.tweens.outInBack = outInBack
	Math.tweens.inBounce = inBounce
	Math.tweens.outBounce = outBounce
	Math.tweens.inOutBounce = inOutBounce
	Math.tweens.outInBounce = outInBounce

	return {
		default = Math,
	}
end
