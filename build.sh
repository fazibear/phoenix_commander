#!/bin/bash
export SECRET_KEY_BASE=ENhzfdb/3IwgO8LX0QHfYqPfpU6I8kyrPG348vFwRkzxG0CjN7+egBO/F0RJnjxE
export MIX_ENV=prod
export DESKTOP=true

mix clean
mix deps.get --only prod
mix compile
npm run deploy --prefix ./assets
mix phx.digest
mix release --overwrite

APP=PhoenixCommander
APP_DIR="${APP}.app/Contents/MacOS"
RELEASE=_build/prod/rel/phoenix_commander

rm -rf $APP.app
mkdir -p $APP_DIR
echo "cp -r $RELEASE $APP_DIR"
cp -r $RELEASE $APP_DIR
echo "#!/bin/bash" > $APP_DIR/$APP
echo 'DIR="\$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )' >> $APP_DIR/$APP
echo '$DIR/phoenix_commander/bin/phoenix_commander start' >> $APP_DIR/$APP
chmod +x $APP_DIR/$APP
