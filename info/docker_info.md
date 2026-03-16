## why would I want to use R in Docker?

This documentation is a brief introduction to Docker. First of all, you may have the question: why would I want to use R in Docker?

To answer that question you can either read the following text or watch this video:

https://youtu.be/_dfLOzuIg2o?t=18

Often when you send code that works fine on your computer to someone else they get thrown errors while executing it. This can have various reasons, such as a different operating system, a different version of R or R packages. Maybe they don't even have R on their PC and don't want to go through the process of installing it, but still want to run your code. Docker is solving those problems.

A Docker container can be understood as a virtual machine running on your computer. With docker, you can create a virtual environment, so-called images, and in our case install the right R version and packages. Someone wanting to reproduce your code just has to download the image and can easily run the virtual machine with the right R version and Packages pre-installed.

In short, you would use Docker because:

-it allows you to solve dependencies problems (including the operating system and R package versions).

-it makes sure that your Projects are reproducible for eternity. Because the Versions of the OS, R, and the additional packages stay the same in the Docker container. Whenever you want to restart the project, the environment configuration remains the same. Docker is just like a time capsule to take you back.

-Accessibility: a docker image can be easily pulled and run locally, and it saves you from installing R and all the packages.

## workflow for pulling down the treat image and run it locally:

Precondition:

you have installed Docker, if not here are installation tutorials:

Download Tutorial for Windows:

https://www.youtube.com/watch?v=5nX8U8Fz5S0

Download Tutorial for MacOS (min 12:18):

https://youtu.be/pTFZFxd4hOI?t=738

once docker is installed, check the Docker settings to make sure that you have at least 2 CPUs, 4 GB of memory.

You also need WRDS access to Compustat (North America and Global) to reproduce the analysis.

Workflow:

1. Issue the following command into your terminal to pull the image from Docker Hub and run it in your environment:  
   `docker run -d -p 8787:8787 -e PASSWORD=password --name (not sure)`

2. Open your browser and point it to: [http://localhost:8787](http://localhost:8787/)

3. Login with username "rstudio" and the password "password"

4. Enter WRDS login Data into the "config.csv" like this:

   ```
   wrds_user, 'yourusername', wrds_pwd, 'yourpassword',
   ```

5. Go to Rstudio in your browser and click on Build on the upper right side of your screen -> click Build all.

   The script is now running and it can take some time. Eventually, you will be greeted with the two files in the output directory: "paper.pdf" and "presentation.pdf".

## How could I start with docker?

an introduction of Docker in 100 seconds:

https://www.youtube.com/watch?v=Gjnup-PuquQ&ab_channel=Fireship
