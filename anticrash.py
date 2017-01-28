import socket
import importlib
import threading
import string
import time
import random
import subprocess
import os
import pwd
import datetime
import re
import psutil
import sys
import signal
from termcolor import colored


__author__ = "Allen - @Dragon_Born"
"""
Anticrash script for telegram_cli
Special thanks to:
@imandaneshi
@siyanew
@it_s_me
and everyone who helped me for this project
"""
config = importlib.import_module("config")
data = {}
	
class Anticrash(object):

  try:
    def check_bot(self, botname, port, path, user):
        bot = botname
		
        if not botname in data:

            addlog('starting '+ botname)
            os.chdir(path)
            proc = subprocess.Popen('screen -dmS "'+ botname +'" su '+ user +' -c "bash launch.sh -P '+ str(port) +'"',shell=True).wait()
            addlog(botname + ' has been successfully started')
            print(colored(botname + ' has been successfully started\n',"blue"))
            spid = screen_pid(botname)
            data[botname] = {"pid": spid}
            time.sleep(5)
						
        while True:
            try:
			
                s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                s.settimeout(5.0)
                s.connect(('localhost', int(port)))
                s.shutdown(socket.SHUT_WR)
                s.close()
            except:
                try:				
                    os.kill(int(data[botname][pid]), 9)
                except Exception as e:
                 a = 'a'
                wipe = subprocess.Popen(["screen", "-wipe"], stdout=subprocess.PIPE)
                del data[botname]
                addlog(botname + ' was crashed and it has been successfully restarted.')
                print(botname + ' was crashed and it has been successfully restarted.')
                botname = bot+get_random_key(2)
				
                proc = subprocess.Popen('screen -dmS "'+ botname +'" su '+ user +' -c "bash launch.sh -P '+ str(port) +'"',shell=True).wait()
                spid = screen_pid(botname)
                data[botname] = {"pid": spid}

            time.sleep(15)

    def __init__(self, interval=5):
        now = datetime.datetime.now()
        now = now.strftime("%H:%M")
        f = open('log.txt','a')
        f.write('\n\n\n------------------------------\n' + now + ': Anticrash script started\n------------------------------\n')
        f.close()
        self.interval = interval
        for x in config.bots:
		
            thread = threading.Thread(target = self.check_bot, args=(x, config.bots[x][0], config.bots[x][1], config.bots[x][2]))
            thread.start()
            print(colored('starting '+ x +'...',"blue"))
            time.sleep(self.interval)
  except Exception as e:
        print('Error: ' + e)
	  
def signal_handler(signal, frame):
        print('stopping script')
        os.setuid(0)
        for x in data:
            try:
                os.kill(int(data[x]['pid']), 9)
                print('killing ' + x)
            except:
                pid_not_found = True
        print("Byebye...")
        f = open('.proc','w+')
        f.write('0')
        f.close()
        wipe = subprocess.Popen(["screen", "-wipe"], stdout=subprocess.PIPE)
        os.kill(os.getpid(), 9)
		
def addlog(text):
        now = datetime.datetime.now()
        time = now.strftime("%Y-%m-%d %H:%M")
        f = open('log.txt','a')
        f.write(time + ' : ' + text + '\n')
        f.close()

def lastpid():
   try:
    lastpid = open('.proc', 'rb').read()
   except:
    print('injas')
    f = open('.proc','w')
    f.write(str(os.getpid()))
    f.close()
    lastpid = open('.proc', 'rb').read()
   return int(lastpid)
   
def get_random_key(strlen):
    return ''.join(random.choice(string.hexdigits) for x in range(strlen))

	
def screen_pid(name):
    ph = subprocess.Popen(["screen", "-ls"], stdout=subprocess.PIPE)
    (stdout,stderr) = ph.communicate()
    try:
        stdout = stdout.decode("utf-8")
    except:
        stdout = stdout
    matches = re.search(r'(\d+).%s' % name, stdout , re.MULTILINE)
    if(matches): 
        pids = matches.groups()
        if(len(pids) == 1): return int(pids[0])
        else: raise Exception("Multiple matching PIDs found: %s" % pids)
    raise Exception("No matching PIDs found")
	
	
signal.signal(signal.SIGTERM, signal_handler)
signal.signal(signal.SIGINT, signal_handler)


try:
 try:
  sys.argv[1]
  argv = True
 except:  
  argv = False
 if argv == True:
    argv = sys.argv[1]
    if argv == 'start':
        if lastpid() != 0:
            try:
                print('killing last session...')
                os.kill(lastpid(),15)
                wipe = subprocess.Popen(["screen", "-wipe"], stdout=subprocess.PIPE)
            except:
                print('The script was not running.\n')
        f = open('.proc','w')
        f.write(str(os.getpid()))
        f.close()
        print(colored('Starting anticrash script\n',"red"))
        run_anticrash = Anticrash()
        print(colored('\nAll Bots successfully started',"green"))
        time.sleep(0.2)
    elif argv == 'stop':
        if lastpid() != 0:
            try:
                print('killing last session...')
                os.kill(lastpid(),15)
                wipe = subprocess.Popen(["screen", "-wipe"], stdout=subprocess.PIPE)
            except:
                print('The script was not running...')
            print("Byebye...")
            f = open('.proc','w+')
            f.write('0')
            f.close()
        else:
            print('The script was not running.\n')
    else:
        print('Usage: python3 anticrash.py {start|stop}\n')   
        quit()
 else: 
    print('Usage: python3 anticrash.py {start|stop}\n')
    quit()
except KeyboardInterrupt:
 quit()
