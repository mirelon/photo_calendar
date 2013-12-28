for i in `ls *-*-*.*`; do mv $i `echo $i | sed -e "s/\([0-9]*\)-\([0-9]*\)/\2-\1/g"`; done
