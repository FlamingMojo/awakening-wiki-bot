# frozen_string_literal: true
require 'optparse'

DowngradeError = Class.new(ArgumentError)
NoRegistryError = Class.new(ArgumentError)

registry = ENV['DOCKER_REGISTRY_URL']
raise NoRegistryError.new('A registry is required to build and deploy') unless registry

current_version = Gem::Version.new(File.read('./.image-version'))
next_patch = Gem::Version.new((current_version.segments.tap {|v| v[-1] += 1}).join('.'))
next_minor = Gem::Version.new("#{current_version.bump}.0")
next_major = Gem::Version.new("#{current_version.segments.first + 1}.0.0")

options = {}
OptionParser.new do |option|
  option.on('--push', "Push the image to the registry") { |opt| options[:version] = opt }
  option.on('-p', '--patch', "Upgrade the patch version to #{next_patch}") { options[:version] = next_patch }
  option.on('-m', '--minor', "Upgrade the minor version to #{next_minor}") { options[:version] = next_minor }
  option.on('-M', '--major', "Upgrade the major version to #{next_major}") { options[:version] = next_major }
  option.on('--force-version VERSION', "Force a new version release higher than #{current_version}") do |opt|
    options[:version] = Gem::Version.new(opt)
    raise DowngradeError.new("Version must be higher than #{current_version}") if options[:version] <= current_version
  end

  option.on('--push', 'Push the new image to the registry') { options[:push] = true }
end.parse!

if options[:version]
  puts "Building new image version #{options[:version]} ..."
  successful_build = system("docker build -t #{registry}/awakening-wiki-bot -t #{registry}/awakening-wiki-bot:#{options[:version]} .")

  if successful_build
    puts 'Build successful.'
    File.write('./.image-version', options[:version].to_s)
    current_version = options[:version]
  else
    puts 'Build unsuccessful :('
  end
end

if options[:push]
  puts "Pushing image to #{registry} ..."
  successful_push = system("docker push #{registry}/awakening-wiki-bot:#{current_version}") &&
    system("docker push #{registry}/awakening-wiki-bot")

  if successful_push
    puts 'Push successful.'
  else
    puts 'Push unsuccessful :('
  end
end
