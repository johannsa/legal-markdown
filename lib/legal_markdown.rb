#!/usr/bin/env ruby
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'legal_markdown/version.rb'
require 'legal_markdown/make_yaml_frontmatter.rb'
require 'legal_markdown/legal_to_markdown.rb'
require 'optparse'

module LegalMarkdown

  def self.parse(*args)

    config={}
    config[:input] = {}
    config[:output] = {}

    args, config = optsparse args, config

    if args.size >= 1
      caller args, config
    else
      puts opt_parser
    end

  end

  def self.optsparse args, config
    args = args_guard args

    opt_parser = OptionParser.new do |opt|
      opt.banner = "Usage: legal2md [commands] [input_file] [output_file]"
      opt.separator ""
      opt.separator "[input_file] can be a file or use \"-\" for STDIN"
      opt.separator "[output_file] can be a file or use \"-\" for STDOUT"
      opt.separator ""
      opt.separator "Specific Commands:"

      config[:output][:markdown] = false
      opt.on( '-m', '--to-markdown', 'Parse the Legal Markdown file and produce a Text document (md, rst, txt, etc.).' ) do
        config[:output][:markdown] = true
      end

      config[:output][:jason] = false
      opt.on( '-j', '--to-json', 'Parse the Legal Markdown file and produce a JSON document.' ) do
        config[:output][:jason] = true
      end

      config[:verbose] = false
      opt.on('--verbose', 'Debug legal_markdown. Only works with output options, not with headers switch.') do
        config[:verbose] = true
      end

      config[:headers] = false
      opt.on( '-d', '--headers', 'Make the YAML Frontmatter automatically.' ) do
        config[:headers] = true
      end

      if args.include? :headers
        config[:headers] = true
        args.delete :headers
      end

      if args.include?( :to_json ) || (begin args[-1][/\.json/]; rescue; end;)
        config[:output][:jason] = true
        args.delete(:to_json) if args.include?( :to_json )
      end

      if args.include? :to_markdown || (begin args[-1][/\.md|\.markdown/]; rescue; end;)
        config[:output][:markdown] = true
        args.delete :markdown
      end

      opt.on( '-v', '--version', 'Display the gem\'s current version that you are using.' ) do
        puts 'Legal Markdown version ' + LegalMarkdown::VERSION
        exit
      end

      opt.on( '-h', '--help', 'Display this screen at any time.' ) do
        puts opt_parser
        exit
      end

      opt.separator ""
      opt.separator "Notes:"
      opt.separator "If the command is --headers or with --to-markdown you can enter one file to be parsed if you wish."
      opt.separator "When these commands are called with only one file I will set the input_file and the output_file to be the same."
      opt.separator "The other commands will require the original legal_markdown file and the output file."
      opt.separator "There is no need to explicitly enter the --to-json if your output_file is *.json I can handle it."
      opt.separator "There is no need to explicitly enter the --to-markdown if your output_file is *.md or *.markdown I can handle it."
      opt.separator ""
    end
    opt_parser.parse!(args)

    return args, config
  end

  def self.args_guard args
    if args.size == 1 && args.first.class == Array
      args = args.first
    end
    args
  end

  def self.caller args, config
    if config[:headers]
      MakeYamlFrontMatter.new(args)
    elsif config[:output][:jason]
      LegalToMarkdown.parse_jason(args, config[:verbose])
    elsif config[:output][:markdown] || args.size <= 2
      LegalToMarkdown.parse_markdown(args, config[:verbose])
    end
  end
end

