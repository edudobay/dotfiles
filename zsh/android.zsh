for dir in \
    $HOME/Library/Android/sdk \
    $HOME/Android/Sdk;
do
  if [[ -d $dir ]]; then
    export ANDROID_HOME=$dir

    path+=(
      $ANDROID_HOME/platform-tools
      $ANDROID_HOME/tools
    )

    break
  fi
done
