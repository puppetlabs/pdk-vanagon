# Puppet Development Kit (PDK) Packaging

This repo contains all the packaging scripts to build the native PDK packages across various platforms.

* [Internal Packaging Pipelines](https://jenkins-master-prod-1.delivery.puppetlabs.net/view/pdk/)

## Promoting and releasing new packages

1. Choose the upstream pdk SHA that you want to release. Optionally, follow the pdk's [release process](https://github.com/puppetlabs/pdk/blob/master/CONTRIBUTING.md#release-process) to create a public gem release.
2. PDK merges to master are automatically promoted into pdk-vanagon with [this jenkins job](https://jenkins-master-prod-1.delivery.puppetlabs.net/view/PDK/job/platform_pdk-vanagon-promotion_pdk-van-promote_master/).
3. Make sure the correct `ref` and `version` have landed in `configs/components/rubygem-pdk.json`.
4. Edit `resources/files/windows/PuppetDevelopmentKit/PuppetDevelopmentKit.psd1`. Update the `version` of this Powershell wrapper to the release version.
5. Edit `configs/components/pdk-module-template.json`. Update the `ref` to point to the desired SHA from the [pdk-module-template](https://github.com/puppetlabs/pdk-module-template).
6. Commit, PR, and merge these changes.
7. If you want this to be a long-lived build (e.g. a new release candidate):
    1. Create a new tag conforming to the scheme `X.Y.Z.N` where X.Y.Z matches the new version of the `pdk` gem, and N is the build number for this package, starting with zero ("0"). For example: `git tag -s 1.2.3.0 -m 'Release 1.2.3.0'`
    2. Push new tag to upstream puppetlabs/pdk-vanagon repo.
8. [Trigger a new build](https://jenkins-master-prod-1.delivery.puppetlabs.net/view/PDK/job/platform_pdk_pdk-van-init_master/build?delay=0sec) with default params.
9. Once the Jenkins jobs are finished, your new packages will appear in [builds.delivery.p.n](http://builds.delivery.puppetlabs.net/pdk/) with either the tag you attached to your new commit or the SHA of your `pdk-vanagon` (not `pdk`) commit.
10. Optional: If the packages were tagged with a version, use the [S3 ship job](http://jenkins-compose.delivery.puppetlabs.net/job/puppetlabs-pdk_s3-ship/) to sign and ship the packages to S3. The REF parameter receives the pdk-vanagon tag to ship. RE's CGI script (see RE-9094) will need modifications to pick up the new version.
11. After pushing a release to S3, send out a Release Announcement
12. Notify symantec about the new version via https://submit.symantec.com/false_positive/ to avoid recurrence of PDK-527
13. Celebrate

## Promoting changes to puppetlabs/pdk-module-temlate into new packages

1. Edit `configs/components/pdk-module-template.json`. Update the `ref` to point to the desired SHA from the [pdk-module-template](https://github.com/puppetlabs/pdk-module-template).

See https://tickets.puppetlabs.com/browse/PDK-578

## Building new packages for any other changes

### Local package build

* Clone this repo
* Change the `configs/components/rubygem-pdk.json` to point to the SHA or ref and version you want to test/build.
* Change the `configs/components/pdk-module-template.json` to point to the SHA or ref and version you want to test/build.
* `bundle install`
* `bundle exec build pdk ubuntu-16.04-amd64,windows-2012r2-x64,el-7-x86_64`

For more info see https://github.com/puppetlabs/vanagon

