cat <<EOF
scale
	=w=640
	:h=-2,

photosensitivity=${params},
split[P][I];

[I]drawgraph
	=fg1=0x00FFFF:m1=lavfi.photosensitivity.fixed-badness
	:fg2=0x0000FF:m2=lavfi.photosensitivity.badness
	:fg3=0xFF00FF:m3=lavfi.photosensitivity.frame-badness
	:fg4=0x00FF00:m4=lavfi.photosensitivity.factor
	:min=0
	:max=2
	:slide=scroll
	:bg=0x000000
	:mode=line
	:size=640x100
[G];

[P][G]vstack
EOF
