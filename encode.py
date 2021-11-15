import json
from os import listdir
from subprocess import PIPE, run
import os

files = listdir()
videos = [f for f in files if f.endswith('.mp4')]
subs = [f for f in files if f.endswith('.ass')]
if len(videos) == 0 or len(subs) == 0:
    from time import sleep
    from sys import exit
    print('no .mp4 and/or .ass found. Quitting')
    sleep(5)
    exit(1)

video, ass = videos[0], subs[0]

probe = run(['ffprobe', '-print_format', 'json', '-show_streams', video],
            stdout=PIPE)
info = json.loads(probe.stdout)
# maintain same bitrate
bitrate = str(int(int(info['streams'][0]['bit_rate']) / 1000)) + 'k'

f_out = '【已压】' + video
out_name = os.path.join(os.path.expanduser('~'), 'Desktop', f_out)
print(out_name)
run(['ffmpeg', '-i', video, '-pix_fmt', 'yuv420p', '-vf', f'subtitles={ass}', '-c:a', 'copy',
'-c:v', 'h264_nvenc', '-b:v', bitrate, '-profile:v', 'high', '-level', '5.1', '-rc', 'vbr', '-tune', 'hq', '-rc-lookahead', '16', '-b_ref_mode', 'middle', out_name])
