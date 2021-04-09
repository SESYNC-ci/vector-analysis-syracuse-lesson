# Another component of build: locate popuptable and leaflet providers and move them to the htmlwidgets root directory.

mv docs/assets/NA/Rtmp6v8Fep/leaflet-providers_1.9.0.js docs/assets/htmlwidgets/
rm -rf docs/assets/NA

mv docs/assets/htmlwidgets/lib/popup/popup.css docs/assets/htmlwidgets/

# Edit htmlwidgets.yml to replace lines that say "src: .na.character" with root directory.

sed -i 's/\.na\.character/htmlwidgets/g' docs/_data/htmlwidgets.yml
