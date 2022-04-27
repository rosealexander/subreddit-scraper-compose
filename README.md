> # docker-scraper-compose
### Docker Compose for [subreddit-scraper](https://github.com/rosealexander/subreddit-scraper)

- Assign the following environment variables and run `docker-compose up`
```
REDDIT_CLIENT_SECRET    Reddit bot secret key           REQUIRED
REDDIT_CLIENT_ID        Reddit bot client ID            REQUIRED
REDDIT_USER_AGENT       Reddit User Agent               REQUIRED    check subreddit-scraper README for info
POSTGRES_USER           PostgreSQL username             REQUIRED
POSTGRES_PASSWORD       PostgreSQL password             REQUIRED
HOST_PORT               Mapping to container port 5432  REQUIRED
KWARGS                  The following OPTIONAL arguments can be used with `KWARGS` environment variable.
                        --subreddit               The subreddits to observe, multiples allowed, defaults to r/all.
                        --disable-submissions     Disables submission collection.
                        --disable-comments        Disables comment collection.
                        --submission-commits      The number of Submission rows to collect before performing batch insert, defaults to 1.
                        --comment-commits         The number of Comment rows to collect before performing batch insert, defaults to 1.
                        --update-interval         Enables score recording at a set interval in minutes, for example: 10, disabled by default
                        --update-threshold        The maximum duration in hours to record score per submission or comment, defaults to 24.
```

[![MIT License][license-shield]][license-url]

[license-shield]: https://img.shields.io/github/license/rosealexander/subreddit-scraper-compose.svg?style=for-the-badge
[license-url]: https://github.com/rosealexander/subreddit-scraper/blob/master/LICENSE
