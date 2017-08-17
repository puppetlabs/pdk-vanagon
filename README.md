# Puppet Development Kit (PDK) Packaging

* [Packaging Pipelines](https://jenkins-master-prod-1.delivery.puppetlabs.net/view/pdk/)


## Promoting and releasing changes to puppetlabs/pdk repo into new packages

1. Choose the upstream pdk SHA that you want to release. Optionally, follow the pdk's [release process](https://github.com/puppetlabs/pdk/blob/master/CONTRIBUTING.md#release-process) to create a public gem release.
2. Edit `configs/components/rubygem-pdk.json`. Update the `ref` to point to the ref that you want to promote and the `version` to match the version of the gem which is built by that ref.
3. Choose the upstream pdk-module-template SHA that you want to release.
4. Edit `configs/components/pdk-module-template.json`. Update the `ref` in the JSON file to point to the ref that you want to promote.
3. Commit, PR, and merge this change.
4. If you want this to be a long-lived build (e.g. a new release candidate):
    1. Create a new tag conforming to the scheme `X.Y.Z.0` where X.Y.Z matches the new version of the `pdk` gem. For example: `git tag -s 1.2.3.0 -m 'Release 1.2.3.0'`
    2. Push new tag to upstream puppetlabs/puppet-sdk-vanagon repo.
5. [Trigger a new build](https://jenkins-master-prod-1.delivery.puppetlabs.net/view/puppet-sdk/job/platform_puppet-sdk_pdk-van-init_master/build?delay=0sec) with default params.
6. Once the Jenkins jobs are finished, your new packages will appear in [builds.delivery.p.n](http://builds.delivery.puppetlabs.net/pdk/) with either the tag you attached to your new commit or the SHA of your `puppet-sdk-vanagon` (not `pdk`) commit.
7. Optional: If the packages were tagged with a version, use the [S3 ship job](http://jenkins-compose.delivery.puppetlabs.net/job/puppetlabs-pdk_s3-ship/) to sign and ship the packages to S3. The REF parameter receives the puppet-sdk-vanagon tag to ship. RE's CGI script (see RE-9094) will pick up the new version.
8. After pushing a release to S3, send out a Release Announcement
9. Celebrate

## Promoting changes to puppetlabs/pdk-module-temlate into new packages

## Building new packages for any other changes

