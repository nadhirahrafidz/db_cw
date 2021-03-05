FROM node:14.15.4 
WORKDIR /
ENV PATH /node_modules/.bin:$PATH
COPY package*.json ./ 
RUN npm install
COPY . ./
EXPOSE 3000
CMD [ "npm", "start" ]