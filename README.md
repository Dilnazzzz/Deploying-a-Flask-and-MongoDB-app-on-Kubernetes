# Deploying a Flask and MongoDB app on Kubernetes


This repository includes scripts that run a Flask and MongoDB app on Kubernetes. This video showcases key features and features of deploying this scalable app. 

Run the command chmod +x [NAME OF FILE] to make shell files executable. For example, chmod +x setup_kubernetes.sh
Then you can run the shell files by using ./ as a prefix to the file. For example, ./setup_kubernetes.sh

To view the landing page: 
dilnazbaltabayeva@Dilnazs-Air tasksapp-python % curl 10.99.210.99:8080
{
  "message": "Welcome to Anonymous Message Board! I am running inside ed3c464481dc pod!"
}
dilnazbaltabayeva@Dilnazs-Air tasksapp-python % curl 10.99.210.99:8080/tasks
{
  "data": []
}
dilnazbaltabayeva@Dilnazs-Air tasksapp-python % curl -X POST -d "{\"message\": \"Message 1\"}" http://10.99.210.99:8080/message
{
  "message": "Task saved successfully!"
}
dilnazbaltabayeva@Dilnazs-Air tasksapp-python % curl 10.99.210.99:8080/messsages
{
  "data": [
    {
      "id": "5ef8bce7df44b8194ee30c9a",
      "message": "Task 1"
    }
  ]
}
myuser@master1:~$ curl -X PUT -d "{\"message\": \"Message 1 Updated\"}" http://10.99.210.99:8080/message/5ef8bce7df44b8194ee30c9a
{
  "message": "Message updated successfully!"
}
myuser@master1:~$ curl -X DELETE http://10.99.210.99:8080/message/5ef8bce7df44b8194ee30c9a
{
  "message": "Message deleted successfully!"
}
