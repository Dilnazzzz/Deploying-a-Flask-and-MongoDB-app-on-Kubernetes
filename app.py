from flask import Flask, request, jsonify
from flask_pymongo import PyMongo
from bson.objectid import ObjectId
import socket

# initialize the flask app
app = Flask(__name__)
app.config["MONGO_URI"] = "mongodb://mongo:27017/dev"
app.config['JSONIFY_PRETTYPRINT_REGULAR'] = True
mongo = PyMongo(app)
db = mongo.db

# landing page with a welcome message
@app.route("/")
def index():
    hostname = socket.gethostname()
    return jsonify(
        message="Welcome to Anonymous Message Board! I am running inside {} pod!".format(hostname)
    )

# view all messages
@app.route("/messages")
def get_all_messages():
    messages = db.message.find()
    data = []
    for message in messages:
        item = {
            "id": str(message["_id"]),
            "message": message["message"]
        }
        data.append(item)
    return jsonify(
        data=data
    )

# create a new message
@app.route("/message", methods=["POST"])
def create_message():
    data = request.get_json(force=True)
    db.message.insert_one({"message": data["message"]})
    return jsonify(
        message="Message saved successfully!"
    )

# update a message by id
@app.route("/message/<id>", methods=["PUT"])
def update_message(id):
    data = request.get_json(force=True)["message"]
    response = db.message.update_one({"_id": ObjectId(id)}, {"$set": {"message": data}})
    if response.matched_count:
        message = "Message updated successfully!"
    else:
        message = "No Message found!"
    return jsonify(
        message=message
    )

# delete a message by id
@app.route("/message/<id>", methods=["DELETE"])
def delete_message(id):
    response = db.message.delete_one({"_id": ObjectId(id)})
    if response.deleted_count:
        message = "Message deleted successfully!"
    else:
        message = "No Message found!"
    return jsonify(
        message=message
    )

# delete all messages
@app.route("/messages/delete", methods=["POST"])
def delete_all_messages():
    db.message.remove()
    return jsonify(
        message="All Messages deleted!"
    )

# default port to run the app
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
