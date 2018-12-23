## Android development

Don’t remember anymore why this was useful, probably this is very old

```
export ANDROID_HVPROTO=ddm
```

## Zsh — Profile startup time

See: https://kev.inburke.com/kevin/profiling-zsh-startup-time/

```
# <Profiling>
PROFILE_STARTUP=false
if [[ "$PROFILE_STARTUP" == true ]]; then
    # http://zsh.sourceforge.net/Doc/Release/Prompt-Expansion.html
    PS4=$'%D{%M%S%.}\t%N:%i> '
    exec 3>&2 2>$HOME/tmp/startlog.$$
    setopt xtrace prompt_subst
fi
# </Profiling>

# ... Your initialization here
 
# <Profiling>
if [[ "$PROFILE_STARTUP" == true ]]; then
    unsetopt xtrace
    exec 2>&3 3>&-
fi
# </Profiling>
```
