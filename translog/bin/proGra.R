### in postscript umlenken
# postscript("FILENAME.eps", onefile=FALSE, height=3, width=12, pointsize=1)
# ProgGraph()
# dev.off()

ReadData <- function(fn, sw = '---') {
  cat("Reading Fixation Units:", fn,".fu\n");
  FU       <<- read.table(paste(fn,".fu",sep=""), header = TRUE, encoding="UTF-8")
  cat("Reading Production Units:", fn,".pu\n");
  PU       <<- read.table(paste(fn,".pu",sep=""), header = TRUE, encoding="UTF-8")
  cat("Reading Keyboard data:", fn,".kd\n");
  Keys     <<- read.table(paste(fn,".kd",sep=""), header = TRUE, encoding="UTF-8")
  cat("Reading Fixation data:", fn,".fd\n");
  Fixes    <<- read.table(paste(fn,".fd",sep=""), header = TRUE, encoding="UTF-8")

#cat("FU:", FU$Path, "\n");

  if(sw == '---') {
    cat("Reading Source Text:", fn,".st\n");
    Source <<- read.table(paste(fn,".st",sep=""), header = TRUE)
  }
  else { Source   <<- read.table(sw, header = TRUE) }
  FileName <<- fn;

  s2 <<- as.numeric()
  for (i in 0:length(Keys$STid)) {
    s2[i] <<- as.integer(unlist(strsplit(as.character(Keys$STid[i]), "\\+"))[[1]]);
  }
  Keys$STid <<- s2;
}


