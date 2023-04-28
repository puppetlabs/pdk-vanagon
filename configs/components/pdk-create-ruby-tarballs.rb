component "pdk-create-ruby-tarballs" do |pkg, settings, platform|
  # Can only create the tarballs AFTER all of them gemfiles have been pruned
  pkg.build_requires 'gem-prune'

  # We only create the tarballs on Windows right now
  if platform.is_windows?
    pkg.add_source('file://resources/files/install-tarballs/extract_all.rb')
    pkg.add_source('file://resources/files/install-tarballs/remove_all.rb')
    pkg.directory "#{settings[:datadir]}/install-tarballs"
    # Unlike other examples, where the path would be '../<file>' we use the current workding directory.  This is because
    # even though we add a source as above, because it is not a gem or tar etc., the component has nothing to extract therefore
    # we don't end up in a component directory
    pkg.install_file 'extract_all.rb', "#{settings[:datadir]}/install-tarballs/extract_all.rb"
    pkg.install_file 'remove_all.rb', "#{settings[:datadir]}/install-tarballs/remove_all.rb"

    pkg.build do
      build_commands = []

      # Create the destination directory incase it doesn't exist already
      build_commands << "mkdir -p #{settings[:datadir]}/install-tarballs"
      build_commands << "pushd #{settings[:install_root]}"

      delete_dirs = []
      # Tar up the base ruby. This will exclude the ruby runtime as we need that for the extraction
      dirs = ["private/puppet/ruby/#{settings[:ruby_api]}", "share/cache/ruby/#{settings[:ruby_api]}"]
      build_commands << "#{platform.tar} --create --gzip --file share/install-tarballs/ruby-#{settings[:ruby_version]}.tgz --directory=. " + dirs.join(" ")
      delete_dirs.concat(dirs)

      settings[:additional_rubies].each do |_, local_settings|
        dirs = ["private/puppet/ruby/#{local_settings[:ruby_api]}", "share/cache/ruby/#{local_settings[:ruby_api]}", "private/ruby/#{local_settings[:ruby_version]}"]

        build_commands << "mkdir -p #{dirs.join(' ')}"

        # Tar up the rest. This will include the ruby runtime as well
        build_commands << "#{platform.tar} --create --gzip --file share/install-tarballs/ruby-#{local_settings[:ruby_version]}.tgz --directory=. " + dirs.join(" ")
        delete_dirs.concat(dirs)
      end

      # We delete the source directories AFTER tarring to make debugging easier if something goes wrong.
      delete_dirs.each { |dir| build_commands << "rm -rf #{dir}" }

      build_commands << 'popd'

      build_commands
    end
  end
end
