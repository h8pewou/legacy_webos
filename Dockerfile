FROM ubuntu
#Install dependencies

RUN apt-get update -y
RUN apt-get upgrade -y
RUN apt-get install -y tzdata
ENV TZ "Europe/Budapest"
RUN echo "Europe/Budapest" > /etc/timezone
RUN dpkg-reconfigure --frontend noninteractive tzdata
RUN apt-get install -y git wget python ffmpeg curl apache2 php libapache2-mod-php php-mysql php-xml php-zip php-gd
RUN rm -f /etc/localtime
RUN ln -fs /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime
#Install app

RUN rm -rf /var/www/html/*
#TODO: Replace this with git clone from codepoet
ADD metube-php-servicewrapper /var/www/html/
RUN wget https://yt-dl.org/downloads/latest/youtube-dl -O /usr/bin/youtube-dl && chmod a+rx /usr/bin/youtube-dl
RUN rm -f /etc/apache2/sites-available/000-default.conf
#TODO: Replace this with wget from h8pewou
ADD ./settings/000-default.conf /etc/apache2/sites-available/
#Configure apache

RUN a2enmod rewrite
RUN chown -R www-data:www-data /var/www/html/
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid

EXPOSE 80
#TODO: Replace this with wget from h8pewou
COPY run.sh /run.sh
RUN chmod a+rx /run.sh
CMD ["/bin/bash", "/run.sh"]
