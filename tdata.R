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
  tetris = parse_logs("data-2020-04-09")
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
if(0) {
  tetris$Delay= c(Inf,tail(tetris$Stats.timestamp,-1)-head(tetris$Stats.timestamp,-1))
  maxdel=40
  dtet=tetris[(tetris$Delay>maxdel) & (tetris$Delay < Inf)]
  # print(summary(lm(dtet$Score ~ dtet$Wifi.mode)))
  # 0.297
  print(summary(lm(as.numeric(dtet$Thought.wifi.mode.was) ~ dtet$Wifi.mode)))
  # 0.697
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
