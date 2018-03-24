require "bundler/gem_tasks"

task :default do
  system 'gem uninstall -ax motion.h'
  system 'gem build motion.h.gemspec'
  system 'gem install ./motion.h-0.0.6.gem'
end
