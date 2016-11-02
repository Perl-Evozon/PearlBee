
FROM        perl:latest
MAINTAINER  perl5 drd.trif@gmail.com
RUN curl -L http://cpanmin.us | perl - App::cpanminus


RUN apt-get update

Run apt-get install libvpx-dev
Run apt-get install libxpm-dev
Run apt-get install -f libgd-dev
RUN cpanm --force Carton Starman


RUN cachebuster=b953b35 git clone -b dockerising_pearlbee --single-branch https://github.com/DragosTrif/PearlBee.git
RUN cd PearlBee && carton install  && carton install --deployment 


 
EXPOSE 8080
WORKDIR PearlBee


CMD carton exec starman --port 8080 bin/app.psgi
