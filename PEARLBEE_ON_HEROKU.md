To deploy Pearlbee on Heroku follow this steps:

1. Clone the branch pb_on_heroku from my repository with the command :
   * `git clone -b pb_on_heroku --single-branch https://github.com/DragosTrif/PearlBee.git
`	
2. `cd Pearlbee`
3. In your teminal type: `heroku login`.
4. Create a heroku remote: `heroku create --stack cedar --buildpack https://github.com/miyagawa/heroku-buildpack-perl.git`
7. `git push heroku master` (Steps 3,4 and 7 have to be repetead evrey time the code is modified)

8. add a database addon on Heroku using this command : `heroku addons:add heroku-postgresql`

9. Create a postgres database localy.
	* dont forget to rename your user table my_users

10. Push your local database to heroku with the command :
	* `PGUSER=your_postgres_username PGPASSWORD=your_postgres_password heroku pg:push your_local_db_name DATABASE_URL your_heroku_db_url` 
11. Grant privilegies to your default heroku postgres user:
	* type in your terminal :
		* `heroku pg:psql`
		* `GRANT USAGE ON SCHEMA public to your_heroku_postgres_user;`
		* `GRANT SELECT ON ALL SEQUENCES IN SCHEMA public to your_heroku_postgres_user;`
		* `GRANT SELECT, UPDATE, INSERT, DELETE ON ALL TABLES IN SCHEMA public to your_heroku_postgres_user;` 

12. Register on http://captchas.net and add the captcha credentials to your config.yml.
    * ` secret: 'your_secret_pharase'`
	* `username: 'your_CaptchasDotNet_username'`
13. Upadate your config.yml file :
    * `app_url: 'your_heroku_url'`
    * `dsn: 	dbi:Pg:dbname=heroku_db_name;host=heroku_host;port=5432`
    * `user: your_heroku_postgres_user`
    * `password: your_heroku_postgres_password` 	
		
    


