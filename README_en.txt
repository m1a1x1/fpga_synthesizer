Project description:
  Using Terasic board DE1-SoC implement sort of synthesizer, which will be able to make
  different sounds. For now, there are still a lot of work to do, but you already can play some
  simple melody.
 
Purpose of the work:
  - Practicing in writing on verilog;
  - Studing, how FPGA interact with different peripheral modules;
  - Practicing in using IP-cores for FPGA;
  - Fun.

For now you can see:
  - 8 jingles, each of ones is an one period of sine but with different frequency;
  - Jingles were made in advance with Python utiliti ROM/py_utl/make_mif.py.
    It create a .mif ( Memory Initialization File ) whitch initialize ROM in FPGA;
  - Volume can be changed realtime with special keys on keyboard;
  - To hear jingle, press keys from 1 to 8 on keyboard.

Known bugs:
  - You can change volume ONLY with spetial keys, which are not on every keyboard.
  - Right after the programing volume on the indicators does not match with real volume;
  - If you press one key and then press another one, the device consider this as you release first key;
  - simmulation does not work;
  - There may be some problems if you change parameters;
  - No tests were done to check if the jingls realy their frequency sine;
