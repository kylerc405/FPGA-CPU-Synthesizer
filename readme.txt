1. No revisions were made after the in-class presentation

2. Modifications were made to top.sv, memIO.sv, memory_mapper.sv, and sound.sv files. This was basically wiring up 12 more sound registers located in the addresses above the LED, and connecting them to 12 more sound generators and passing the audio through a sound mixer MUX that cycled quickly between them all. In each sound generator is a phase counter, a PWM counter, a waveform selector based on accelX, and a volume scaler based on accelY that scales either the saw or square wave (triangle wave never ended up being completed and functioning). 


