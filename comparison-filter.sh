cat <<EOF
scale
	=w=640
	:h=-2,
split[A][B];

[B]photosensitivity=${params}[P];

[P]split[R][I];

[A][R]hstack[C];

[I]drawgraph
	=fg1=0x0000FF:m1=lavfi.photosensitivity.badness
	:fg2=0x00FF00:m2=lavfi.photosensitivity.factor
	:min=0
	:max=2
	:slide=scroll
	:bg=0x000000
	:mode=line
	:size=1280x100
[G];

[C][G]vstack
EOF
