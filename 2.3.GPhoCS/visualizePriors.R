require(invgamma)
options(scipen = 999)

mu = 2.9*(10^-9)
gn = 0.25


##### Ne ///////////////////////////////////////////////////////////////////////
x = rgamma(n = 1000000, shape = 2, rate = 100)
y = rgamma(n = 1000000, shape = 0.009, rate = 0.5)
o = rgamma(n = 1000000, shape = 1, rate = 20)
z = rinvgamma(n = 1000000, shape = 3, rate = 0.04)
yScale = y / (4*mu)
xScale = x / (4*mu)
oScale = o / (4*mu)
zScale = z / (4*mu)
plot(density(zScale), xlim=c(0,2*(10^7)), col="purple")
lines(density(xScale), xlim=c(0,2*(10^7)), col="blue")
lines(density(yScale), xlim=c(0,2*(10^7)), col="orange")
lines(density(oScale), xlim=c(0,2*(10^7)), col="red")
abline(v = 10000)
abline(v = 100000)
abline(v = 500000)
abline(v = 1000000)
abline(v = 4000000)
plot(density(xScale), xlim=c(0,2*(10^7)), col="blue")


plot(density(yScale), col="orange")

##### Time of divergence ///////////////////////////////////////////////////////
round(2/100/mu*gn/1000000, digits = 1)
round(2/10/mu*gn/1000000, digits = 1)
# distribution
x = rgamma(n = 1000000, shape = 2, rate = 100)
y = rgamma(n = 1000000, shape = 1, rate = 100)
o = rgamma(n = 1000000, shape = 1, rate = 10)
z = rinvgamma(n = 1000000, shape = 3, rate = 0.06)
# rescale
zTscale = z / mu * gn
yTscale = y / mu * gn 
xTscale = x / mu * gn 
oTscale = o / mu * gn 
# plot
# plot(density(zTscale), xlim=c(0,1*(10^7)), col="purple")
plot(density(xTscale), xlim=c(0,1*(10^7)), col="blue")
lines(density(yTscale), xlim=c(0,1*(10^7)), col="orange")
lines(density(oTscale), xlim=c(0,1*(10^7)), col="red")
abline(v = 100000)
abline(v = 500000)
abline(v = 1000000)

x = rgamma(n = 1000000, shape = 2, rate = 50)
xTscale = x / mu * gn 
plot(density(xTscale), xlim=c(0,1*(10^7)), col="blue")
abline(v = 1700000)


##### migration ////////////////////////////////////////////////////////////////
0.002/0.00001* 0.02
0.0005/0.00001*0.02

# prior
x = rgamma(n = 100000, shape = 0.002, rate = 0.00001)
y = rgamma(n = 100000, shape = 0.0005, rate = 0.00001)
z = rbeta(n = 100000, shape1 = 4, shape2 = 2)
# Re-scale (M - proportion of migrants)
xScale = x * mu
yScale = y * mu
zScale = z * mu
# plot
plot(density(xScale), col="red", xlim=c(0,0.001))
plot(density(yScale), col="red", xlim=c(0,0.001))
plot(density(zScale), col="orange", xlim=c(0,0.001))
# Re-scale (migrants/generation)
xScale = x * 0.02
yScale = y * 0.02
zScale = z * 0.02
# plot
plot(density(xScale), col="orange", xlim=c(0,25))
plot(density(yScale), col="red",    xlim=c(0,25))
plot(density(zScale), col="red",    xlim=c(0,0.1))

abline(v = 10000)
abline(v = 100000)
abline(v = 500000)
abline(v = 1000000)

# m_sx
y = rgamma(n = 100000, shape = 0.002, rate = 0.00001)
summary(y)
yScale = y * mu # M_sx (Proportion migrants/generation)
summary(yScale)
yScale = y * 0.02 # Number migrants/generation
summary(yScale)
yScale = y * 0.02 # Number migrants/generation
summary(yScale)

plot(density(yScale), col="blue", xlim=c(0,0.1))
abline(v = 0.001)
abline(v = 0.01)



