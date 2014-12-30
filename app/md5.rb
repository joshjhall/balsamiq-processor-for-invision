#!usr/bin/ruby

require 'digest'

# Get the index of the file
def getMD5(f)
  if File.exists? f
    # Get the MD5 hash by reading blocks, so we don't need to open the file in memory
    md5 = Digest::MD5.file(f).hexdigest
  
    # return the hash
    md5.to_s
  else
    false
  end
end
