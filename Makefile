build:
	gprbuild -P tree.gpr -p

spark:
	gnatprove -P tree.gpr
