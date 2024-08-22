source "$stdenv/setup"

export HOME=$(mktemp -d)
mkdir --parents "$out"/
ghost install "$version" --db=sqlite3 \
  --no-enable --no-prompt --no-stack --no-setup --no-start --dir "$out"
