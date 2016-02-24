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
    
### Customizing your deployment

You can include additional files in your slug with the `--includes` option. 

```
heroku deploy:war --war myapp.war --includes newrelic.jar:newrelic.xml
```

The character separating the included files is platform specific, just like [File.pathSeparator](http://docs.oracle.com/javase/8/docs/api/java/io/File.html#pathSeparator). On Windows it will be `;` (semi-colon) and on Mac and Linux it will be `:` (colon).

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

## Configuration

You can configure how the WAR file executes on the server by setting the
WEBAPP_RUNNER_OPTS configuration variable on your application. For example,
you might set the following option:

```term
$ heroku config:set WEBAPP_RUNNER_OPTS="--uri-encoding=UTF-8"
```

The `heroku-deploy` plugin uses Tomcat Webapp Runner as a container for the
WAR file. Thus, all Webapp Runner options are available to the app. A full list
options is described in the
[Webapp Runner documentation](https://github.com/jsimone/webapp-runner#options).

You can also configure the underlying JVM that runs the Tomcat container by
setting the JAVA_OPTS configuration variable. For example, you set the
following option:

```term
$ heroku config:set JAVA_OPTS="-Xss512k"
```

However, [the Heroku platform will select a good set of defaults](https://devcenter.heroku.com/articles/java-support#environment) for you.
