path_pub = $(PWD)/pub
path_tmp = $(PWD)/tmp
path_local = /mnt/local/tmp

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
	ccache make -C $(path_ffmpeg_build_native) -j`nproc`

ffmpeg : $(path_ffmpeg_build_native_exe)

### FFmpeg (win64)

path_ffmpeg_build_win64 = $(path_tmp)/build/ffmpeg/win64
path_ffmpeg_build_win64_config = $(path_ffmpeg_build_win64)/Makefile
path_ffmpeg_build_win64_exe = $(path_ffmpeg_build_win64)/ffmpeg.exe

$(path_ffmpeg_build_win64_config) :
	mkdir -p $(path_ffmpeg_build_win64)
	cd $(path_ffmpeg_build_win64) && $(path_ffmpeg_src)/configure --arch=x86_64 --target-os=mingw32 --cross-prefix=x86_64-w64-mingw32- --disable-shared --enable-static

$(path_ffmpeg_build_win64_exe) : $(path_ffmpeg_build_win64_config) $(path_ffmpeg_src_files)
	ccache make -C $(path_ffmpeg_build_win64) -j`nproc`

path_pub_ffmpeg = $(path_pub)/bin/ffmpeg.7z
$(path_pub_ffmpeg) : $(path_ffmpeg_build_win64_exe)
	rm -rf $(path_tmp)/out
	mkdir $(path_tmp)/out
	cp `ls $(path_ffmpeg_build_win64)/*.exe $(path_ffmpeg_build_win64)/*/*-*.dll | grep -v _g.exe` $(path_tmp)/out/
	-for f in /usr/x86_64-w64-mingw32/bin/{SDL2,libwinpthread-1,zlib1,libbz2-1,libiconv-2,liblzma-5}.dll ; do cp "$$f" $(path_tmp)/out/ ; done || true
	rm -f $@
	cd $(path_tmp)/out/ && 7z a $@ *
ffmpeg-win64 : $(path_pub_ffmpeg)

### MXE

path_mxe = $(path_local)/mxe
mxe_target = x86_64-w64-mingw32.static

$(path_mxe) :
	git clone https://github.com/mxe/mxe $(path_mxe)

path_mxe_config = $(path_mxe)/settings.mk
$(path_mxe_config) : | $(path_mxe)
	echo JOBS := `nproc` > $@
	echo MXE_TARGETS := $(mxe_target) >> $@

tgt_mxe_deps = $(path_tmp)/tgt-mxe-deps
$(tgt_mxe_deps) : $(path_mxe_config)
	make -C $(path_mxe) gcc libass jpeg lua luajit rubberband
	touch $@

path_mxe_ffmpeg_exe = $(path_mxe)/usr/$(mxe_target)/bin/ffmpeg.exe
$(path_mxe_ffmpeg_exe) : $(path_ffmpeg_src_files) $(tgt_mxe_deps)
	touch $(path_mxe)/src/ffmpeg.mk
	rm -rf $(path_mxe)/tmp-$(mxe_target)
	make -C $(path_mxe) ffmpeg libass jpeg lua luajit rubberband ffmpeg_SOURCE_TREE=$(path_ffmpeg_src)

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

path_pub_mpv = $(path_pub)/bin/mpv.7z
$(path_pub_mpv) : $(path_mpv_build_win64_exe)
	rm -f $(path_pub)/bin/mpv.7z
	7z a $(path_pub)/bin/mpv.7z $(path_mpv_build_win64)/mpv.exe $(path_mpv_build_win64)/mpv.com
mpv : $(path_pub_mpv)

### Video stuff

action := filter
out_fn := out.mp4
input := fn

video-input-fn :
	printf -- '%q ' -i $(fn) > $(path_tmp)/cmd-input.txt

video-input-sample-% :
	cat samples/$*.txt > $(path_tmp)/cmd-input.txt

video-action-render :
	printf -- '%q ' -vf "photosensitivity=$(params)" > $(path_tmp)/cmd-action.txt

video-action-filter :
	printf -- '%q ' -filter_complex "$$(params="$(params)" ./filter-$(filter).sh)" > $(path_tmp)/cmd-action.txt

video-output-mpv :
	printf -- '%q ' mpv - > $(path_tmp)/cmd-output.txt

video-output-encode :
	printf -- '%q ' ffmpeg -y -i - -pix_fmt yuv420p '-c:v' libx264 -crf 15 "$(out_fn)" > $(path_tmp)/cmd-output.txt

$(path_tmp)/cmd.txt : video-input-$(input) video-action-$(action) video-output-$(output)
	printf -- '%q ' "$(path_ffmpeg_build_native_exe)" -y -loglevel verbose > $@
	cat $(path_tmp)/cmd-input.txt >> $@
	printf -- '%q ' $(ffmpeg_args) >> $@
	cat $(path_tmp)/cmd-action.txt >> $@
	printf -- '%q ' -max_muxing_queue_size 1024 '-c:v' rawvideo -c:a copy -f nut  -  >> $@
	printf ' | ' >> $@
	cat $(path_tmp)/cmd-output.txt >> $@

video : $(path_ffmpeg_build_native_exe) $(path_tmp)/cmd.txt
	bash -s < $(path_tmp)/cmd.txt

video-render :
	make video input=sample-$(sample) action=render output=encode params=$(params) out_fn=$(path_pub)/vid/$(sample)-filtered$(suffix).mp4

video-filter-% :
	make video input=sample-$(sample) action=filter output=encode params=$(params) out_fn=$(path_pub)/vid/$(sample)-$*$(suffix).mp4 filter=$*

video-play :
	make video input=sample-$(sample) action=render output=mpv
