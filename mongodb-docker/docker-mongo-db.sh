sudo mkdir ${PWD}/mongo-db

sudo chmod 777 ${PWD}/mongo-db

sudo docker run --name some-mongo -p 27017:27017 -e MONGO_INITDB_ROOT_USERNAME=sysdba -e MONGO_INITDB_ROOT_PASSWORD=masterkey  -v ${PWD}/mongo-db:/data/db -d mongo
