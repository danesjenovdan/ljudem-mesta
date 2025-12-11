# build stage
FROM node:24-alpine AS build

# set current directory
WORKDIR /app

# install dependencies
COPY package.json package-lock.json ./
RUN npm ci

# copy source code
COPY src ./src
COPY static ./static
COPY database.types.ts .eslintignore .eslintrc.cjs .prettierignore .prettierrc svelte.config.js tsconfig.json vite.config.ts ./

# set environment variables
# TODO dont use secrets here
ARG VITE_SUPABASE_URL
ARG VITE_SUPABASE_API_KEY

# build the app
RUN npm run build

# production stage
FROM node:24-alpine

# set current directory
WORKDIR /app

# install dependencies
COPY package.json package-lock.json ./
RUN npm ci --omit=dev

# copy built files
COPY --from=build /app/build ./build

CMD ["node", "build/index.js"]
