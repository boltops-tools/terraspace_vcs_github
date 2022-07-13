require "faraday"
require "faraday/retry"
require "octokit"

module TerraspaceVcsGithub
  class Interface
    extend Memoist
    include Terraspace::Cloud::Vcs::Interface

    def comment(body)
      return unless github_token?

      logger.debug "Adding comment to full_repo #{full_repo} pr_number #{pr_number}"
      comments = client.issue_comments(full_repo, pr_number)
      found_comment = comments.find do |comment|
        comment.body.starts_with?(MARKER)
      end

      if found_comment
        client.update_comment(full_repo, found_comment.id, body) unless found_comment.body == body
      else
        client.add_comment(full_repo, pr_number, body)
      end
    rescue Octokit::Unauthorized => e
      # pretty long GitHub error message. so on separate line
      logger.info <<~EOL
        WARN: #{e.message}
        Unable to create pull request comment. Please double check your github token.
      EOL
    rescue Octokit::NotFound => e # from client.issue_comments(full_repo, pr_number)
      # can occur when user token does not have access to the repo
      logger.info <<~EOL
        WARN: #{e.message}
        Unable to list comments and create pull request comment.
        This can happen when user does not have access to the repo. Please double check your github token.
      EOL
    end

    def client
      Octokit::Client.new(access_token: ENV['GH_TOKEN'])
    end
    memoize :client

    def github_token?
      if ENV['GH_TOKEN']
        true
      else
        puts "WARN: The env var GH_TOKEN is not configured. Will not post PR comment"
        false
      end
    end
  end
end
