require "rest-client"
require "json"

# GithubRepoApi Class
# This class is here for communicating with the Github API to retrieve information
# about a specific repo.
#
# Arguments:
# username - The username to authenticate to github as (ex: user1234)
# password - The password to quthenticate to github with (ex: password1234)
# repo - The repository in github that you'd like to be getting info for (ex: Invoca/web)
class GithubRepoApi
  def initialize(username, password, repo)
    @github_url = "https://#{username}:#{password}!@api.github.com/repos/#{repo}"
  end

  # Returns a hash containing the base information
  # for the repository including but not limited to:
  #
  # fork - Boolean indicating if the repo was forked
  def information!
    JSON.parse(RestClient.get(@github_url))
  end

  # Returns a hash containing information about the current HEAD sha of the master branch
  # including but not limited to:
  #
  # sha - The current sha at the head of master
  def master_information!
    JSON.parse(RestClient.get("#{@github_url}/git/refs/heads/master"))["object"]
  end

  # Returns a hash containing information about the difference between two shas
  # including but not limited to
  #
  # ahead_by - How many commits exist in sha2 but not sha1
  # behind_by - How many commits exist in sha1 but not sha2
  def sha_compare!(sha1, sha2)
    JSON.parse(RestClient.get("#{@github_url}/compare/#{sha1}...#{sha2}"))
  end
end
