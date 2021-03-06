#!/usr/bin/env bash
set -Ceu

cd "${0%/*}"

caskVersion=$(
    grep -m 1 -E 'version "([0-9]{1}.[0-9]{2}.[0-9]{1,2})"' < ./Casks/swiftformat-for-xcode.rb |
        sed -e 's/  version "//g' -e 's/"//g'
)

latestVersion=$(
    curl https://github.com/nicklockwood/SwiftFormat/releases.atom |
        grep -m 1 -E "<title>([0-9]{1}.[0-9]{2}.[0-9]{1,2})" |
        sed -e 's/    <title>//g' -e 's/<\/title>//g'
)

sha256=$(
    curl "https://codeload.github.com/nicklockwood/SwiftFormat/zip/${latestVersion}" |
        shasum -a 256 |
        awk '{print $1}'
)

if [[ $caskVersion != "$latestVersion" ]]; then
    sed -i '' -e "s/^  version.*/  version \"$latestVersion\"/" ./Casks/swiftformat-for-xcode.rb
    sed -i '' -e "s/^  sha256.*/  sha256 '$sha256'/" ./Casks/swiftformat-for-xcode.rb
fi

wait
git add . && git commit -m "auto commit by updater.sh" && git push origin
