local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local hubName = "Eclipse"
local hubVersion = "0.0.1"
local myName = "sqwz"
local robloxUsername = "sqwaze_y"
local telegramUsername = "sqwzsqwz"

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
	Title = hubName .. " Hub",
	Author = "by " .. myName,
	Icon = "craft:github-stroke", --github
	ToggleKey = Enum.KeyCode.RightShift
})

