require_relative "./github_api";

def put_warnings(warnings, warnings_count)
  if warnings_count > 0
    warnings.sort_by!{|gem| gem["name"]}
    warn "\nThe following invoca gems in the gemfile are pointing behind the tips of their master branches."
    puts ""
    warnings.each do |gem|
      puts gem
      puts ""
    end
  end
end

lock = Bundler.read_file(Bundler.default_lockfile)
gems = Bundler::LockfileParser.new(lock)
incorrect_references = []
warnings = []
count = 0
warnings_count = 0

# Loop over all gem sources within the Gemfile
gems.sources.each do |source|
  begin
    if source.class == Bundler::Source::Git
      name = source.name
      sha = source.revision
      username = ENV['GITHUB_USERNAME']
      password = ENV['GITHUB_PASSWORD']
      forked = GithubRepoApi.new(username, password, "Invoca/#{name}").information!["fork"]
      next if forked
      master_sha = GithubRepoApi.new(username, password, "Invoca/#{name}").master_information["sha"]
      ahead_by = GithubRepoApi.new(username, password, "Invoca/#{name}").sha_compare!(master_sha, sha)["ahead_by"]
      behind_by = GithubRepoApi.new(username, password, "Invoca/#{name}").sha_compare!(master_sha, sha)["behind_by"]
      if ahead_by > 0
        info = {"name" => name, "ahead_by" => ahead_by, "sha" => sha, "master sha" => master_sha}
        incorrect_references[count] = info
        count = count + 1
      else
        if behind_by > 0
          info = {"name" => name, "ahead_by" => ahead_by, "sha" => sha, "master sha" => master_sha}
          warnings[warnings_count] = info
          warnings_count = warnings_count + 1
        end
      end
    end
  rescue RestClient::Exception => ex
    puts name
    puts ex.http_body
  end
end

put_warnings(warnings, warnings_count)

if count > 0
  incorrect_references.sort_by!{|gem| gem["name"]}
  puts "\nThe shas of the following gems do not match the gem's masters"
  puts "Merge the gems into their respective master branches"
  puts ""
  incorrect_references.each do |gem|
    puts gem
    puts ""
  end
  exit(1)
else
  exit(0)
end
