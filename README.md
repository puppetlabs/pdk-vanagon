# Puppet Development Kit (PDK) Packaging

[![Code Owners](https://img.shields.io/badge/owners-DevX--team-blue)](https://github.com/puppetlabs/provision/blob/main/CODEOWNERS)
![GitHub release (latest by date)](https://img.shields.io/github/v/release/puppetlabs/pdk-vanagon)

## Table of contents

1.  [Description](#description)
2.  [Usage](#usage)
    i.  [Promoting and releasing new packages](#promoting-and-releasing-new-packages)
    ii. [Promoting changes to puppetlabs/pdk-templates into new packages](#promoting-changes-to-puppetlabspdk-templates-into-new-packages)
    iii.[Building new local packages for any other changes](#building-new-local-packages-for-any-other-changes)
3.  [Development](#development)

## Description

The purpose of this tool is to enable PDK native package building across all of our supported platforms. 

This repository contains all the necessary scripts to build these packages and push them into our internal Jenkins pipelines.

* [Internal Packaging Pipelines](https://jenkins-master-prod-1.delivery.puppetlabs.net/view/PDK/)

## Usage
### Promoting and releasing new packages

**NOTE: Please refer to the instructions in the [PDK Release Ticket Template](https://github.com/puppetlabs/winston/#pdk-release-tickets) for the most up-to-date instructions on releasing a new version of the PDK**

1. Choose the upstream pdk SHA that you want to release. Optionally, follow the pdk's [release process](https://github.com/puppetlabs/pdk/blob/main/CONTRIBUTING.md#release-process) to create a public gem release. **You can ignore this step if you want to take the latest commit on `main` of the [pdk](https://github.com/puppetlabs/pdk) and [pdk-templates](https://github.com/puppetlabs/pdk-templates) repos.**
2. PDK merges to main are automatically promoted into pdk-vanagon with [this jenkins job](https://jenkins-master-prod-1.delivery.puppetlabs.net/view/PDK/job/platform_pdk-vanagon-promotion_pdk-van-promote_master/).
3. Make sure the correct `ref` and `version` have landed in `configs/components/rubygem-pdk.json`.
4. Make sure the correct `ref` has landed in `configs/components/pdk-templates.json`. This will have been bumped to the latest SHA from [pdk-templates](https://github.com/puppetlabs/pdk-templates) by Jenkins.
5. Create a tag for the RC build: `git tag -a -m x.y.z.0-rc.# x.y.z.0-rc.#` e.g. (`git tag -a -m 1.18.0.0-rc.1 1.18.0.0-rc.1`)
6. [Trigger a new build](https://jenkins-master-prod-1.delivery.puppetlabs.net/view/PDK/job/platform_pdk_pdk-van-init_master/build?delay=0sec) with default params.
7. Once the Jenkins jobs are finished, your new packages will appear in [builds.delivery.p.n](http://builds.delivery.puppetlabs.net/pdk/) with either the tag you attached to your new commit or the SHA of your `pdk-vanagon` (not `pdk`) commit.
8. Optional: If the packages were tagged with a version, use the [S3 ship job](http://jenkins-compose.delivery.puppetlabs.net/job/puppetlabs-pdk_s3-ship/) to sign and ship the packages to S3. The REF parameter receives the pdk-vanagon tag to ship. RE's CGI script (see RE-9094) will need modifications to pick up the new version.
9. After pushing a release to S3, send out a Release Announcement
10. Celebrate

### Promoting changes to puppetlabs/pdk-templates into new packages

1. Edit `configs/components/pdk-templates.json`. Update the `ref` to point to the desired SHA from the [pdk-templates](https://github.com/puppetlabs/pdk-templates).

See https://tickets.puppetlabs.com/browse/PDK-578

### Building new local packages for any other changes

* Clone this repo
* Change the `configs/components/rubygem-pdk.json` to point to the SHA or ref and version you want to test/build.
* Change the `configs/components/pdk-templates.json` to point to the SHA or ref and version you want to test/build.
* `bundle install`
* `bundle exec build pdk ubuntu-16.04-amd64,windows-2012r2-x64,el-7-x86_64`

For more info see https://github.com/puppetlabs/vanagon

## Development

This tool is owned by DevX, part of the Content and Tooling (CAT) team.

This is an open-source project and, as such, Issue reports and Pull Requests are always welcome in our GitHub repository.

If you have any questions, or simply want to contact us regarding open-source contributions, you can find us in the official community Slack server. We host an office hours (Q&A) session biweekly on Tuesdays at 15:00 (BST).
