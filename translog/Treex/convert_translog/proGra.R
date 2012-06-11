### in postscript umlenken
# postscript("FILENAME.eps", onefile=FALSE, height=3, width=12, pointsize=1)

ReadData <- function(fn, sw = '---') {
  cat("Reading Fixation Units:", fn,".fu\n");
  FU       <<- read.table(paste(fn,".fu",sep=""), header = TRUE, encoding="UTF-8")
  cat("Reading Production Units:", fn,".pu\n");
  PU       <<- read.table(paste(fn,".pu",sep=""), header = TRUE, encoding="UTF-8")
  cat("Reading Keyboard data:", fn,".kd\n");
  Keys     <<- read.table(paste(fn,".kd",sep=""), header = TRUE, encoding="UTF-8")
  cat("Reading Fixation data:", fn,".fd\n");
  Fixes    <<- read.table(paste(fn,".fd",sep=""), header = TRUE, encoding="UTF-8")

#cat("FU:", FU$fixes, "\n");

  if(sw == '---') {
    cat("Reading Source Text:", fn,".st\n");
    Source <<- read.table(paste(fn,".st",sep=""), header = TRUE)
  }
  else { Source   <<- read.table(sw, header = TRUE) }
  FileName <<- fn;

  s2 <<- as.numeric()
  for (i in 0:length(Keys$sid)) {
    s2[i] <<- as.integer(unlist(strsplit(as.character(Keys$sid[i]), "\\+"))[[1]]);
  }
  Keys$sid <<- s2;
}


