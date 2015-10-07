function es --description 'Edit text based executable files in your PATH'
    set -l editor vim
    set -l res 0

    set -l configdir ~/.config
    if set -q XDG_CONFIG_HOME
        set configdir $XDG_CONFIG_HOME
    end

	if test (count $argv) -eq 1
        if functions -q -- $argv
            set -l funcA "$configdir/fish/functions/$argv.fish"

            if test -e $funcA;
                eval $editor "$funcA"
            else
                set funcB "/usr/share/fish/functions/$argv.fish"

                if test -e $funcB
                    eval $editor "$funcB"
                else
                    if test -e ~/.bash_aliases
                        set -l alias (grep "alias $argv" ~/.bash_aliases)

                        if test $status -eq 0
                            echo "'$argv' might be a bash alias from ~/.bash_aliases: $alias" 
                            echo
                            echo "However in this fish shell:"
                            echo
                            type $argv

                            set res 2
                        end
                    end
                    if test $res -ne 2
                        if test -e ~/.bashrc
                            set alias (grep "alias $argv" ~/.bashrc)

                            if test $status -eq 0
                                echo "'$argv' might be a bash alias from ~/.bashrc: $alias"
                                echo
                                echo "However in this fish shell:"
                                echo
                                type $argv

                                set res 2
                            else
                                echo "fish_script: '$funcA' was not found."
                                echo "You might consider looking in `/usr/share/fish` and sub dirs."
                                echo "TIP: man funcsave"
                                echo 
                                type $argv

                                set res 1
                            end
                        else
                            echo "fish_script: '$funcA' was not found."
                            echo "You might consider looking in `/usr/share/fish` and sub dirs."
                            echo "TIP: man funcsave"
                            echo
                            type $argv

                            set res 1
                        end
                    end
                end
            end
        else
            set -l cmd (command -s $argv)

            if test $status -eq 0
                set -l path (realpath $cmd)

                if not file "$path" -i | grep -iq "binary"
                    eval $editor "$path"
                else
                    echo "'$path' is a binary file."
                    set res 1
                end
            else
                set res 1

                if contains -- $argv (builtin -n)
                    echo "'$argv' is a builtin."
                else
                    echo "No command '$argv' found."
                end
            end
        end
    else
        functions -n
    end

    return $res
end
