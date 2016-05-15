if ($env:appveyor_repo_tag -eq "true") {
    echo "Tag is being pushed"
}
elseif ($env:NEW_TAG -eq "none") {
    $version = Select-String -Path Cargo.toml -pattern  '\d{1,3}.\d{1,3}.\d{1,3}' | Select-Object -First 1
    $version = $version.Line.split('=')[1].trim()
    $version = $version.substring(1, $version.Length-2)
    git tag -a $version -m "$version"

    if ($LASTEXITCODE  -eq 0) {
        git config --global credential.helper store
        Add-Content "$env:USERPROFILE\.git-credentials" "https://$($env:git_token):x-oauth-basic@github.com\n"
        git config --global user.name "AppVeyor bot"
        git config --global user.email "douman@gmx.se"
        git config remote.origin.url "https://$($env:git_token)@github.com/DoumanAsh/rusty-eushully.git"

        # Use AppVeyor API to set variables properly within one build job
        Set-AppveyorBuildVariable -name "NEW_TAG" -Value $version
        Set-AppveyorBuildVariable -Name "APPVEYOR_REPO_TAG_NAME" -Value $version
        Set-AppveyorBuildVariable -Name "APPVEYOR_REPO_TAG" -Value "true"
    }
}
# We saved tag name in first build
else {
    Set-AppveyorBuildVariable -Name "APPVEYOR_REPO_TAG_NAME" -Value $env:NEW_TAG
    Set-AppveyorBuildVariable -Name "APPVEYOR_REPO_TAG" -Value "true"
}
