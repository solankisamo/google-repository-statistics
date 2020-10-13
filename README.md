# GitHub Google Repository Statistics

## Running locally

First, you'll need a [GitHub API access token](https://help.github.com/articles/creating-an-access-token-for-command-line-use) to make GraphQL API requests. This should be set as a `GITHUB_ACCESS_TOKEN` environment variable as configured in [config/secrets.yml](https://github.com/github/github-graphql-rails-example/blob/master/config/secrets.yml).

``` sh
$ bundle install
$ GITHUB_ACCESS_TOKEN=abc123 rails server
```

And visit [http://localhost:3000/](http://localhost:3000/).

This should show 5 top languages and 5 least languages used in Google Repositories. And an option to export all repository list (with name and created date) in a CSV file
