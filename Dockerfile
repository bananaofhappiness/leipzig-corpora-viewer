FROM debian:latest


# Update package lists and install bash and mysql-client (provides mysqladmin)
RUN apt-get update && apt-get install -y bash default-mysql-client

COPY initdb.sh /initdb.sh
RUN chmod +x /initdb.sh

ENTRYPOINT ["/initdb.sh"]