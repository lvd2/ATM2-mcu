TARGET = ../bin/at_mcs52.hex
BIN = ../bin/at_mcs52.bin


.PHONY: clean



all: $(TARGET) $(BIN)

bin: $(BIN)

.PRECIOUS: at_mcs52.p

at_mcs52.p: *.asm
	asl -L at_mcs52.asm

$(TARGET): at_mcs52.p
	p2hex   $< $@

$(BIN): at_mcs52.p
	p2bin   $< $@

#pgm: $(TARGET)
#	avrdude -c usbasp -p at89s52 -B 5 -U flash:w:$(TARGET):i

clean:
	rm *.p *.lst $(TARGET) $(BIN)

