# MONGO PACKAGE FUNCTIONS

# drops mongo database, inputted by user
function mongo.drop() {
 mongo "$@" --eval "db.dropDatabase()"
}
