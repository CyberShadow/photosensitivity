cat <<EOF
scale
	=w=640
	:h=-2,
split[A][B];

[B]photosensitivity=${params},

$(cat filter-drawgraph.txt)
	:size=640x100
[G];

[A][G]vstack
EOF
