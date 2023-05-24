#! /usr/bin/env python
# -*- coding: utf-8 -*-
import sys

def convert_bin_to_mem(bin_file, mem_file):
    try:
        with open(bin_file, 'rb') as f_in, open(mem_file, 'w') as f_out:
            byte_count = 0
            byte_buffer = []
            for byte in f_in.read():
                byte_buffer.append(format(ord(byte), '02X'))
                byte_count += 1
                if byte_count == 4:
                    f_out.write(''.join(byte_buffer) + '\n')
                    byte_count = 0
                    byte_buffer = []

            if byte_count > 0:
                f_out.write(''.join(byte_buffer) + '\n')

        print("Conversion successful!")

    except IOError as e:
        print("I/O error({0}): {1}".format(e.errno, e.strerror))

    except:
        print("Unexpected error:", sys.exc_info()[0])

# 请在下面修改输入和输出文件的路径
bin_file_path = 'inst_rom.bin'
mem_file_path = 'inst_rom.mem'

convert_bin_to_mem(bin_file_path, mem_file_path)
