cat <<EOF
scale
	=w=640
	:h=-2,

photosensitivity=${params},
split[P][I];

[I]$(cat filter-drawgraph.txt)
	:size=640x100
[G];

[P][G]vstack
EOF
