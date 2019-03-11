cat <<EOF
scale
	=w=640
	:h=-2,
split[A][B];

[B]photosensitivity=${params}[P];

[P]split[R][I];

[A][R]hstack[C];

[I]drawgraph
	=m1=lavfi.photosensitivity.badness
	:fg1=0xFF0000
	:m2=lavfi.photosensitivity.factor
	:fg2=0x00FF00
	:min=0
	:max=2
	:slide=scroll
	:bg=0x000000
	:mode=line
	:size=1280x200
[G];

[C][G]vstack
EOF
