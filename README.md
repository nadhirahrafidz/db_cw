## Team 11 COMP0022 Project Repository

<p align="center">
<img src="https://user-images.githubusercontent.com/35294224/111269423-89942a00-8626-11eb-808b-82994fb62cce.png" width="460" height="300">
</p>

### Abstract
MovieLens is a free movie recommendation service. And contains database two key datasets: ml-latest-small and personality-isf2018. Visit https://movielens.org/ to learn more about the data available. In this assignment we make use of the aforementioned datasets to create a LAMP Stack, N-tier Web Application can satisfies 6 different Use cases. Clients are about to search and filter through movies, see which movies are most popular, segment users based on tags and ratings, have a preview panel of users predict a rating of a "soon to be released movie" and predict traits of users who would give a high rating to a soon to be released movie.

### Launching Web App
1. Clone this repo in your local directory
2. Open terminal in the 'db_cw' folder
3. Make sure Docker is running
4. Run _sudo docker-compose up_

If you run into an error, it might be because one of your ports is already in use. 
- If you have mySQL installed locally on your comp, it automatically uses port 3306  
- Else, check if any other docker containers are running and using one of your ports (3306, 8080, 80). You can check by running command _docker ps_ on terminal. 
- Kill whatever is using the port and re-run _sudo docker-compose up_ 

To check if the 6 containers are up and running:
1. Run _docker ps_  : There should be 6 containers listed: preprocessing, db_cw_websvr_container, mysql:8.0, nadhirahrafidz98/team_11:websvr, phpmyadmin/phpmyadmin, nadhirahrafidz98/team_11:frontend
2. Go to _http://localhost:8080/_  : You should see the login page for phpmyadmin
3. Go to _http://localhost:3000/_  : You should see the Home Page for the Web Application

To check if the database has been set up and populated: 
1. Go to localhost8080
2. Sign into phpmyadmin:
        username: root
        password: team11
3. Database MovieLens should exist with 8 tables. 

### Docker Containers
Reference: https://www.youtube.com/watch?v=svlcIIp-S9w&ab_channel=TechOpenS.

#### About docker-compose.yml
Compose is a tool for defining and running multi-container Docker applications. The file creates containers for the following services:
1. Preprocessing
2. MySQL (version 8)
3. PHP-apache webserver (which is built from the Dockerfile in ./LAMPcontainer)
4. phpmyadmin

- Preprocessing container runs preprocess.py which prepares the datasets in ml-latest-small before populating the tables. 
- The MySQL container will not run until the preprocessing container has ran preprocess.py. 
- You don't need to manually download MySQL, PHP-apache or phpmyadmin images from Docker Hub, the docker-compose file will automatically do that for you 
- The PHP-apache webserver container & phpmyadmin container have been linked to the mySQL container
- The webserver's files (eg. HTML files) are located in _./LAMPcontainer/data:/var/www/html_ . You can see an index.html file already in there. 