ProgGraph <- function(X1=0, X2=0, Y1=0, Y2=0, fix=1, pu=0, fu=0, CK=0) {

  if(length(Fixes$n) == 0) {
    cat("Fixation table emty: cannot plot fixations\n");
    fix=0;
  }
  if(length(FU$n) == 0) {
    cat("Fixation units table emty: cannot plot fixation units\n");
    fu=0;
  }
  if(length(PU$n) == 0) {
    cat("Production units table emty: cannot plot production units\n");
    pu=0;
  }

## CK: only classified keystrokes

  if(X1 > X2) { cat( "X1 must be smaller than or equal to X2\n"); return; }
  if(Y1 > Y2) { cat( "Y1 must be smaller than or equal to Y2\n"); return; }
  if(Y1 == Y2) {
    if(X1 == X2){Y1=0;Y2 = length(Source[,2]);}
    else {
      for (i in 1:length(Keys$n)) {
        if(Keys$time[i] < X1 || Keys$time[i] > X2 ) {next;}
        if(Keys$sid[i] < 0 && CK == 1) {next;}
        if(Y2 == Y1){ Y1 <- Keys$sid[i];Y2 <- Keys$sid[i]+1; next;}
        if(Y1 > Keys$sid[i]) {Y1 <- Keys$sid[i];}
        if(Y2 < Keys$sid[i]) {Y2 <- Keys$sid[i];}
  } } }
  if(X1 == X2){
    for (i in 1:length(Keys$n)) {
#cat( "KEY", i, length(Keys$n), "\n");
      if(Keys$sid[i] < Y1 || Keys$sid[i] > Y2 ) {next;}
      if(X2 == X1){ X1 <- Keys$time[i];X2 <- Keys$time[i]+1; next;}
      if(X1 > Keys$time[i]) {X1 <- Keys$time[i];}
      if(X2 < Keys$time[i]) {X2 <- Keys$time[i];}
#if(i > 10 ) {break;}
    }
    if(fix) {
      for (i in 1:length(Fixes$n)) {
        if(Fixes$sid[i] > Y2 || Fixes$sid[i] < Y1) {next;}
        if(X1 > Fixes$time[i]) {X1 <- Fixes$time[i];}
        if(X2 < Fixes$time[i]) {X2 <- Fixes$time[i]; }
    } }
  }
 
# color insertions/deletions
  kt  <-  c(); 
  for (i in 1:length(Keys$type)) {
    if(Keys$type[i] == "ins") {kt[i] <- 1;}
    else {kt[i] <- 2;}
  }

# color source/target fixations 
  ft  <-  c();
  if(fix) {
    for (i in 1:length(Fixes$win)) {
      if(Fixes$win[i] == "1") {ft[i] <- 4;}
      else {ft[i] <- 3;}
    }
  }

#cat( "XXX", Y2-Y1, pu, fu, fix);
  par(mai=c(0.8,1.2,0.3,0.3))

  xlab  <-  paste("Translation Progression Graph " , FileName , "Translation time ", X1, " to ", X2, " (in ms)");
  ylab  <-  paste("Source Text", Y1, "to" , Y2);

# Mit Zahlen an der  Y-achse
  plot(Keys$time,Keys$sid,mgp=c(7,0.6,0),lab=c(25,10,2),type="n",xlab=xlab,ylab=ylab,xlim=c(X1,X2),ylim=c(Y1,Y2))
#  plot(s3,s2,mgp=c(7,0.6,0),lab=c(25,10,2),type="n",xlab=xlab,ylab=ylab,xlim=c(X1,X2),ylim=c(Y1,Y2))
  axis(2,at=Source[,1],labels=Source[,2],las=1,mgp=c(10,2.0,0),tck=0.01)

  text(Keys$time,Keys$sid,as.character(Keys$chr),cex=1.0,col=kt,font=kt);
  if(fix) { points(Fixes$time, Fixes$sid, type="b", col=ft); }

## Polygon Processing Units
  if(pu) { 
    PUx  <-  c(); 
    PUy  <-  c(); 
    for (i in 1:length(PU$start)) { 
      if(PU$start[i] > X2) {break;}
      if(PU$start[i]+PU$dur[i] < X1) {next}
  ## update X2 for last FU overlapping PU
      if(PU$start[i]+PU$dur[i] > X2) {X2 = PU$start[i]+PU$dur[i];}
      PUx=append(PUx,PU$start[i]); 
      PUx=append(PUx,PU$start[i]); 
      PUx=append(PUx,PU$start[i]+PU$dur[i]); 
      PUx=append(PUx,PU$start[i]+PU$dur[i])
      PUx=append(PUx,NA);

      max <- 0;
      min <- 1000;
      S <- c();
      S <- unlist(strsplit(as.character(PU$sid[i]), "\\+"));
      for (k in 1:length(S)) {
        if(as.integer(S[[k]]) > max) { max <- as.integer(S[[k]]);};
        if(as.integer(S[[k]]) < min) { min <- as.integer(S[[k]]);};
      }
      if(min >= 1) {min <- min -1};
      max <- max +1;
      PUy = append(PUy, min);
      PUy = append(PUy, max);
      PUy = append(PUy, max);
      PUy = append(PUy, min);
      PUy = append(PUy, NA);
#cat( "AA2 min:", min, "max:", max, "\n");
##############
    }
    polygon(PUx,PUy,density=5,angle=0,lty=1,col=2,lwd=0.4); 
#    polygon(PUx,rep(c(Y1,Y2,Y2,Y1,NA),length(PUx)/5),density=5,angle=0,lty=1,col=2,lwd=0.4); 
  }

  mar=(Y2-Y1)/20;
## Polygon Fixation Units
  if(fu) {
    FUx <- c(); 
    FUy <- c();
    FUc <- c(); 
    FUw <- c(); 
    col <- 5; 
    j <- 1;
    for (i in 1:length(FU$start)) {
      if(FU$start[i] > X2) {break;}
      if(FU$start[i]+FU$dur[i] < X1) {next}
      FUx=append(FUx,FU$start[i]-100); 
      FUx=append(FUx,FU$start[i]-100); 
      FUx=append(FUx,FU$start[i]+FU$dur[i]); 
      FUx=append(FUx,FU$start[i]+FU$dur[i])
      FUx=append(FUx,NA);

      max <- 0;
      min <- 1000;
      S <- c();
      S <- unlist(strsplit(as.character(FU$fixes[i]), "\\+"));
      for (k in 1:length(S)) {
        if(as.integer(S[[k]]) > max) { max <- as.integer(S[[k]]);};
        if(as.integer(S[[k]]) < min) { min <- as.integer(S[[k]]);};
      }
      if(min >= 1) {min <- min -1};
      max <- max +1;
      FUy = append(FUy, min);
      FUy = append(FUy, max);
      FUy = append(FUy, max);
      FUy = append(FUy, min);
      FUy = append(FUy, NA);
#cat( "AA2 min:", min, "max:", max, "\n");
      
      if(FU$win[i] == 1) {FUw[j] <- -50; FUc[j] <- 4;}
      else {FUw[j] <- 50; FUc[j] <- 3;}
      j <- j+1;
    }
    polygon(FUx,FUy,density=5,angle=FUw,lty=1,col=FUc,lwd=0.6);
#    polygon(FUx,rep(c(Y1+mar,Y2-mar,Y2-mar,Y1+mar,NA),length(FUx)/5),density=5,angle=FUw,lty=1,col=FUc,lwd=0.6);
  }
}


