local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local Junkie = loadstring(game:HttpGet("https://jnkie.com/sdk/library.lua"))()


local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local hubName = "Nova"
local hubVersion = "0.0.1"
local myName = "sqwz"
local robloxUsername = "sqwaze_y"
local telegramUsername = "sqwzsqwz"




-- */  Colors  /* --
local Purple = Color3.fromHex("#7775F2")
local Yellow = Color3.fromHex("#ECA201")
local Green = Color3.fromHex("#10C550")
local Grey = Color3.fromHex("#83889E")
local Blue = Color3.fromHex("#257AF7")
local Red = Color3.fromHex("#EF4F1D")
local Grey1 = Color3.fromHex("#3A3D45")
local Grey2 = Color3.fromHex("#2E3138")
local Grey3 = Color3.fromHex("#22242A")
local Grey4 = Color3.fromHex("#17181C")

Junkie.service = "Nova Hub"
Junkie.identifier = "1159416"
Junkie.provider = "test"

WindUI.Services.junkiedevelopment = {
	Name = "Junkie Development", 
	Icon = "shield-check",
	Args = { "ServiceId", "ApiKey", "Provider" },

	New = function()
		local function Verify(key)
			local result = Junkie.check_key(key)
			if result and result.valid then
				if result.message == "KEYLESS" then
					getgenv().SCRIPT_KEY = "KEYLESS"
					return true, "Keyless mode"
				elseif result.message == "KEY_VALID" then
					getgenv().SCRIPT_KEY = key
					return true, "Key valid"
				else
					return false, "Invalid key"
				end
			end
		end

		local function Copy()
			local link = Junkie.get_key_link()
			if setclipboard then setclipboard(link) end
			return link
		end

		return { Verify = Verify, Copy = Copy }
	end
}

WindUI:AddTheme({
	Name = "Midnight",

	Accent = Color3.fromHex("#1e3a8a"),
	Dialog = Color3.fromHex("#0c1e42"),
	--Outline = Color3.fromHex("#bfdbfe"),
	Text = Color3.fromHex("#dbeafe"),
	Placeholder = Color3.fromHex("#2f74d1"),
	Background = Color3.fromHex("#0a0f1e"),
	Button = Color3.fromHex("#2563eb"),
	Primary = Color3.fromHex("#2563eb"),
	Icon = Color3.fromHex("#5591f4"),

	ElementBackground = Color3.fromHex("#242836"),
	ElementBackgroundTransparency = 0,
})

WindUI:SetTheme("Midnight")

local Window = WindUI:CreateWindow({
	Title = "Nova Hub", -- CHANGE TITLE HERE!
	Theme = "Dark",
	Transparent = true,
	Resizable = true,

	KeySystem = {
		Note = "Enter your key to continue.",
		SaveKey = true,
		API = {
			{
				Title = "Junkie",
				Desc  = "Click to copy link",
				Icon  = "key-round",
				Type  = "junkiedevelopment"
			}
		}
	}
})

while not getgenv().SCRIPT_KEY do
	task.wait(0.1)
end

local MainTab = Window:Tab({
	Title = "Main",
	Icon = "house",
})

local aboutHubParagraph  = MainTab:Paragraph({
	Title = "About " .. hubName .. " Hub",
	Desc = hubName .. " Hub is a universal script hub featuring basic utilities and support for multiple games. " .. hubName .. " Hub has only recently been released, and new features and game support will be added soon.",
	Locked = false,
	Buttons = {
		{
			Title = "Copy Owner nickname!",
			Desc = "@"..robloxUsername,
			Callback = function()
				if setclipboard then
					setclipboard(robloxUsername)
					WindUI:Notify({
						Title = "Copied",
						Content = "Roblox username copied to clipboard!",
						Duration = 3
					})
				end
			end
		}
	}
})


Window:OnOpen(function()
	WindUI:Notify({
		Title = "Script executed!",
		Desc = hubName .. " Hub will launch in 3 seconds!",
		Duration = 3
	})

	task.wait(3)
	loadstring(game:HttpGet("https://api.jnkie.com/api/v1/luascripts/public/ace64acd16fafbec871be9edb90db6da78e09d5779414eb2a921eb91711cbdfc/download"))()
	Window:Close()
	Window:Destroy()
end)
