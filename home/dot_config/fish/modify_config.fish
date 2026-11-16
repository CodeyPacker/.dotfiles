{{- /* chezmoi:modify-template */ -}}
{{- $marker := "# >>> dotfiles quiet fish greeting >>>" -}}
{{- if contains $marker .chezmoi.stdin -}}
{{- replaceAllRegex `(?ms)^# >>> dotfiles quiet fish greeting >>>\n.*?^# <<< dotfiles quiet fish greeting <<<\n?` .chezmoi.stdin `# >>> dotfiles quiet fish greeting >>>
function fish_greeting
end
# <<< dotfiles quiet fish greeting <<<
` -}}
{{- else -}}
{{ .chezmoi.stdin }}
# >>> dotfiles quiet fish greeting >>>
function fish_greeting
end
# <<< dotfiles quiet fish greeting <<<
{{- end -}}
