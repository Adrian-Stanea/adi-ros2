- Here add Docker wrappers for each package
- They should use 
  - BUild from sources or the .deb that is released in the index or ros2.org

- The docker wrapper should start from another Docker image that is -dev or -base that is given from each package
- Each package contains a Dockerfile with the -dev env and mounts the commit to the repo
  - The image can be used in development and testing