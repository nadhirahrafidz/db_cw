Team 11 Database Coursework repo

## Docker Containers
Reference: https://www.youtube.com/watch?v=svlcIIp-S9w&ab_channel=TechOpenS.

#### About docker-compose.yaml
Compose is a tool for defining and running multi-container Docker applications. The file creates containers for the following services (images): 
1. MySQL (version 8)
2. PHP-apache webserver (which is built from the Dockerfile in ./LAMPcontainer)
3. phpmyadmin

- You don't need to manually download these images from Docker Hub, the docker-compose file will automatically do that for you 
- The PHP-apache webserver & phpmyadmin has been linked to the mySQL container
- The webserver's files (eg. HTML files) are located in ./LAMPcontainer/data:/var/www/html

### Getting Started:
1. Clone this repo in local directory
2. Open terminal in the 'db_cw' folder
3. Make sure Docker is running
4. Run _sudo docker-compose up_

If you run into an error, it might be because one of your ports is already in use. 
- If you have mySQL installed locally on your comp, it automatically uses port 3306  
- Else, check if any other docker containers are running and using one of your ports (3306, 8080, 80). You can check by running command _docker ps_ on terminal. 
- Kill whatever is using the port and re-run _sudo docker-compose up_ 

To check if the containers are up and running:
1. Run _docker ps_  : There should be 3 images listed: db_cw_websvr_container, mysql:8.0, phpmyadmin/phpmyadmin
2. Go to _http://localhost:8080/_  : You should see the login page for phpmyadmin
3. Go to _http://localhost:80/_  : You should see "Hi team 11!" 

