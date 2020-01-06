FROM alpine

RUN apk add --update --no-cache openssh sshpass curl
RUN mkdir /root/.ssh/
RUN echo "Host *" > /root/.ssh/config
RUN echo "StrictHostKeyChecking no" >> /root/.ssh/config
RUN chmod 400 root/.ssh/config
COPY magic.sh /etc/
RUN chmod +x /etc/magic.sh
RUN echo '0 0 * * * /etc/magic.sh' >> /etc/crontabs/root
CMD crond -l 2 -f