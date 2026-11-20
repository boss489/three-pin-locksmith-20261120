import wave, math, struct, random, os
base = os.path.join(os.path.dirname(__file__), 'assets')
for name, duration, notes in [('tick', .08, [520]), ('buzz', .22, [170,151]), ('chime', .65, [392,523,659])]:
    rate = 22050
    random.seed(19)
    samples = []
    for i in range(int(rate*duration)):
        t = i/rate
        env = (1-t/duration)**2 * min(1,t*300)
        if name == 'chime': value = sum(math.sin(2*math.pi*f*t)*.25 for f in notes)
        elif name == 'tick': value = (random.random()*2-1)*.25 + math.sin(2*math.pi*notes[0]*t)*.4
        else: value = sum(math.sin(2*math.pi*f*t)*.22 for f in notes)
        samples.append(struct.pack('<h',int(max(-1,min(1,value*env))*22000)))
    with wave.open(os.path.join(base,name+'.wav'),'wb') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(rate)
        w.writeframes(b''.join(samples))
