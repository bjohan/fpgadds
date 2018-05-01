TARGET = axis_tb
SRC = $(wildcard component_*.vhd) $(wildcard component_*.vhdl) $(wildcard *_tb.vhdl) $(wildcard *_tb.vhd)


view:$(TARGET).fst
	gtkwave $(TARGET).fst wave.gtkw

$(TARGET).fst: $(TARGET)
	./$(TARGET) --fst=$(TARGET).fst --stop-time=30us

$(TARGET): work-obj93.cf
	ghdl -e $(TARGET)

work-obj93.cf: $(SRC)
	ghdl -a $(SRC)

clean:
	rm *.o
	rm work-obj93.cf
	rm $(TARGET)
	rm $(TARGET).vcd

