1. Install the recommended plugins

2. Create User

3. Setup Matrix authentication: 
Manage Jenkins > Configure Global Security 
> Authorization > Matrix-based > Add User 
> Select All

4. Make quick test:
New Item > Freestyle Project > Build Steps 
> Execute Shell > ps ax > Save 
> Build Now > Check output

5. Create Folder:
New Item > Folder > Homework-Docker-BG-App

5. In that folder create two items:

New Item > Pipeline > name it PL-Master > OK >
* Paste the content of ./pl-master.groovy

New Item > Pipeline > name it PL-Slave > OK >
* This project is parameterised
* add all params, as String Parameter, 
without default values, as follows:

- LOCAL_ENV_PORT
- APP_ROOT
- PROJECT_ROOT
- DB_ROOT_PASSWORD

* Paste the content of ./pl-slave.groovy

6. Build now the PL-Master
7. Open http://192.168.99.101:9090/
8. or curl http://192.168.99.101:9090/

Regards,
Dimitar