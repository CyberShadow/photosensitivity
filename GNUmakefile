path_pub = $(PWD)/pub
path_tmp = $(PWD)/tmp

### FFmpeg (native)

path_ffmpeg_src = $(HOME)/work/extern/ffmpeg
path_ffmpeg_src_files = $(path_ffmpeg_src)/libavfilter/vf_photosensitivity.c

path_ffmpeg_build_native = $(path_tmp)/build/ffmpeg/native
path_ffmpeg_build_native_config = $(path_ffmpeg_build_native)/Makefile
path_ffmpeg_build_native_exe = $(path_ffmpeg_build_native)/ffmpeg

$(path_ffmpeg_build_native_config) :
	mkdir -p $(path_ffmpeg_build_native)
	cd $(path_ffmpeg_build_native) && $(path_ffmpeg_src)/configure

$(path_ffmpeg_build_native_exe) : $(path_ffmpeg_build_native_config) $(path_ffmpeg_src_files)
	cd $(path_ffmpeg_build_native) && ccache-run make -j12

ffmpeg : $(path_ffmpeg_build_native_exe)

### FFmpeg (win64)

path_ffmpeg_build_win64 = $(path_tmp)/build/ffmpeg/win64
path_ffmpeg_build_win64_config = $(path_ffmpeg_build_win64)/Makefile
path_ffmpeg_build_win64_exe = $(path_ffmpeg_build_win64)/ffmpeg

$(path_ffmpeg_build_win64_config) :
	mkdir -p $(path_ffmpeg_build_win64)
	cd $(path_ffmpeg_build_win64) && $(path_ffmpeg_src)/configure --arch=x86_64 --target-os=mingw32 --cross-prefix=x86_64-w64-mingw32- --enable-shared --enable-static

$(path_ffmpeg_build_win64_exe) : $(path_ffmpeg_build_win64_config) $(path_ffmpeg_src_files)
	ccache-run make -C $(path_ffmpeg_build_win64) -j12

path_pub_ffmpeg = $(path_pub)/ffmpeg.7z
$(path_pub_ffmpeg) : $(path_ffmpeg_build_win64_exe)
	rm -rf $(path_tmp)/out
	mkdir $(path_tmp)/out
	cp `ls $(path_ffmpeg_build_win64)/*.exe $(path_ffmpeg_build_win64)/*/*-*.dll | grep -v _g.exe` $(path_tmp)/out/
	cp /usr/x86_64-w64-mingw32/bin/{SDL2.dll,libwinpthread-1.dll,zlib1.dll} $(path_tmp)/out/
	rm -f $@
	cd $(path_tmp)/out/ && 7z a $@ *
ffmpeg-win64 : $(path_pub_ffmpeg)

### MXE

path_mxe = /tmp/2019-03-10/mxe
mxe_target = x86_64-w64-mingw32.static

$(path_mxe) :
	git clone https://github.com/mxe/mxe $(path_mxe)

path_mxe_config = $(path_mxe)/settings.mk
$(path_mxe_config) : | $(path_mxe)
	echo JOBS := 12 > $@
	echo MXE_TARGETS := $(mxe_target) >> $@

tgt_mxe_deps = $(path_tmp)/tgt-mxe-deps
$(tgt_mxe_deps) : $(path_mxe_config)
	cd $(path_mxe) && make gcc libass jpeg lua luajit rubberband
	touch $@

path_mxe_ffmpeg_exe = $(path_mxe)/usr/$(mxe_target)/bin/ffmpeg.exe
$(path_mxe_ffmpeg_exe) : $(path_ffmpeg_src_files) $(tgt_mxe_deps)
	touch $(path_mxe)/src/ffmpeg.mk
	rm -rf $(path_mxe)/tmp-$(mxe_target)
	cd $(path_mxe) && make ffmpeg libass jpeg lua luajit rubberband ffmpeg_SOURCE_TREE=$(path_ffmpeg_src)

### MPV

path_mpv = $(HOME)/work/extern/mpv
path_mpv_build_win64 = $(path_tmp)/build/mpv/win64
path_mpv_build_win64_config = $(path_mpv_build_win64)/config.h
path_mpv_build_win64_exe = $(path_mpv_build_win64)/mpv.exe

$(path_mpv_build_win64_config) : $(path_mxe_ffmpeg_exe)
	mkdir -p $(path_mpv_build_win64)
	cd $(path_mpv) && export PATH=$(path_mxe)/usr/bin:$$PATH && DEST_OS=win32 TARGET=$(mxe_target) python2 ./waf -o $(path_mpv_build_win64) configure

$(path_mpv_build_win64_exe) : $(path_mpv_build_win64_config)
	cd $(path_mpv) && export PATH=$(path_mxe)/usr/bin:$$PATH &&                                    python2 ./waf -o $(path_mpv_build_win64) build

path_pub_mpv = $(path_pub)/mpv.7z
$(path_pub_mpv) : $(path_mpv_build_win64_exe)
	rm -f $(path_pub)/mpv.7z
	7z a $(path_pub)/mpv.7z $(path_mpv_build_win64)/mpv.exe $(path_mpv_build_win64)/mpv.com
mpv : $(path_pub_mpv)

### Video stuff

action := filter
params := t=1

video-action-filter :
	printf -- '%q ' -vf "photosensitivity=$(params)" > $(path_tmp)/cmd-action.txt

video-action-comparison :
	printf -- '%q ' -filter_complex "$$(params="$(params)" ./comparison-filter.sh)" > $(path_tmp)/cmd-action.txt

video-output-mpv :
	printf -- '%q ' mpv - > $(path_tmp)/cmd-output.txt

video-output-encode :
	printf -- '%q ' ffmpeg -y -i - -pix_fmt yuv420p '-c:v' libx264 -crf 15 out.mp4 > $(path_tmp)/cmd-output.txt

$(path_tmp)/cmd.txt : video-action-$(action) video-output-$(output)
	printf -- '%q ' "$(path_ffmpeg_build_native_exe)" -y -loglevel verbose > $@
	cat $(path_tmp)/cmd-action.txt >> $@
	printf -- '%q ' -i $(fn) $(ffmpeg_args) '-c:v' rawvideo -c:a copy -f nut  -  >> $@
	printf ' | ' >> $@
	cat $(path_tmp)/cmd-output.txt >> $@

video : $(path_ffmpeg_build_native_exe) $(path_tmp)/cmd.txt
	bash -s < $(path_tmp)/cmd.txt
