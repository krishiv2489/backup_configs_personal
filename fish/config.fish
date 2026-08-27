# ==============================================================================
# Plugin Manager (Fisher) — optional
# ==============================================================================
# fish ships autosuggestions and syntax highlighting natively, so the zsh
# equivalents of those two plugins aren't needed. Uncomment below only if you
# want oh-my-zsh's git aliases too:
#
# if not functions -q fisher
#     curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source
#     fisher install jorgebucaran/fisher
# end
# if not functions -q gst
#     fisher install oh-my-fish/plugin-git
# end

# ==============================================================================
# History
# ==============================================================================
# No config needed — fish auto-dedupes, auto-appends, and shares history
# across open sessions by default. HISTFILE/HISTSIZE/SAVEHIST have no fish
# equivalent because this is already fish's default behavior.

# ==============================================================================
# Custom Functions
# ==============================================================================

# Automatically list directory contents upon changing directories
function cd
    builtin cd $argv
    and ls
end

# Dynamic Fastfetch with Matugen Colors
function fetch
    set -l color_file "$HOME/.config/hypr/scripts/quickshell/qs_colors.json"
    set -l config_path "/tmp/qs_fastfetch.jsonc"

    if test "$color_file" -nt "$config_path"; or not test -f "$config_path"

        set -l c_blue (grep -E '"blue"\s*:\s*"[^"]+"' $color_file 2>/dev/null | cut -d '"' -f 4)
        test -z "$c_blue"; and set c_blue "#89b4fa"

        set -l c_sapphire (grep -E '"sapphire"\s*:\s*"[^"]+"' $color_file 2>/dev/null | cut -d '"' -f 4)
        test -z "$c_sapphire"; and set c_sapphire "#74c7ec"

        set -l c_teal (grep -E '"teal"\s*:\s*"[^"]+"' $color_file 2>/dev/null | cut -d '"' -f 4)
        test -z "$c_teal"; and set c_teal "#94e2d5"

        set -l c_mauve (grep -E '"mauve"\s*:\s*"[^"]+"' $color_file 2>/dev/null | cut -d '"' -f 4)
        test -z "$c_mauve"; and set c_mauve "#cba6f7"

        set -l c_text (grep -E '"text"\s*:\s*"[^"]+"' $color_file 2>/dev/null | cut -d '"' -f 4)
        test -z "$c_text"; and set c_text "#cdd6f4"

        set -l palette_hexes
        for col in red peach yellow green sapphire mauve pink
            set -l val (grep -E "\"$col\"\s*:\s*\"[^\"]+\"" $color_file 2>/dev/null | cut -d '"' -f 4)
            switch $col
                case red
                    test -z "$val"; and set val "#f38ba8"
                case peach
                    test -z "$val"; and set val "#fab387"
                case yellow
                    test -z "$val"; and set val "#f9e2af"
                case green
                    test -z "$val"; and set val "#a6e3a1"
                case sapphire
                    test -z "$val"; and set val "#74c7ec"
                case mauve
                    test -z "$val"; and set val "#cba6f7"
                case pink
                    test -z "$val"; and set val "#f5c2e7"
            end
            set -a palette_hexes $val
        end

        set -l palette_str ""
        for hex in $palette_hexes
            set -l hex (string replace -a "#" "" -- $hex)
            set -l r (math "0x"(string sub -s 1 -l 2 -- $hex))
            set -l g (math "0x"(string sub -s 3 -l 2 -- $hex))
            set -l b (math "0x"(string sub -s 5 -l 2 -- $hex))
            set palette_str "$palette_str""\\\\e[38;2;$r;$g;$b""m● \\\\e[0m"
        end

        echo "{
  \"\$schema\": \"https://github.com/fastfetch-cli/fastfetch/raw/master/doc/json_schema.json\",
  \"logo\": {
    \"source\": \"OS_LOGO_PLACEHOLDER\",
    \"color\": {
      \"1\": \"$c_blue\",
      \"2\": \"$c_sapphire\"
    },
    \"padding\": { \"top\": 1, \"left\": 2, \"right\": 3 }
  },
  \"display\": {
    \"separator\": \"  \",
    \"color\": { \"separator\": \"$c_text\" }
  },
  \"modules\": [
    \"break\",
    { \"type\": \"title\", \"format\": \"{1}\", \"color\": { \"user\": \"$c_blue\" } },
    \"break\",
    { \"type\": \"os\", \"key\": \" os \", \"keyColor\": \"$c_blue\" },
    { \"type\": \"cpu\", \"key\": \" cpu\", \"keyColor\": \"$c_sapphire\" },
    { \"type\": \"memory\", \"key\": \" ram\", \"keyColor\": \"$c_teal\" },
    { \"type\": \"shell\", \"key\": \" sh \", \"keyColor\": \"$c_mauve\" },
    \"break\",
    { \"type\": \"command\", \"key\": \" \", \"text\": \"echo -e '$palette_str'\" }
  ]
}" > $config_path
    end

    fastfetch -c $config_path
end

# ==============================================================================
# Execute on Startup
# ==============================================================================
if status is-interactive
    fetch
end


if status is-interactive
    # No greeting
    set fish_greeting

    # Use starship prompt
    if command -v starship &>/dev/null
        starship init fish | source
    end

    # Apply terminal color sequences (Material You from wallpaper)
    if test -f ~/.local/state/quickshell/user/generated/terminal/sequences.txt
        cat ~/.local/state/quickshell/user/generated/terminal/sequences.txt
    end

    # Aliases
    alias clear "printf '\033[2J\033[3J\033[1;1H'" # fix: kitty doesn't clear scrollback properly
    alias celar "printf '\033[2J\033[3J\033[1;1H'"
    alias claer "printf '\033[2J\033[3J\033[1;1H'"
    if command -v eza &>/dev/null
        alias ls 'eza --icons'
    end
    alias q 'inir run'
end
