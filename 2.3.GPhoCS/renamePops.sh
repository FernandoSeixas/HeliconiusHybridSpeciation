
## rename pop names - some populations from the same region have different names 
## but actually are genetically homogeneous

file=$1

# rename individuals
sed -i 's,Helebvcbra001,Helerurbra003,g' $file  ## Group.1
sed -i 's,Helesfyven005,Heleauyven004,g' $file  ## Group.1
sed -i 's,Heleautbra001,Helecarbra002,g' $file  ## P7.1
sed -i 's,Heleautbra002,Helecarbra003,g' $file  ## P7.1

sed -i 's,Hlucrorbra001,Hluctrabra003,g' $file  ## luciana
sed -i 's,Hlucvnvbra001,Hluctrabra004,g' $file  ## luciana
#sed -i 's,Hluccarbra001,Hluctrabra005,g' $file  ## luciana
#sed -i 's,Hluccarbra002,Hluctrabra006,g' $file  ## luciana
#sed -i 's,Hluccarbra003,Hluctrabra007,g' $file  ## luciana
#sed -i 's,Hluccarbra004,Hluctrabra008,g' $file  ## luciana
#sed -i 's,Hluccarbra005,Hluctrabra009,g' $file  ## luciana
#sed -i 's,Hluccarbra006,Hluctrabra010,g' $file  ## luciana
#sed -i 's,Hluccarbra007,Hluctrabra011,g' $file  ## luciana

# rename populations
#sed -i 's,Heleautbra,Helecarbra,g' $file  ## P7.1
#sed -i 's,Helesfyven,Heleauyven,g' $file  ## Group.1
#sed -i 's,Helebvcbra,Helerurbra,g' $file  ## Group.1
#sed -i 's,Hlucrorbra,Hluctrabra,g' $file  ## luciana
#sed -i 's,Hlucvnvbra,Hluctrabra,g' $file  ## luciana
#sed -i 's,Hluccarbra,Hluctrabra,g' $file  ## luciana

