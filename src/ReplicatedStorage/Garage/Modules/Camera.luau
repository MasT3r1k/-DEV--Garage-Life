local Camera = {}

--camera module sets the CameraSubject based on the data

function Camera.CameraSubject(player, Subject)
	local Cam = workspace.CurrentCamera
	Cam.CameraSubject = Subject
end

return Camera
