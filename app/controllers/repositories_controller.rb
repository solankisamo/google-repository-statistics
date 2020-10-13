class RepositoriesController < ApplicationController
  require 'csv' 
  # defined. Queries MUST NOT be generated at request time.
  IndexQuery = GitHub::Client.parse <<-'GRAPHQL'
    # All read requests are defined in a "query" operation
    query {
      search(query: "org:google", type: REPOSITORY, first: 100) {
        edges {
          node {
            ... on Repository {
              name
              primaryLanguage {
                name
              }
              createdAt
            }
          }
        }
      }
    }
  GRAPHQL

  
  # GET /repositories
  def index
    # Use query helper defined in ApplicationController to execute the query.
    # `query` returns a GraphQL::Client::QueryResult instance with accessors
    # that map to the query structure.
    response = query IndexQuery
    languages = []
    data = JSON.parse(response.to_json)
    puts data
    dataset = data.fetch('data').fetch('search').fetch('edges')
    dataset.each do |row|
      languages << row.fetch('node').fetch('primaryLanguage')
    end
    
    # Bad idea to set these here but just using as quickly we can, always a scope to refactor
    @top_5 = top_languages(languages)
    @least_5 = least_languages(languages)

    respond_to do |format|
      format.html
      format.csv { send_data generate_csv(dataset) }
    end
    
  end


  private 

  def top_languages(lang_array, up_to = 5)
    # Remove the nil or blank elements first
    lang_array.reject!{ |e| e.to_s.empty? }

    lang_array.group_by { |r| r["name"]}
    .sort_by  { |k, v| -k }
    .first(up_to)
    .map(&:first)
    .flatten
  end

  def least_languages(lang_array, up_to = 5)
    # Remove the nil or blank elements first
    lang_array.reject!{ |e| e.to_s.empty? }

    lang_array.group_by { |r| r["name"]}
    .sort_by  { |k, v| -k }
    .last(up_to)
    .map(&:first)
    .flatten
  end

  def generate_csv(csv_data)
    CSV.generate(headers: true) do |csv|
      csv << ["Repo Name", "Language", "Created Date"]

      csv_data.each do |row|
        # Some of the repositories not having `primaryLanguage` set so just use `N/A` instead
        repo_name = row.fetch('node').fetch('primaryLanguage').fetch('name') rescue 'N/A'
        csv << [row.fetch('node').fetch('name'), repo_name, row.fetch('node').fetch('createdAt')] 
      end
    end
  end

end
