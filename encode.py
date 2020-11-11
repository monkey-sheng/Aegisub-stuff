import json
from subprocess import run, PIPE
from os import listdir
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
bitrate = str(int(int(info['streams'][0]['bit_rate']) / 1000) + 100) + 'k'
f_out = '【已压】' + video
out_name = os.path.join(os.path.expanduser('~'), 'Desktop', f_out)
avs_content = r'LoadPlugin("C:\Program Files\aegisub-3.2.2-portable-32\csri\VSFilterMod.dll")' + 'DirectShowSource("' + video + '")' + 'TextSubMod(file="' + ass + '")'
avs = open('encode.avs', 'w')
avs.write(avs_content)
avs.close()

run([
    'ffmpeg', '-i', 'encode.avs', '-pix_fmt', 'yuv420p', '-preset', 'slow',
    '-b:v', bitrate, out_name
],
    shell=True)
