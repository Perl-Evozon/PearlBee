
FROM        perl:latest
MAINTAINER  perl5 drd.trif@gmail.com
RUN curl -L http://cpanmin.us | perl - App::cpanminus



RUN cpanm Carton Starman


RUN cachebuster=b953b35 git clone -b pb_on_docker --single-branch https://github.com/DragosTrif/PearlBee.git

RUN cd PearlBee && carton install  && carton install --deployment 
EXPOSE 8080
WORKDIR PearlBee

CMD carton exec plackup --port 8080 bin/app.psgi