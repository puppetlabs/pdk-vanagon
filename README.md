# Puppet Development Kit (PDK) Packaging

* [Packaging Pipelines](https://jenkins-master-prod-1.delivery.puppetlabs.net/view/pdk/)


## Promoting changes to puppetlabs/pdk repo into new packages

1. Edit `configs/components/rubygem-pdk.rb` and `configs/components/rubygem-pdk.json`. Update the `ref` in the JSON file to point to the ref that you want to promote. Update the `version` in the Ruby file to match the version of the gem which is built by that ref.
2. Commit, PR, and merge this change.
3. If you want this to be a long-lived build (e.g. a new release candidate):
    1. Create a new tag conforming to the scheme `X.Y.Z.0` where X.Y.Z matches the new version of the `pdk` gem. For example: `git tag -s 1.2.3.0 -m 'Release 1.2.3.0'`
    2. Push new tag to upstream puppetlabs/puppet-sdk-vanagon repo.
4. [Trigger a new build](https://jenkins-master-prod-1.delivery.puppetlabs.net/view/puppet-sdk/job/platform_puppet-sdk_pdk-van-init_master/build?delay=0sec) with default params.
5. Once the Jenkins jobs are finished, your new packages will appear in [](http://builds.delivery.puppetlabs.net/pdk/) with either the tag you attached to your new commit or the SHA of your `puppet-sdk-vanagon` (not `pdk`) commit.

## Promoting changes to puppetlabs/pdk-module-temlate into new packages

## Building new packages for any other changes

