all:
	cd calc1 && $(MAKE)
	cd calc2 && $(MAKE)
	cd calc3 && $(MAKE)
	cd calc4 && $(MAKE)
	cd calc5 && $(MAKE)

clean:
	cd calc1 && $(MAKE) clean
	cd calc2 && $(MAKE) clean
	cd calc3 && $(MAKE) clean
	cd calc4 && $(MAKE) clean
	cd calc5 && $(MAKE) clean
