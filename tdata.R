read_one_file = function(fn) {
  lines=readLines(fn)
  fields=gsub("(.*?):.*", "\\1", lines, perl=T)
  values=gsub(".*?: *(.*)", "\\1", lines, perl=T)
  names(values)=fields
  as.data.frame(as.list(values),stringsAsFactors=F)
}

library(data.table)
parse_logs = function(root) {
  logfiles=Sys.glob(paste0(root,"/*/*.log"))
  rows=lapply(logfiles, read_one_file)
  ## fn=logfiles[[1]]
  ## d=read_one_file(fn)
  tetris=rbindlist(rows,fill=T)
  nrs=c("Time","Paused","Score","Rotations","Drops","Right.trans","Left.trans","Paused","Average.height","Alert.level.before","Alert.level.after","Time","Level");
  lapply(nrs, function(r) { tetris[[r]] <<- as.numeric(tetris[[r]]) })
  fcts=c("Thought.wifi.mode.was","Wifi.mode");
  lapply(fcts, function(r) { tetris[[r]] <<- as.factor(tetris[[r]]) })
tetris$Stats.timestamp = as.POSIXct( tetris$Stats.timestamp)
  tetris
}

if(!exists("tetris")) {
#  tetris = parse_logs("data-2020-04-09")
  tetris = parse_logs("~/.tetris-wifi/")
}

if(0) {
  summary(lm(tetris$Score ~ tetris$Wifi.mode))
  # 0.349
}
if(0) {
  # subtract smoothed score
#  smscore=smooth.spline((tetris$Stats.timestamp),tetris$Score, cv=F,spar=0.8)
  smscore=smooth.spline((tetris$Stats.timestamp),tetris$Score, cv=T)
  if(0) {
    plot((tetris$Stats.timestamp),tetris$Score,type="l")
    lines(smscore,col="red")
  }
  print(summary(lm(tetris$Score - smscore$y ~ tetris$Wifi.mode)))
  # 0.743
}
# time difference in minutes
tetris$Delay= c(NA,tail(tetris$Stats.timestamp,-1)-head(tetris$Stats.timestamp,-1))
tetris$Prev.mode= unlist(list(tetris$Wifi.mode[1],head(tetris$Wifi.mode,-1)))
if(0) {
  maxdel=40
  dtet=tetris[(tetris$Delay>maxdel) & (tetris$Delay < Inf)]
  # print(summary(lm(dtet$Score ~ dtet$Wifi.mode)))
  # 0.297
  print(summary(lm(as.numeric(dtet$Thought.wifi.mode.was) ~ dtet$Wifi.mode)))
  # 0.697
  # 0.966 NE 12 Apr 2020
}
if(0) {
  print(summary(lm(tetris$Alert.level.after ~ tetris$Wifi.mode)))
  # 0.0482
  print(summary(lm((tetris$Alert.level.before-tetris$Alert.level.after) ~ tetris$Wifi.mode)))
  # 0.06665
  print(summary(lm(as.numeric(tetris$Thought.wifi.mode.was) ~ tetris$Wifi.mode)))
  # 0.469
}

if(0) {
  # see if I was better at guessing the mode after being in sauna
  stet=tetris[grep("post.*sauna",tetris$Comments.before.start),]
  print(summary(lm(as.numeric(stet$Thought.wifi.mode.was) ~ stet$Wifi.mode)))
  # 0.896069
}

plot_on_off = function(tet, tcol, ...) {
  
  tet=tet[!is.na(tet[[tcol]]),]
  t_on = tet[tet$Wifi.mode=="pulse"]
  t_off = tet[tet$Wifi.mode=="none"]
  plot((t_on$Stats.timestamp),t_on[[tcol]],type="l",main=tcol, ...)
  lines((t_off$Stats.timestamp),t_off[[tcol]],col="red")

  smtcol=smooth.spline(tet$Stats.timestamp,tet[[tcol]], cv=T)
  lines(smtcol,col="blue")
  print(summary(lm(tet[[tcol]] - smtcol$y ~ tet$Wifi.mode)))
  legend("topleft",col=c("black","red"),lty=1,legend=c("pulse","none"))
}

if(0) {
  plot_on_off(tetris, "Score")
}

tetris$Drop.rate=tetris$Drops/tetris$Time
tetris$Key.rate=(tetris$Drops+tetris$Left.trans+tetris$Right.trans+tetris$Rotations)/tetris$Time
#plot_on_off(tetris, "Drop.rate")
if(0) {
  plot_on_off(tetris, "Alert.level.before")
  dev.new()
  plot_on_off(tetris, "Alert.level.after")
}

NONE=factor("none",levels=c("none","pulse"))
PULSE=factor("pulse",levels=c("none","pulse"))
ctet = tetris[(tetris$Delay>30 | tetris$Prev.mode==NONE),]
ctet = tail(ctet,-1)
if(0) {
#  print(summary(lm(as.numeric(ctet$Thought.wifi.mode.was) ~ ctet$Wifi.mode)))
#  plot_on_off(ctet, "Score")
#  plot_on_off(ctet, "Drop.rate")
#  plot_on_off(ctet, "Key.rate") # signif after 118 games
#  plot_on_off(ctet, "Average.height")
#    plot_on_off(ctet, "Alert.level.after") # 0.971
}

if(0) {
#  ctet = tail(ctet,-1)
  plot_on_off(ctet, "Key.rate") # 0.984 after 118 games
  print(summary(lm(as.numeric(ctet$Thought.wifi.mode.was) ~ ctet$Wifi.mode)))
  print(summary(lm(as.numeric(tetris$Thought.wifi.mode.was) ~ tetris$Wifi.mode)))
}

if(0) {
  print(summary(glm(Wifi.mode ~ Score + Alert.level.after + Drop.rate + Thought.wifi.mode.was, data=tetris, family=binomial())))
  # after 123 games:
  ##   Coefficients:                
  ##                              Estimate Std. Error z value Pr(>|z|)
  ## (Intercept)                -9.3463091  4.5486044  -2.055   0.0399 *
  ## Score                      -0.0002578  0.0001365  -1.888   0.0590 .
  ## Alert.level.after           0.6970586  0.3134381   2.224   0.0262 *
  ## Drop.rate                   9.7151884  7.4707441   1.300   0.1935
  ## Thought.wifi.mode.waspulse  0.3714515  0.3788009   0.981   0.3268
}

if(0) {
  print(summary(glm(Wifi.mode ~  Thought.wifi.mode.was * Time, data=tetris, family=binomial())))
# (Intercept)                      0.0079033  0.6466686   0.012    0.990
  # what does this mean?
 mod= glm(Wifi.mode ~  Thought.wifi.mode.was * Time, data=tetris, family=binomial())
 d=cbind(tetris$Wifi.mode, (predict(mod,tetris)>0)+1)
 sum(d[,1]==d[,2])
## [1] 75
 nrow(d)
## [1] 135
pbinom(sum(d[,1]==d[,2]),nrow(d),0.5)
## [1] 0.9158704
}

if(1) {
  plot_on_off(tetris[1:53,],"Score")
  dev.new()
  plot_on_off(tetris, "Score")
}
