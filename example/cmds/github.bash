init() {
    deps-require jq
    
    cmd-export gh-orgs
    env-import GITHUB_TOKEN
    env-import PAGE_SIZE 5
}

gh-orgs() {
    declare desc="Lists your GithHub organizations"

    : ${GITHUB_TOKEN:? go to https://github.com/settings/tokens to create one}
    curl -s \
        -H "Authorization: Bearer $GITHUB_TOKEN" \
        https://api.github.com/user/orgs?per_page=$PAGE_SIZE \
          | jq ".[].login" -r

}
