--- @since 25.5.31

-- WSL にいるときは Windows のホームへ、Windows にいるときは WSL のホームへ移動する
local function other_home()
	if ya.target_family() == "windows" then
		-- \\wsl.localhost\<ディストリビューション>\home\<ユーザー> が返る
		return Command("wsl.exe"):arg({ "sh", "-c", "wslpath -w ~" }):output()
	elseif os.getenv("WSL_DISTRO_NAME") then
		-- cmd.exe は Linux 側のディレクトリにいると警告を出すので /mnt/c から呼ぶ
		return Command("sh")
			:arg({ "-c", [[cd /mnt/c && wslpath "$(cmd.exe /c 'echo %USERPROFILE%' 2>/dev/null | tr -d '\r')"]] })
			:output()
	end
	return nil, "WSL か Windows でだけ使える"
end

local function entry()
	local output, err = other_home()
	local path = output and output.status.success and output.stdout:gsub("%s+$", "")
	if not path or path == "" then
		ya.notify { title = "wsl-hop", content = tostring(err or "移動先が見つからない"), timeout = 3, level = "warn" }
		return
	end
	ya.emit("cd", { path })
end

return { entry = entry }
