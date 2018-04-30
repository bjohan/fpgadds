TARGET = axis_tb
SRC = $(wildcard *.vhd) $(wildcard *.vhdl)


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

