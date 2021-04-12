# Before build: "clean" by removing a bunch of directories that will be rebuilt
rm -rf docs/assets/htmlwidgets
rm -rf docs/_site
rm -rf docs/_slides
rm -rf cache

# Now build.

# After build: locate popuptable and leaflet providers and move them to the htmlwidgets root directory.

providersfile=`find docs/assets/NA -type f -name "leaflet-providers_1.9.0.js"`
mv $providersfile docs/assets/htmlwidgets/
rm -rf docs/assets/NA

mv docs/assets/htmlwidgets/lib/popup/popup.css docs/assets/htmlwidgets/

# Edit htmlwidgets.yml to replace lines that say "src: .na.character" with root directory.

sed -i 's/\.na\.character/htmlwidgets/g' docs/_data/htmlwidgets.yml
