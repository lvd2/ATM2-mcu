TARGET = at32.hex
BIN = at32.bin


.PHONY: clean



all: $(TARGET) $(BIN)

bin: $(BIN)

.PRECIOUS: at32.p

at32.p: *.asm
	asl -L at32.asm

$(TARGET): at32.p
	p2hex -r '$$-$$' $< $@

$(BIN): at32.p
	p2bin -r '$$-$$' $< $@

#pgm: $(TARGET)
#	avrdude -c usbasp -p at89s52 -B 5 -U flash:w:$(TARGET):i

clean:
	rm *.p *.lst $(TARGET) $(BIN)
