# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/log_parser'
require "test/unit/assertions"
include Test::Unit::Assertions

class LogParserTest < Minitest::Test

  def self.run_all_test
    self.every_url_one_visit
    self.every_url_more_visit_but_one_unique
    self.every_url_more_visit_and_more_unique
    self.invalid_ip_given
    self.no_logs
  end

  def self.every_url_one_visit

    testData = "/help_page/1 1.1.1.1\n" \
               "/contact 2.2.2.2\n" \
               "/home 3.3.3.3\n" \
               "/about/2 4.4.4.4\n" \
               "/index 5.5.5.5\n"
    File.write("webserver.log", testData)

    processLogParser = LogParser.processing

    url_visit = processLogParser[0]
    assert_equal 5, processLogParser[0].size
    assert_equal [ "/help_page/1" , 1 ], url_visit[0]
    assert_equal [ "/contact" , 1 ], url_visit[1]
    assert_equal [ "/home" , 1 ], url_visit[2]
    assert_equal [ "/about/2" , 1 ], url_visit[3]
    assert_equal [ "/index" , 1 ], url_visit[4]

    url_unique_visit = processLogParser[1]
    assert_equal [ "/help_page/1" , 1 ], url_unique_visit[0]
    assert_equal [ "/contact" , 1 ], url_unique_visit[1]
    assert_equal [ "/home" , 1 ], url_unique_visit[2]
    assert_equal [ "/about/2" , 1 ], url_unique_visit[3]
    assert_equal [ "/index" , 1 ], url_unique_visit[4]
  end

  def self.every_url_more_visit_but_one_unique

    testData = "/help_page/1 1.1.1.1\n" \
               "/help_page/1 1.1.1.1\n" \
               "/contact 2.2.2.2\n" \
               "/contact 2.2.2.2\n" \
               "/home 3.3.3.3\n" \
               "/home 3.3.3.3\n" \
               "/about/2 4.4.4.4\n" \
               "/about/2 4.4.4.4\n" \
               "/index 5.5.5.5\n" \
               "/index 5.5.5.5\n"
    File.write("webserver.log", testData)

    processLogParser = LogParser.processing

    url_visit = processLogParser[0]
    assert_equal 5, processLogParser[0].size
    assert_equal [ "/help_page/1" , 2 ], url_visit[0]
    assert_equal [ "/contact" , 2 ], url_visit[1]
    assert_equal [ "/home" , 2 ], url_visit[2]
    assert_equal [ "/about/2" , 2 ], url_visit[3]
    assert_equal [ "/index" , 2 ], url_visit[4]

    url_unique_visit = processLogParser[1]
    assert_equal [ "/help_page/1" , 1 ], url_unique_visit[0]
    assert_equal [ "/contact" , 1 ], url_unique_visit[1]
    assert_equal [ "/home" , 1 ], url_unique_visit[2]
    assert_equal [ "/about/2" , 1 ], url_unique_visit[3]
    assert_equal [ "/index" , 1 ], url_unique_visit[4]
    end

  def self.every_url_more_visit_and_more_unique

    testData = "/help_page/1 1.1.1.1\n" \
               "/help_page/1 1.1.1.10\n" \
               "/contact 2.2.2.2\n" \
               "/contact 2.2.2.20\n" \
               "/home 3.3.3.3\n" \
               "/home 3.3.3.30\n" \
               "/about/2 4.4.4.4\n" \
               "/about/2 4.4.4.40\n" \
               "/index 5.5.5.5\n" \
               "/index 5.5.5.50\n" \
               "/index 5.5.5.100\n"
    File.write("webserver.log", testData)

    processLogParser = LogParser.processing

    url_visit = processLogParser[0]
    assert_equal 5, processLogParser[0].size
    assert_equal [ "/help_page/1" , 2 ], url_visit[0]
    assert_equal [ "/contact" , 2 ], url_visit[1]
    assert_equal [ "/home" , 2 ], url_visit[2]
    assert_equal [ "/about/2" , 2 ], url_visit[3]
    assert_equal [ "/index" , 3 ], url_visit[4]

    url_unique_visit = processLogParser[1]
    assert_equal [ "/help_page/1" , 2 ], url_unique_visit[0]
    assert_equal [ "/contact" , 2 ], url_unique_visit[1]
    assert_equal [ "/home" , 2 ], url_unique_visit[2]
    assert_equal [ "/about/2" , 2 ], url_unique_visit[3]
    assert_equal [ "/index" , 3 ], url_unique_visit[4]
  end

  def self.invalid_ip_given

    testData = "/help_page/1 111.111.111.111\n" \
               "/contact 222.222.222.222\n" \
               "/home 333.333.333.333\n" \
               "/about/2 444.444.444.444\n" \
               "/index 555.555.555.5\n"
    File.write("webserver.log", testData)

    processLogParser = LogParser.processing

    url_visit = processLogParser[0]
    url_unique_visit = processLogParser[1]

    assert_equal 2, url_visit.size
    assert_equal 2, url_unique_visit.size
  end

  def self.no_logs

    testData = ""
    File.write("webserver.log", testData)

    processLogParser = LogParser.processing

    url_visit = processLogParser[0]
    url_unique_visit = processLogParser[1]

    assert_equal 0, url_visit.size
    assert_equal 0, url_unique_visit.size
  end

end

LogParserTest.run_all_test