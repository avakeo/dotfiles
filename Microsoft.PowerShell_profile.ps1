# Shared lightweight aliases (align with zsh)
Set-Alias g git -Option AllScope
Set-Alias v nvim -Option AllScope
Set-Alias ll "ls -al"

# Optional: starship prompt if available
if (Get-Command starship -ErrorAction SilentlyContinue) {
	Invoke-Expression (& starship init powershell)
}
