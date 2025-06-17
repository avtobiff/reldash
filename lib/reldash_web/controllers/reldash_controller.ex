defmodule ReldashWeb.ReldashController do
  use ReldashWeb, :controller

  @active_releases_txt "config/active-releases.txt"
  @atlassian_token File.read!("config/reldash.token") |> String.trim()
  @jira_url "JIRA_URL/rest/api/3/search/approximate-count"
  @bar_width 400

  # XXX setup correct project and fields in jql queries
  @fixed_num_jql      """
                      project = 
                      AND
                      status = closed
                      AND
                      fixVersion = 
                      """
  @bugs_num_jql       """
                      project = 
                      AND
                      category != feature
                      AND
                      status != closed
                      AND
                      fixVersion = 
                      """
  @features_num_jql   """
                      project = 
                      AND
                      category = feature
                      AND
                      status != closed
                      AND
                      fixVersion = 
                      """


  def home(conn, _params) do
    {:ok, active_releases} = :file.consult(@active_releases_txt)

    release_status =
      for {release_c, date_c} <- active_releases do
        release = to_string(release_c)
        fixed = jira_count(@fixed_num_jql, release)
        bugs = jira_count(@bugs_num_jql, release)
        features = jira_count(@features_num_jql, release)
        num_issues = fixed + bugs + features

        [progress_fixed, progress_bugs, progress_features] =
          for item <- [fixed, bugs, features] do
            try do
              item / num_issues
            rescue
              ArithmeticError ->
                # guard divide by zero
                1.0
            end
          end

        height = 10 + 20 * ceil(:math.log10(1 + num_issues))
        green = floor(progress_fixed * @bar_width)
        red = ceil(progress_bugs * @bar_width)
        blue = ceil(progress_features * @bar_width)

        %{release: release,
          date: to_string(date_c),
          num_issues: num_issues,
          fixed: fixed,
          bugs: bugs,
          features: features,
          green: "width:" <> to_string(green) <> "px;" <>
                 "height:" <> to_string(height) <>"px;display:inline-block",
          red: "width:" <> to_string(red) <> "px;" <>
               "height:" <> to_string(height) <>
               "px;display:inline-block;margin-left:-5px",
          blue: "width:" <> to_string(blue) <> "px;" <>
                "height:" <> to_string(height) <>
                "px;display:inline-block;margin-left:-5px"}
      end

    render(conn, :home, release_status: release_status)
  end


  def jira_count(jql_template, release) do
    jql = %{jql: jql_template <> release}

    {:ok, {_, _, body}} =
      :httpc.request(:post,
                     {@jira_url,
                      [{~c"Authorization",
                        "Basic " <> Base.encode64("USER:" <>
                        @atlassian_token)}],
                      ~c"application/json",
                      Jason.encode!(jql)},
                      [], [])
    %{"count" => count} = Jason.decode!(body)

    count
  end
end
