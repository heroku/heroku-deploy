# Getting started with WAR deployment on Heroku

## Pre requisites

You will require the following:

* Install the [Heroku toolbelt](https://toolbelt.heroku.com/)
* [Heroku account](https://api.heroku.com/signup)

## Getting started

### 1. Make sure Java 7 or higher is installed

Run the following command to confirm:

```sh-session
$ java -version
java version "1.7.0_51"
Java(TM) SE Runtime Environment (build 1.7.0_51-b13)
Java HotSpot(TM) 64-Bit Server VM (build 24.51-b03, mixed mode)
```

### 2. Install the <code>heroku-deploy</code> CLI plugin

Use the following command to install the <code>heroku-deploy</code> plugin:

    heroku plugins:install https://github.com/heroku/heroku-deploy

<b>Note</b>: If you have a previous version of Heroku client, please ensure you update to the latest version. You should have <code>ver 2.24.0</code> of the Heroku command line. To verify your version, type the following command:

     $ heroku version
     2.24.0

or

     C:\> heroku version
     2.24.0

### 3. Create a Heroku application

Use the following command to create a new application on Heroku

    heroku create

### 4. Create a WAR file

You can use any method to generate a WAR file. You can use <code>maven</code>,<code>ant</code> or simply export your application from your IDE as a WAR file.

The only requirement is that the WAR file is a standard Java web application and adheres to the standard web application structure and conventions.

### 5. Deploy your WAR

In order to deploy your WAR use the following command:

    $ heroku deploy:war --war <path_to_war_file> --app <app_name>
    Uploading my-app.war....
    ---> Packaging application...
    - app: my-app
    - including: webapp-runner.jar
    - including: my-app.war
    - installing: OpenJDK 1.8
    ---> Creating slug...
    - file: slug.tgz
    - size: 56MB
    ---> Uploading slug...
    - stack: cedar-14
    - process types: [web]
    ---> Releasing...
    - version: 24

If you are in an application directory, you can use the following command instead::

    heroku deploy:war --war <path_to_war_file>

### 6. View your app on Heroku

Use the following command to open the application on the browser:

    heroku open
