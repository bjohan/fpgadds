TARGET = axis_tb
SRC = $(wildcard component_*.vhd) $(wildcard component_*.vhdl) $(wildcard *_tb.vhdl) $(wildcard *_tb.vhd)


debug:$(TARGET)
	gdb --args $(TARGET) --wave=$(TARGET).ghw --stop-time=30us

view:$(TARGET).ghw
	gtkwave $(TARGET).ghw wave.gtkw

$(TARGET).ghw: $(TARGET)
	./$(TARGET) --wave=$(TARGET).ghw --stop-time=30us

$(TARGET).fst: $(TARGET)
	./$(TARGET) --fst=$(TARGET).fst --stop-time=30us

$(TARGET): work-obj93.cf
	ghdl -e -g $(TARGET)

work-obj93.cf: $(SRC)
	ghdl -a -g $(SRC)

clean:
	rm *.o
	rm work-obj93.cf
	rm $(TARGET)
	rm $(TARGET).vcd

