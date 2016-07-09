#!/usr/bin/env ruby
# Xronos Scheduler - structured scheduling program.
# Copyright (C) 2009-2016 John Winters
# Portions Copyright (C) 2014-16 Abingdon School
# See COPYING and LICENCE in the root directory of the application
# for more information.

require 'optparse'
require 'optparse/date'
require 'ostruct'
require 'yaml'
require 'nokogiri'

#
#  The following line means I can just run this as a Ruby script, rather
#  than having to do "rails r <script name>"
#
require_relative '../../config/environment'

#
#  The idea here is to make as much as possible of this program platform
#  agnostic.  It will define some data structures/classes, and it's then
#  up to the individual platform implementations to flesh them out.  Any
#  processing which is common between platforms should be shared.
#

#
#  Support files.
#
require_relative 'misimport/misrecord.rb'
#
#  Actual identifiable database things.
#
require_relative 'misimport/mispupil.rb'

#
#  Now we actually access the database to discover what MIS is in use.
#  That will dictate what further files to include.
#
#  Note that at this stage we are still merely defining our classes.
#  Bringing in the actual data and instantiating the objects will
#  come later.
#

current_mis = Setting.current_mis
if current_mis
  if current_mis == "iSAMS"
    require_relative 'isams/dateextra.rb'
    require_relative 'isams/misloader.rb'
    require_relative 'isams/creator.rb'
    require_relative 'isams/mispupil.rb'
  elsif current_mis == "SchoolBase"
  else
    raise "Don't know how to handle #{current_mis} as our current MIS."
  end
else
  raise "No current MIS configured - can't import."
end


def finished(options, stage)
  if options.do_timings
    puts "#{Time.now.strftime("%H:%M:%S")} finished #{stage}."
  end
end

begin
  options = OpenStruct.new
  options.verbose         = false
  options.full_load       = false
  options.just_initialise = false
  options.send_emails     = false
  options.do_timings      = false
  OptionParser.new do |opts|
    opts.banner = "Usage: misimport.rb [options]"

    opts.on("-i", "--initialise", "Initialise only") do |i|
      options.just_initialise = i
    end

    opts.on("-v", "--verbose", "Run verbosely") do |v|
      options.verbose = v
    end

    opts.on("-f", "--full",
            "Do a full load",
            "(as opposed to incremental.  Doesn't",
            "actually affect what gets loaded, but",
            "does affect when it's loaded from.)") do |f|
      options.full_load = f
    end

    opts.on("--timings",
            "Log the time at various stages in the processing.") do |timings|
      options.do_timings = timings
    end

  end.parse!

  MIS_Loader.new(options) do |loader|
    unless options.just_initialise
      finished(options, "initialisation")
      loader.do_pupils
      finished(options, "pupils")
    end
  end
rescue RuntimeError => e
  puts e
end


