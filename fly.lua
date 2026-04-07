loadstring([[
local dx = math.clamp(flyTouchDelta.X / FLY_TOUCH_MAX_DRAG, -1, 1)
local dy = math.clamp(flyTouchDelta.Y / FLY_TOUCH_MAX_DRAG, -1, 1)
local flatR = Vector3.new(rVec.X, 0, rVec.Z)
flatR = flatR.Magnitude > 0.01 and flatR.Unit or Vector3.new(0, 0, 0)
dir = flatR * dx + camCF.LookVector * (-dy)
bv.Velocity = bv.Velocity:Lerp(dir.Unit * SETTINGS.FlySpeed, 0.25)
]])()
