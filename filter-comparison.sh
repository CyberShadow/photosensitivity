cat <<EOF
scale
	=w=640
	:h=-2,
split[A][B];

[B]photosensitivity=${params}[P];

[P]split[R][I];

[A][R]hstack[C];

[I]$(cat filter-drawgraph.txt)
	:size=1280x100
[G];

[C][G]vstack
EOF
