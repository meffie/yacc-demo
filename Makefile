all:
	cd calc1 && $(MAKE)
	cd calc2 && $(MAKE)
	cd calc3 && $(MAKE)

clean:
	cd calc1 && $(MAKE) clean
	cd calc2 && $(MAKE) clean
	cd calc3 && $(MAKE) clean
