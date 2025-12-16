FROM postgres:15

RUN apt-get update && apt-get install -y \
    curl \ 
    gzip \
    cron \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /backups

COPY database/backup.sh /usr/local/bin/backup.sh

RUN chmod +x /usr/local/bin/backup.sh

# Dodaj zadanie cron do wykonywania backupu codziennie o 2:00 w nocy
RUN echo "0 2 * * * root /usr/local/bin/backup.sh" >> /etc/cron.d/backup-cron
RUN chmod 0644 /etc/cron.d/backup-cron

#RUN /usr/local/bin/backup.sh

CMD cron && docker-entrypoint.sh postgres