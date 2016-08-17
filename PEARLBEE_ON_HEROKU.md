To deploy Pearlbee on heroku follow this steps:

1. Clone this repository
2. cd Pearlbee
3.git add .
4.git commit -m "deploying to heroku"
4.heroku create --stack cedar --buildpack https://github.com/miyagawa/heroku-buildpack-perl.git
5.git push heroku master

6. add a database addon on Heroku using this command : heroku addons:add heroku-postgresql

7.Create a postgres database localy.

8.Push your local database to heroku with the command :
PGUSER=your_postgres_username PGPASSWORD=your_postgres_password heroku pg:push your_local_db_name DATABASE_URL your_heroku_db_url .
9.Register on http://captchas.net and add the secret code and user name in lib/PearlBee.pm at line 56:
    my $captcha = WebService::CaptchasDotNet->new(secret   => 'g4VE1IEwYCGjCM7M14Mwy8GOILJUuGJH4wt9DP5H',
                                            username =>   'drd_drd',
                                            alphabet => 'abcdefghkmnopqrstuvwxyz',
                                            expire   => 1800); 


