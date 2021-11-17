import json
from os import listdir
from subprocess import PIPE, run
import os
from sys import argv
from time import sleep
from sys import exit

print(argv)
# sleep(10)
if len(argv) == 1:
    files = listdir()
    videos = [f for f in files if f.endswith(('mp4', 'mov', 'webm'))]
    subs = [f for f in files if f.endswith('.ass')]
    if len(videos) == 0 or len(subs) == 0:
        print('no video and/or .ass found. Quitting')
        sleep(5)
        exit(1)
    video, ass = videos[0], subs[0]
elif len(argv) == 3:
    video, ass = (argv[1], argv[2]) if argv[1].endswith(('mp4', 'mov', 'webm')) and argv[2].endswith('ass') else (argv[2], argv[1]) if argv[2].endswith(('mp4', 'mov', 'webm')) and argv[1].endswith('ass') else (None, None)
    if not all([video, ass]):
        print('unrecognized extensions, please double check')
        sleep(5)
        exit(1)
elif len(argv) > 3:
    print('too many files, can only do 1 video/ass at a time')
    sleep(5)
    exit(1)
else:
    print('UNKNOWN ERROR')
    sleep(5)
    exit(1)

probe = run(['ffprobe', '-print_format', 'json', '-show_streams', video],
            stdout=PIPE)
info = json.loads(probe.stdout)
# maintain same bitrate for video stream
video_stream = list(filter(lambda s: s['codec_type'] == 'video', info['streams']))[0]
bitrate = str(int(video_stream['bit_rate']) / 1000) + 'k'

f_out = '【已压】' + os.path.basename(video)
out_name = os.path.join(os.path.expanduser('~'), 'Desktop', f_out)
# ffmpeg filters using absolute path is a nightmare with crazy escapes, change working directory instead
ass_dir = os.path.dirname(ass)
os.chdir(ass_dir)
ass = os.path.basename(ass)
run(['ffmpeg', '-i', video, '-pix_fmt', 'yuv420p', '-vf', f'subtitles={ass}', '-c:a', 'copy',
'-c:v', 'h264_nvenc', '-b:v', bitrate, '-profile:v', 'high', '-level', '5.1', '-rc', 'vbr', '-tune', 'hq', '-rc-lookahead', '16', '-b_ref_mode', 'middle', out_name])
