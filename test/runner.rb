#!/usr/bin/ruby

Dir.chdir(File.dirname(__FILE__))

TERMINAL_COLUMNS = `stty size`.split(" ").last.to_i

require 'test/unit'

# Re-initialise regression files (copy current to expect)
if ARGV.shift=='-i'
  Dir.chdir('regression')
  print `rm -v *.expect`
  print `rename 's/tags$/tags.expect/g' *.tags`
  print `rename 's/TAGS$/TAGS.expect/g' *.TAGS`
  exit
end

# run regression tests

def regression_test basedir,file,switches=''
  rtags = 'ruby '+basedir+'/bin/rtags'+' '+switches
  datafn = basedir+'/test/regression/'+File.basename(file)
  cmd = "#{rtags} #{file}"
  puts
  puts
  puts "=" * TERMINAL_COLUMNS
  puts "Difference between (emacs) #{datafn}.TAGS and #{datafn}.TAGS.expect:"
  print `#{cmd} --quiet -f #{datafn}.TAGS`
  print `colordiff -u --minimal #{datafn}.TAGS.expect #{datafn}.TAGS`
  puts
  puts "=" * TERMINAL_COLUMNS
  puts "Difference between (vi) #{datafn}.tags and #{datafn}.tags.expect:"
  print `#{cmd} --vi --quiet -f #{datafn}.tags`
  print `colordiff -u --minimal #{datafn}.tags.expect #{datafn}.tags`
  puts
  puts

end

$stderr.print "Begin regression tests..."
basedir = '..'
files = Dir.glob("data/*")
files.each do | file |
  regression_test basedir,file
end
regression_test basedir,'recurse','-R'
$stderr.print "\nFinalised regression tests\n"
