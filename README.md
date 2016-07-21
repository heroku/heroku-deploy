**WARNING**

This plugin has been replaced by the [Heroku CLI Deploy plugin](https://github.com/heroku/heroku-cli-deploy),
which you can install like this:

```
$ heroku plugins:install heroku-cli-deploy
```

The commands for heroku-cli-deploy are the same as this plugin.

# Heroku Deploy War/Jar [![Build Status](https://travis-ci.org/heroku/heroku-deploy.svg)](https://travis-ci.org/heroku/heroku-deploy)

This project is a [Heroku toolbelt](https://toolbelt.heroku.com/)
plugin for [deploying WAR files](https://devcenter.heroku.com/articles/war-deployment). It can also be used to deploy
[executable JAR files](#executable-jar-files).

If you are using Maven, see also the [Heroku Maven plugin](https://devcenter.heroku.com/articles/deploying-java-applications-with-the-heroku-maven-plugin),
a more robust method of WAR file deployment.

## Prerequisites

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

    $ heroku plugins:install https://github.com/heroku/heroku-deploy

### 3. Create a Heroku application

Use the following command to create a new application on Heroku

    $ heroku create

### 4. Create a WAR file

You can use any method to generate a WAR file. You can use <code>maven</code>,<code>ant</code> or simply export your application from your IDE as a WAR file.

The only requirement is that the WAR file is a standard Java web application and adheres to the standard web application structure and conventions.

### 5. Deploy your WAR

In order to deploy your WAR use the following command:

```sh-session
$ heroku deploy:war --war <path_to_war_file> --app <app_name>
Uploading my-app.war....
---> Packaging application...
    - app: my-app
    - including: webapp-runner.jar
    - including: my-app.war
---> Creating build...
    - file: slug.tgz
    - size: 1MB
---> Uploading build...
    - success
---> Deploying...
remote:
remote: -----> Fetching custom tar buildpack... done
remote: -----> JVM Common app detected
remote: -----> Installing OpenJDK 1.8... done
remote: -----> Discovering process types
remote:        Procfile declares types -> web
remote:
remote: -----> Compressing... done, 50.3MB
remote: -----> Launching... done, v5
remote:        https://my-app.herokuapp.com/ deployed to Heroku
remote:
---> Done
```

If you are in an application directory, you can use the following command instead::

    heroku deploy:war --war <path_to_war_file>

### 6. View your app on Heroku

Use the following command to open the application on the browser:

    heroku open

You can learn how to customize the deploy (such as including files and setting Tomcat options)
in [Configuring WAR Deployment with the Heroku Toolbelt](https://devcenter.heroku.com/articles/configuring-war-deployment-with-the-heroku-toolbelt).

## Executable JAR Files

You can also use this tool to deploy executable JAR files. To do so, run a command like this:

```
$ heroku deploy:jar --jar <path_to_jar> --app <appname>
```

Available options include:

```
 -j, --jar FILE         # jar or war to deploy
 -v, --jdk VERSION      # 7 or 8. defaults to 8
 -o, --options OPTS     # options passed to the jar file
 -i, --includes FILES   # list of files to include in the slug
```

### Customizing your deployment

You can customize the command used to run your application by creating a `Procfile` in the *same directory* as your run the `heroku deploy:jar` command. For example:

```
web: java -cp my-uberjar.jar com.foo.MyMain opt1 opt2
```

You can view your current Procfile command by running `heroku ps`.
