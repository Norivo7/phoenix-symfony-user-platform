## Morizon–Gratka Recruitment Task


consisting of:

- Phoenix (Elixir)
- Symfony (PHP)
- Docker Compose

Symfony follows a DDD-inspired modular structure
to keep clear boundaries, while the domain and persistence are handled by Phoenix API.

### Requirements
Docker + Docker Compose

### Configuration

Symfony requires APP_SECRET.

Generate it locally:
```bash
php -r 'echo bin2hex(random_bytes(16)).PHP_EOL;'
```
rename ```.env.example``` to ```.env.local```

and paste generated value
```dotenv
APP_SECRET=generated_value_here
```

### Run project

1. Go to the project root (``` /morizon-gratka```), build and start containers:
```bash
docker compose up -d --build
```

2. Run database migrations:
```bash
docker compose exec phoenix mix ecto.migrate
```

3. Install Symfony dependencies:
```bash
docker compose exec symfony composer install
```

### After startup

Phoenix API → http://localhost:4000

Symfony frontend → http://localhost:8000/users

## Import initial data (Phoenix)

Phoenix exposes an import endpoint that generates 100 users based on PESEL name datasets.

Token is configured via ```IMPORT_TOKEN``` env var in ``docker-compose.yml`` (phoenix service).

Endpoint is protected with x-api-token header.


Import can be executed multiple times (for demo purposes)
### Run:
```bash
curl -X POST http://localhost:4000/api/import -H "x-api-token: change_me"
```

## Data sources

User data is generated from official PESEL datasets:

[Top 100 female first names](https://dane.gov.pl/pl/dataset/1667,lista-imion-wystepujacych-w-rejestrze-pesel-osoby-zyjace/resource/63924/table?page=1&per_page=20&q=&sort=)

[Top 100 male first names](https://dane.gov.pl/pl/dataset/1667,lista-imion-wystepujacych-w-rejestrze-pesel-osoby-zyjace/resource/63929/table?page=1&per_page=20&q=&sort=)

[Top 100 female last names](https://dane.gov.pl/pl/dataset/1681,nazwiska-osob-zyjacych-wystepujace-w-rejestrze-pesel/resource/63888/table?page=1&per_page=20&q=&sort=)

[Top 100 male last names](https://dane.gov.pl/pl/dataset/1681,nazwiska-osob-zyjacych-wystepujace-w-rejestrze-pesel/resource/63892/table?page=1&per_page=20&q=&sort=)

CSV files are stored locally in``` phoenix-api/priv/pesel/```

### Generation rules:

- Random first name + last name
- Gender consistent with first name
- Birthdate randomly generated between 1970-01-01 and 2024-12-31

### Endpoints

| Method	 | Endpoint   | 	Description                              |
|---------|------------|-------------------------------------------|
| GET	    | /users     | 	List users (filters & sorting supported) |
| POST	   | /users     | 	Create user                              |
| GET	    | /users/:id | 	Get user details                         |
| PUT	    | /users/:id | 	Update user                              |
| DELETE	 | /users/:id | 	Delete user                              |
| POST	   | /import    | 	Import users (requires x-api-token)      |


### Features:

- User list
- Filtering & sorting
- Create / edit / delete users
- Communication with Phoenix API via HttpClient
- DDD-styled structure
- Commands & Queries handled via Symfony Messenger (sync)

### Useful commands
to clear users data in Phoenix DB:
```bash
docker compose exec db psql -U morizon -d morizon -c "TRUNCATE users RESTART IDENTITY;"```
```