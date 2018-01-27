#!/usr/bin/python3
# -*- coding: utf-8 -*-
from PIL import Image
import os.path
import json


def make_sprite_img(im, x,y, width, height):
    box = (x, y, x+width, y+height)
    a = im.crop(box)
    return a


def theslicer(Path, jsonfile, input):
    im = Image.open(input)
   
    json_file = open(jsonfile)
    json_str = json_file.read()
    json_data = json.loads(json_str)

    print(json_data)

    slices = json_data['meta']['slices']

    k = 0
    for slice in slices:
      k = k + 1
      print('')
      print(slice)

      t_x = slice['keys'][0]['bounds']['x']
      t_y = slice['keys'][0]['bounds']['y']
      t_w = slice['keys'][0]['bounds']['w']
      t_h = slice['keys'][0]['bounds']['h']
      t_name = slice['name']
      sprite_to_save = make_sprite_img(im,t_x,t_y,t_w,t_h)
      sprite_to_save.save(os.path.join(Path, "{0}_{1:03d}_{2}.png".format("sprite",k,t_name)))
           


            
theslicer("OUTPUT_FOLDER","atlas01.json","../../project/img/atlas01.png")
