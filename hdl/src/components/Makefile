TARGET = tb
SRC = $(wildcard *.vhd) $(wildcard *.vhdl)


view:$(TARGET).vcd
	gtkwave $(TARGET).vcd wave.gtkw

$(TARGET).vcd: $(TARGET)
	./$(TARGET) --vcd=$(TARGET).vcd

$(TARGET): work-obj93.cf
	ghdl -e $(TARGET)

work-obj93.cf: $(SRC)
	ghdl -a $(SRC)

clean:
	rm *.o
	rm work-obj93.cf
	rm $(TARGET)
	rm $(TARGET).vcd