ProgGraph <- function(X1=0, X2=0, Y1=0, Y2=0, fix=1, pu=0, fu=0, CK=0) {

  if(length(Fixes$FIXid) == 0) {
    cat("Fixation table empty: cannot plot fixations\n");
    fix=0;
  }
  if(length(FU$FUid) == 0) {
    cat("Fixation units table empty: cannot plot fixation units\n");
    fu=0;
  }
  if(length(PU$PUid) == 0) {
    cat("Production units table empty: cannot plot production units\n");
    pu=0;
  }

  if(length(Keys$KEYid) == 0) {
    cat("No Key data: cannot plot Graph \n");
    return;
  }

## CK: only classified keystrokes

  if(X1 > X2) { cat( "X1 must be smaller than or equal to X2\n"); return; }
  if(Y1 > Y2) { cat( "Y1 must be smaller than or equal to Y2\n"); return; }
  if(Y1 == Y2) {
    if(X1 == X2){Y1=0;Y2 = length(Source[,2]);}
    else {
      for (i in 1:length(Keys$KEYid)) {
        if(Keys$Time[i] < X1 || Keys$Time[i] > X2 ) {next;}
        if(Keys$STid[i] < 0 && CK == 1) {next;}
        if(Y2 == Y1){ Y1 <- Keys$STid[i];Y2 <- Keys$STid[i]+1; next;}
        if(Y1 > Keys$STid[i]) {Y1 <- Keys$STid[i];}
        if(Y2 < Keys$STid[i]) {Y2 <- Keys$STid[i];}
  } } }
  if(X1 == X2){
    for (i in 1:length(Keys$KEYid)) {
#cat( "KEY", i, length(Keys$KEYid), "X1:", X1, "X2:", X2, "\n");
      if(Keys$STid[i] > 0 && (Keys$STid[i] < Y1 || Keys$STid[i] > Y2 )) {next;}
      if(X2 == X1){ X1 <- Keys$Time[i];X2 <- Keys$Time[i]+1; next;}
      if(X1 > Keys$Time[i]) {X1 <- Keys$Time[i];}
      if(X2 < Keys$Time[i]) {X2 <- Keys$Time[i];}
#if(i > 10 ) {break;}
    }
    if(fix) {
      for (i in 1:length(Fixes$FIXid)) {
        if(Fixes$STid[i] > Y2 || Fixes$STid[i] < Y1) {next;}
        if(X1 > Fixes$Time[i]) {X1 <- Fixes$Time[i];}
        if(X2 < Fixes$Time[i]) {X2 <- Fixes$Time[i]; }
    } }
  }
 
# color insertions/deletions
  kt  <-  c(); 
  for (i in 1:length(Keys$Type)) {
    if(Keys$Type[i] == "ins") {kt[i] <- 1;}
    else {kt[i] <- 2;}
  }

# color source/target fixations 
  ft  <-  c();
  fc  <-  c();
  if(fix) {
    for (i in 1:length(Fixes$Win)) {
      if(Fixes$Win[i] == "1") {ft[i] <- 4; fc[i] = 4;}
      else {ft[i] <- 3; fc[i] = 3;}
    }
  }

#cat( "XXX", Y2-Y1, pu, fu, fix);
  par(mai=c(0.8,1.2,0.3,0.3))

  xlab  <-  paste("Translation Progression Graph " , FileName , "Translation time ", X1, " to ", X2, " (in ms)");
  ylab  <-  paste("Source Text", Y1, "to" , Y2);

# Mit Zahlen an der  Y-achse
  plot(Keys$Time,Keys$STid,mgp=c(7,0.6,0),lab=c(25,10,2),type="n",xlab=xlab,ylab=ylab,xlim=c(X1,X2),ylim=c(Y1,Y2))
#  plot(s3,s2,mgp=c(7,0.6,0),lab=c(25,10,2),type="n",xlab=xlab,ylab=ylab,xlim=c(X1,X2),ylim=c(Y1,Y2))
  axis(2,at=Source[,1],labels=Source[,2],las=1,mgp=c(10,2.0,0),tck=0.01)

  text(Keys$Time,Keys$STid,as.character(Keys$Char),cex=1.0,col=kt,font=kt);
  if(fix) { points(Fixes$Time, Fixes$STid, type="b", pch=fc, col=ft); }

## Polygon Processing Units
  if(pu) { 
    PUx  <-  c(); 
    PUy  <-  c(); 
    for (i in 1:length(PU$Start)) { 
      if(PU$Start[i] > X2) {break;}
      if(PU$Start[i]+PU$Duration[i] < X1) {next}
  ## update X2 for last FU overlapping PU
      if(PU$Start[i]+PU$Duration[i] > X2) {X2 = PU$Start[i]+PU$Duration[i];}
      PUx=append(PUx,PU$Start[i]-100); 
      PUx=append(PUx,PU$Start[i]-100); 
      PUx=append(PUx,PU$Start[i]+PU$Duration[i]+100); 
      PUx=append(PUx,PU$Start[i]+PU$Duration[i]+100)
      PUx=append(PUx,NA);

#      max <- 0;
#      min <- 1000;
#      S <- c();
#      S <- unlist(strsplit(as.character(PU$STid[i]), "\\+"));
#      for (k in 1:length(S)) {
#        if(as.integer(S[[k]]) > max) { max <- as.integer(S[[k]]);};
#        if(as.integer(S[[k]]) < min) { min <- as.integer(S[[k]]);};
#      }
#      if(min >= 1) {min <- min -1};
#      max <- max +1;
#      min <- Y1+5;
#      max <- Y1+15;
      min <- Y1+((Y2-Y1)/6);
      max <- Y2-((Y2 -Y1)/6);
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

## Polygon Fixation Units
  if(fu) {
    FUx <- c(); 
    FUy <- c();
    FUc <- c(); 
    FUw <- c(); 
    col <- 5; 
    j <- 1;
    for (i in 1:length(FU$Start)) {
      if(FU$Start[i] > X2) {break;}
      if(FU$Start[i]+FU$Duration[i] < X1) {next}
      FUx=append(FUx,FU$Start[i]-100); 
      FUx=append(FUx,FU$Start[i]-100); 
      FUx=append(FUx,FU$Start[i]+FU$Duration[i]+100); 
      FUx=append(FUx,FU$Start[i]+FU$Duration[i]+100)
      FUx=append(FUx,NA);

#      max <- 0;
#      min <- 1000;
#      S <- c();
#      S <- unlist(strsplit(as.character(FU$Path[i]), "\\+"));
#      for (k in 1:length(S)) {
#        K <- unlist(strsplit(as.character(S[[k]]), ":"));
#        if(as.integer(K[[2]]) > max) { max <- as.integer(K[[2]]);};
#        if(as.integer(K[[2]]) < min) { min <- as.integer(K[[2]]);};
#      }
#      if(min >= 1) {min <- min -1};
#      max <- max +1;
#      min <- Y1+(Y1/5);
#      max <- Y2-(Y1/5);
      min <- Y1+((Y2-Y1)/10);
      max <- Y2-((Y2 -Y1)/10);
      FUy = append(FUy, min);
      FUy = append(FUy, max);
      FUy = append(FUy, max);
      FUy = append(FUy, min);
      FUy = append(FUy, NA);
#cat( "AA2 min:", min, "max:", max, "\n");
      
      if(FU$Window[i] == 1) {FUw[j] <- -45; FUc[j] <- 3;}
      else {FUw[j] <- 45; FUc[j] <- 3;}
      j <- j+1;
    }
    polygon(FUx,FUy,density=5,angle=FUw,lty=1,col=FUc,lwd=0.6);
#    mar=(Y2-Y1)/20;
#    polygon(FUx,rep(c(Y1+mar,Y2-mar,Y2-mar,Y1+mar,NA),length(FUx)/5),density=5,angle=FUw,lty=1,col=FUc,lwd=0.6);
  }
}

