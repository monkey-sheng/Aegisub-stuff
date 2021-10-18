from os import listdir
from subprocess import run
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
f_out = '【已压】' + video
out_name = os.path.join(os.path.expanduser('~'), 'Desktop', f_out)
print(out_name)
run(['ffmpeg', '-i', video, '-pix_fmt', 'yuv420p', '-vf',
     f'subtitles={ass}', '-c:a', 'copy', '-profile:v', 'high', '-level', '5.0', '-crf', 19, out_name])
