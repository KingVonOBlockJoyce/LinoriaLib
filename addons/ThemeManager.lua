local httpService = game:GetService('HttpService')
local ThemeManager = {} do
	ThemeManager.Folder = 'LinoriaLibSettings'
	-- if not isfolder(ThemeManager.Folder) then makefolder(ThemeManager.Folder) end

	ThemeManager.Library = nil
	ThemeManager.BuiltInThemes = {
        ['Default'] = { 1, httpService:JSONDecode('{"MainColor":"181818","AccentColor":"6c2020","OutlineColor":"1c1c1c","BackgroundColor":"141414","FontColor":"ffffff"}') },
        ['Rainbow'] = { 2, httpService:JSONDecode('{"MainColor":"181818","AccentColor":"6c2020","OutlineColor":"1c1c1c","BackgroundColor":"141414","FontColor":"ffffff"}') },
        ['Venom'] = { 3, httpService:JSONDecode('{"FontColor":"BFBFBF","MainColor":"0E0E0E","AccentColor":"ff0000","BackgroundColor":"0E0E0E","OutlineColor":"212121"}') },
        ['Cyan'] = { 4, httpService:JSONDecode('{"FontColor":"BFBFBF","MainColor":"0F0F0F","AccentColor":"00ffef","BackgroundColor":"101010","OutlineColor":"0B0B0B"}') },
        ['Fatality'] = { 5, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"1e1842","AccentColor":"c50754","BackgroundColor":"191335","OutlineColor":"28204F"}') },
        ['GameSense'] = { 6, httpService:JSONDecode('{"FontColor":"FFFFFF","MainColor":"171717","AccentColor":"98E22E","BackgroundColor":"171717","OutlineColor":"282828"}') },
        ['Comet'] = { 7, httpService:JSONDecode('{"FontColor":"5E5E5E","MainColor":"0F0F0F","AccentColor":"5D589D","BackgroundColor":"0F0F0F","OutlineColor":"e0e0e0"}') },
        ['BBot'] = { 8, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"1e1e1e","AccentColor":"7e48a3","BackgroundColor":"232323","OutlineColor":"141414"}') },
        ['Jester'] = { 9, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"242424","AccentColor":"db4467","BackgroundColor":"1c1c1c","OutlineColor":"373737"}') },
        ['Mint'] = { 10, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"242424","AccentColor":"3db488","BackgroundColor":"1c1c1c","OutlineColor":"373737"}') },
        ['Tokyo Night'] = { 11, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"191925","AccentColor":"6759b3","BackgroundColor":"16161f","OutlineColor":"323232"}') },
        ['Ubuntu'] = { 12, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"3e3e3e","AccentColor":"e2581e","BackgroundColor":"323232","OutlineColor":"2e2e2e"}') },
        ['Quartz'] = { 13, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"232330","AccentColor":"426e87","BackgroundColor":"1d1b26","OutlineColor":"27232f"}') },
        ['Sunset Orange'] = { 14, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"2B1F13","AccentColor":"FF5733","BackgroundColor":"1F1410","OutlineColor":"3B2523"}') },
        ['Ocean Breeze'] = { 15, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"1F3A47","AccentColor":"58C1D4","BackgroundColor":"14292E","OutlineColor":"233B43"}') },
        ['Dark Cherry'] = { 16, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"2E0B0B","AccentColor":"B72A2A","BackgroundColor":"1F0707","OutlineColor":"381818"}') },
        ['Frostbite'] = { 17, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"2E3B3F","AccentColor":"A8D8E8","BackgroundColor":"192A2E","OutlineColor":"2A4C53"}') },
        ['Space Odyssey'] = { 18, httpService:JSONDecode('{"FontColor":"E4E4E4","MainColor":"121A26","AccentColor":"6E83B7","BackgroundColor":"0D1219","OutlineColor":"283346"}') },
        ['Cyberpunk Pink'] = { 19, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"2B0F25","AccentColor":"FF58A0","BackgroundColor":"1D0C1C","OutlineColor":"391E2A"}') },
        ['Vivid Green'] = { 20, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"263A23","AccentColor":"9CE1A3","BackgroundColor":"1F2F1C","OutlineColor":"2C3F28"}') }
    }

	function ThemeManager:ApplyTheme(theme)
		local customThemeData = self:GetCustomTheme(theme)
		local data = customThemeData or self.BuiltInThemes[theme]

		if not data then return end

		-- custom themes are just regular dictionaries instead of an array with { index, dictionary }

		local scheme = data[2]
		for idx, col in next, customThemeData or scheme do
			self.Library[idx] = Color3.fromHex(col)
			
			if Options[idx] then
				Options[idx]:SetValueRGB(Color3.fromHex(col))
			end
		end

		self:ThemeUpdate()
	end

    game:GetService("RunService").RenderStepped:Connect(function()
        if not Options.ThemeManager_ThemeList then return end
        if Options.ThemeManager_ThemeList.Value ~= "Rainbow" then return end
        if Options.AccentColor then
            Options.AccentColor:SetValueRGB(Color3.fromHSV(tick() % 5/5, 0.4, 1))
        end
    end)

	function ThemeManager:ThemeUpdate()
		-- This allows us to force apply themes without loading the themes tab :)
		local options = { "FontColor", "MainColor", "AccentColor", "BackgroundColor", "OutlineColor" }
		for i, field in next, options do
			if Options and Options[field] then
				self.Library[field] = Options[field].Value
			end
		end

		self.Library.AccentColorDark = self.Library:GetDarkerColor(self.Library.AccentColor);
		self.Library:UpdateColorsUsingRegistry()
	end

	function ThemeManager:LoadDefault()		
		local theme = 'Default'
		local content = isfile(self.Folder .. '/themes/default.txt') and readfile(self.Folder .. '/themes/default.txt')

		local isDefault = true
		if content then
			if self.BuiltInThemes[content] then
				theme = content
			elseif self:GetCustomTheme(content) then
				theme = content
				isDefault = false;
			end
		elseif self.BuiltInThemes[self.DefaultTheme] then
		 	theme = self.DefaultTheme
		end

		if isDefault then
			Options.ThemeManager_ThemeList:SetValue(theme)
		else
			self:ApplyTheme(theme)
		end
	end

	function ThemeManager:SaveDefault(theme)
		writefile(self.Folder .. '/themes/default.txt', theme)
	end

	function ThemeManager:CreateThemeManager(groupbox)
		groupbox:AddLabel('Background color'):AddColorPicker('BackgroundColor', { Default = self.Library.BackgroundColor });
		groupbox:AddLabel('Main color')	:AddColorPicker('MainColor', { Default = self.Library.MainColor });
		groupbox:AddLabel('Accent color'):AddColorPicker('AccentColor', { Default = self.Library.AccentColor });
		groupbox:AddLabel('Outline color'):AddColorPicker('OutlineColor', { Default = self.Library.OutlineColor });
		groupbox:AddLabel('Font color')	:AddColorPicker('FontColor', { Default = self.Library.FontColor });

		local ThemesArray = {}
		for Name, Theme in next, self.BuiltInThemes do
			table.insert(ThemesArray, Name)
		end

		table.sort(ThemesArray, function(a, b) return self.BuiltInThemes[a][1] < self.BuiltInThemes[b][1] end)

		groupbox:AddDivider()
		groupbox:AddDropdown('ThemeManager_ThemeList', { Text = 'Theme list', Values = ThemesArray, Default = 1 })

		groupbox:AddButton('Set as default', function()
			self:SaveDefault(Options.ThemeManager_ThemeList.Value)
			self.Library:Notify(string.format('Set default theme to %q', Options.ThemeManager_ThemeList.Value))
		end)

		Options.ThemeManager_ThemeList:OnChanged(function()
			self:ApplyTheme(Options.ThemeManager_ThemeList.Value)
		end)

		groupbox:AddDivider()
		groupbox:AddInput('ThemeManager_CustomThemeName', { Text = 'Custom theme name' })
		groupbox:AddDropdown('ThemeManager_CustomThemeList', { Text = 'Custom themes', Values = self:ReloadCustomThemes(), AllowNull = true, Default = 1 })
		
		newgroupboxsettings:AddButton('Save theme', function() 
			self:SaveCustomTheme(Options.ThemeManager_CustomThemeName.Value)

			Options.ThemeManager_CustomThemeList:SetValues(self:ReloadCustomThemes())
			Options.ThemeManager_CustomThemeList:SetValue(nil)
		end):AddButton('Load theme', function() 
			self:ApplyTheme(Options.ThemeManager_CustomThemeList.Value) 
		end)

		newgroupboxsettings:AddButton('Refresh list', function()
			Options.ThemeManager_CustomThemeList:SetValues(self:ReloadCustomThemes())
			Options.ThemeManager_CustomThemeList:SetValue(nil)
		end)

		newgroupboxsettings:AddButton('Set as default', function()
			if Options.ThemeManager_CustomThemeList.Value ~= nil and Options.ThemeManager_CustomThemeList.Value ~= '' then
				self:SaveDefault(Options.ThemeManager_CustomThemeList.Value)
				self.Library:Notify(string.format('Set default theme to %q', Options.ThemeManager_CustomThemeList.Value))
			end
		end)

		ThemeManager:LoadDefault()

		local function UpdateTheme()
			self:ThemeUpdate()
		end

		Options.BackgroundColor:OnChanged(UpdateTheme)
		Options.MainColor:OnChanged(UpdateTheme)
		Options.AccentColor:OnChanged(UpdateTheme)
		Options.OutlineColor:OnChanged(UpdateTheme)
		Options.FontColor:OnChanged(UpdateTheme)
	end

	function ThemeManager:GetCustomTheme(file)
		local path = self.Folder .. '/themes/' .. file
		if not isfile(path) then
			return nil
		end

		local data = readfile(path)
		local success, decoded = pcall(httpService.JSONDecode, httpService, data)
		
		if not success then
			return nil
		end

		return decoded
	end

	function ThemeManager:SaveCustomTheme(file)
		if file:gsub(' ', '') == '' then
			return self.Library:Notify('Invalid file name for theme (empty)', 3)
		end

		local theme = {}
		local fields = { "FontColor", "MainColor", "AccentColor", "BackgroundColor", "OutlineColor" }

		for _, field in next, fields do
			theme[field] = Options[field].Value:ToHex()
		end

		writefile(self.Folder .. '/themes/' .. file .. '.json', httpService:JSONEncode(theme))
	end

	function ThemeManager:ReloadCustomThemes()
		local list = listfiles(self.Folder .. '/themes')

		local out = {}
		for i = 1, #list do
			local file = list[i]
			if file:sub(-5) == '.json' then
				-- i hate this but it has to be done ...

				local pos = file:find('.json', 1, true)
				local char = file:sub(pos, pos)

				while char ~= '/' and char ~= '\\' and char ~= '' do
					pos = pos - 1
					char = file:sub(pos, pos)
				end

				if char == '/' or char == '\\' then
					table.insert(out, file:sub(pos + 1))
				end
			end
		end

		return out
	end

	function ThemeManager:SetLibrary(lib)
		self.Library = lib
	end

	function ThemeManager:BuildFolderTree()
		local paths = {}

		-- build the entire tree if a path is like some-hub/phantom-forces
		-- makefolder builds the entire tree on Synapse X but not other exploits

		local parts = self.Folder:split('/')
		for idx = 1, #parts do
			paths[#paths + 1] = table.concat(parts, '/', 1, idx)
		end

		table.insert(paths, self.Folder .. '/themes')
		table.insert(paths, self.Folder .. '/settings')

		for i = 1, #paths do
			local str = paths[i]
			if not isfolder(str) then
				makefolder(str)
			end
		end
	end

	function ThemeManager:SetFolder(folder)
		self.Folder = folder
		self:BuildFolderTree()
	end

	function ThemeManager:CreateGroupBox(tab)
		assert(self.Library, 'Must set ThemeManager.Library first!')
        newgroupboxsettings = tab:AddRightGroupbox('Custom Theme Settings')
		return tab:AddLeftGroupbox('Themes')
	end

	function ThemeManager:ApplyToTab(tab)
		assert(self.Library, 'Must set ThemeManager.Library first!')
		local groupbox = self:CreateGroupBox(tab)
		self:CreateThemeManager(groupbox)
	end

	function ThemeManager:ApplyToGroupbox(groupbox)
		assert(self.Library, 'Must set ThemeManager.Library first!')
		self:CreateThemeManager(groupbox)
	end

	ThemeManager:BuildFolderTree()
end

return ThemeManager
