<h1>Dockerising Pearlbee</h1>
By following this steps you will create a stack of three containers:
- the first for  Pearlbee ( a Dancer2 web app )
- the second for mysql ( this will hold the database )
- and a third for Nginx ( to act as a load-balancer )


1. Clone this repository with this command :
   * `git clone -b dockerising_pearbee --single-branch https://github.com/DragosTrif/PearlBee.git`
2. `cd  dockerising_pearbee`
3. Create docker containers and images:
   * `docker-compose up -d`
4. Fire up your containers with :
   * `docker-compose up`
5. Checking out the containers and creating the database for Pearlbee:
    * open a new terminal and type: 
      * `docker ps`
    * inspect the mysql container and copy the ip using:
      *  `docker inspect your_mysql_container_id` 
    * open the mysql container with:
      * `mysql -h mysql_container_ip -P 3306 -u root -p` (the password is `secret`)
    * copy paste this code https://github.com/DragosTrif/PearlBee/blob/dockerising_pearbee/dockerising_pearlbee/db_patches/create_tables.sql
    * type `exit` to leave the container.     
6. Fire up browser and and go to the url `localhost` .
    * login with this credentials : 
      *    `user:        admin `
      *    `password: password `
7. Scale up Pearlbee.
	* in your second terminal go to your `dockerising_pearbee` folder.
	* type `docker-compose scale pearlbee=2` this will start a second instance of your pearlbee service.
8. Check if the ip of the second pearlbee instance is added to your NGINX load-balncer:
	* type `docker ps`
	* open your NGINX container with `docker exec -it nginx_container_id    sh`
	* inside the container type 'nslookup pearlbee' you should see smothing like this:
	 * `Name:      pearlbee`
	 * `Address 1: 172.23.0.4 dockerisingpearlbee_pearlbee_1.dockerisingpearlbee_default`
     * `Address 2: 172.23.0.5 dockerisingpearlbee_pearlbee_3.dockerisingpearlbee_default`
9. Restart your your compostion:
 	* hit `ctrl+c' to stop it
 	* `docker-compose up` to restart it.
 	* Enjoy PearlBee      

     
    