# Stage 1: Build stage using Node.js image
FROM node:18.9.1 AS build

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code
COPY . .

# Set environment variable for Prisma
ENV DATABASE_URL=postgresql://tomboy:tom@1234567@postgres_db:5432/school

# Generate Database
RUN npx prisma migrate dev --name init

# Build the Next.js application
RUN npm run build

# Use a minimal Node.js image for production
FROM node:20-alpine3.20

# Set working directory
WORKDIR /app

# Copy the built application and node_modules from the builder stage
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/prisma ./prisma
COPY --from=build /app/.next ./.next

# Expose the port the app runs on
EXPOSE 3000

# Add a non-root user and switch to it
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

# Run the Next.js application
CMD ["npm", "start"]