####################################################

PlotXYData <- function(X1=0, X2=0, Y1=0, Y2=0, CK=1) {

  if(X1 > X2) { cat( "X1 must be smaller than or equal to X2\n"); return; }
  if(Y1 > Y2) { cat( "Y1 must be smaller than or equal to Y2\n"); return; }
  if(Y1 == Y2) {
    if(X1 == X2){Y1=1;Y2 = length(Source[,2]);}
    else {
      for (f in files[,1]) {
        Ksrc <<- MUL[[f]]$kd$sid;
        Koff <<- MUL[[f]]$kd$off;

#cat("A X1:", X1, "X2:", X2, "Y1:", Y1, "Y2:", Y2, f, "\n")
        for (i in 1:length(Koff)) {
          if(Koff[i] < X1 || Koff[i] > X2 ) {next;}
          if(Ksrc[i] < 0 && CK == 1) {next;}
          if(Y2 == Y1){ Y1 <- Ksrc[i];Y2 <- Ksrc[i]+1; next;}
          if(Y1 > Ksrc[i]) {Y1 <- Ksrc[i];}
          if(Y2 < Ksrc[i]) {Y2 <- Ksrc[i];}
  } } } }
  if(X1 == X2){
    for (f in files[,1]) {
      Ksrc <<- MUL[[f]]$kd$sid;
      Koff <<- MUL[[f]]$kd$off;
      Fsrc <<- MUL[[f]]$fd$src;
      Foff <<- MUL[[f]]$fd$off;

#cat(f, "C X1:", X1, "X2:", X2, "Y1:", Y1, "Y2:", Y2, "len:", length(Ksrc), "\n")
      for (i in 1:length(Ksrc)) {
#cat(i, "Y1:", Y1, "Y2:", Y2, "len:", length(Ksrc), "\n")
        if(Ksrc[i] < Y1 || Ksrc[i] > Y2 ) {next;}
        if(X2 == X1){ X1 <- Koff[i]; X2 <- Koff[i]+1; next;}
        if(X1 > Koff[i]) {X1 <- Koff[i];}
        if(X2 < Koff[i]) {X2 <- Koff[i];}
      }
      for (i in 1:length(Fsrc)) {
        if(Fsrc[i] > Y2 || Fsrc[i] < Y1) {next;}
        if(X1 > Foff[i]) {X1 <- Foff[i];}
        if(X2 < Foff[i]) {X2 <- Foff[i]; }
      }
    }
  }
 
#cat("3 X1:", X1, "X2:", X2, "Y1:", Y1, "Y2:", Y2, "\n")

  Foff <<- MUL[[1]]$fd$off;
  Fsrc <<- MUL[[1]]$fd$sid;

  par(mai=c(0.8,1.2,0.3,0.3))
  plot(Foff,Fsrc,mgp=c(7,0.6,0),lab=c(20,10,2),type="n",xlim=c(X1,X2),ylim=c(Y1,Y2))
  axis(2,at=Source[,1],labels=Source[,2],las=1,mgp=c(10,2.0,0),tck=0.01)

  for (f in files[,1]) {
#cat(f, "Y1:", Y1, "Y2:", Y2, "\n")

    Koff <<- MUL[[f]]$kd$off;
    Ksrc <<- MUL[[f]]$kd$sid;
    Kchr <<- MUL[[f]]$kd$chr;
    Ktyp <<- MUL[[f]]$kd$type;
    Foff <<- MUL[[f]]$fd$off;
    Fsrc <<- MUL[[f]]$fd$sid;

# color insertions & deletions
    kt  <-  c(); 
    for (i in 1:length(Ktyp)) {
      if(Ktyp[i] == "ins") {kt[i] <- 1;}
      else {kt[i] <- 2;}
    }
#cat("6 X1:", X1, "X2:", X2, "Y1:", Y1, "Y2:", Y2, f, "\n")
    text(Koff,Ksrc,as.character(Kchr),cex=1.0,col=kt,font=kt)
    points(Foff,Fsrc,pch=20,type="p",col=4)
#return(0);
  }
}

