###################################
#---------------BASE--------------#
###################################
FROM node:16 as base
ARG NODE_ENV=development

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

###################################
#---------------TEST--------------#
###################################
FROM base as test

COPY .npmrc package.json yarn.lock /usr/src/app/
RUN yarn --verbose --frozen-lockfile
ADD . /usr/src/app/

###################################
#--------------BUILDER------------#
###################################
FROM test as builder

RUN yarn build
RUN npm prune --production

###################################
#------------PRODUCTION-----------#
###################################
FROM node:16.14-alpine as production
ENV NODE_ENV=production

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY --from=builder /usr/src/app/node_modules ./dist/node_modules
COPY --from=builder /usr/src/app/package.json ./
COPY --from=builder /usr/src/app/dist ./dist

EXPOSE 3000

CMD [ "yarn", "start:prod" ]
