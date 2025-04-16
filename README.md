# Leipzig Corpora Docker

## 📚 Citation

If you use this corpus in your work, please cite the following:
* [Goldhahn, Dirk, Thomas Eckart, and Uwe Quasthoff. "Building large monolingual dictionaries at the leipzig corpora collection: From 100 to 200 languages." LREC. Vol. 29. 2012.](http://www.lrec-conf.org/proceedings/lrec2012/pdf/327_Paper.pdf)

---

This project provides an easy way to set up and manage Leipzig corpora using Docker. You can run and process corpora in a few simple steps, including using a web interface (DbGate) to interact with the data.

## 🔧 Prerequisites
* [Install Docker](https://www.docker.com) — make sure Docker Desktop is installed and running on your system.

---

## 🚀 Setup Instructions

### 1. Get source code

* If you are familiar with git, you know what to do.
  
* If not, download ZIP of the repository [here](https://github.com/bananaofhappiness/leipzig-corpora-viewer/archive/refs/heads/main.zip) or by using a green button "<> Code" at the top of the page.
	
* Extract the ZIP file to any folder on your computer.

### 2. Run the Project

🪟 For Windows Users:

* Open the folder where you’ve unpacked the ZIP.
    
* Right-click and select “Run with PowerShell” on the start.ps1 script.
    
* Wait for the script to finish — this will build and start the Docker containers.

🐧 For Linux and macOS Users:
* Open a terminal and navigate to the folder where you’ve unpacked the ZIP.
* Run the following command to build and start the containers:

`docker-compose up --build`

* This will automatically download the necessary images, build the containers, and start the project.

---

## 📒 Add your corpora

Once the container is up and running, you can access the DbGate web interface at http://localhost:3000

This interface allows you to view and query the corpora.

### 1. Setting Up DbGate Connection
To set up a connection to the MySQL database:
* Click on the "Connections" tab.
* Click a plus button.
* Select `MySQL` as connection type.
* In the `Server` field either db, dockerhost, or leipzig-corpora-mysql will work (though the last one is more verbose and hence is more preferable).
* For `Username`, use root.
* For `Password`, use 1111.
* Select MySQL as the connection type and click Save.

Now you should be able to view and query your corpora.

### 2. Adding New Corpora

To add new corpora to the project, follow these steps:
1. Stop the Docker container:
    * Open Docker Desktop.
    * Go to the `Containers` tab on the left.
    * Find the running container named `leipzig-corpora-viewer`.
    * Click the stop (square) button to stop the containers.
2. Add your new corpora:
   * Download a Leipzig Corpus.
   * Unzip it.
   * Move the folder containing the corpus into `corpora` folder
3. Restart the Docker container:
   * Go back to Docker Desktop.
   * Find the stopped containers and click the start (play) button to restart them.

---

## ⚠️ Notes
* If you encounter any issues with Docker containers starting or stopping, try restarting Docker Desktop.
* You can always check the logs for more information by clicking on the container and looking at the logs in Docker Desktop.

---

## 🎉 You’re Ready to Go!
* Now you can use DbGate to interact with the corpora, make SQL queries, and view the data.
* Keep your corpora in the corpora folder and just restart the containers whenever you add new data.

---

## 🔄 Updating and Rebuilding

If you make changes to the docker-compose.yml or Dockerfile, or want to rebuild the images:
* Stop the containers using the stop button in Docker Desktop.
* Rebuild and restart: `docker-compose up --build`

This will pull the latest changes and rebuild the project.

---

## 🧑‍💻 Further Customization

Feel free to modify the docker-compose.yml, the initdb.sh script, or any other files to suit your needs. If you want to add more services or databases, just edit the compose file and rebuild.

---

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](https://github.com/bananaofhappiness/leipzig-corpora-viewer/blob/main/LICENSE) file for details.

---

Let me know if you need any further customization or additions!
