require "http/server"
require "path"
require "mime"
require "option_parser"

# TODO: Write documentation for `Hostcraft`
module Hostcraft
  VERSION = "0.1.0"

  macro serve_html(domain, filepath)
    file_path = "./www/#{{{domain}}}#{{{filepath}}}.html"
    file_content = ""
    if File.exists?(file_path)
      file_content = File.read(file_path)
    else
      file_content = File.read("./www/#{{{domain}}}/404.html")
    end
    file_content
  end

  macro serve_file(domain, filepath)
    file_path = "./www/#{{{domain}}}#{{{filepath}}}"
    file_content = ""
    if File.exists?(file_path)
      file_content = File.read(file_path)
    else
      file_content = File.read("./www/#{{{domain}}}/404.html")
    end
    file_content
  end

  server = HTTP::Server.new do |context|
    domain = context.request.host

    path = Path[context.request.path]

    if path.extension != ""
      mime = MIME.from_extension?(path.extension) if path.extension != ""
      context.response.content_type = mime.as(String)
      context.response.print serve_file(domain, path)
    else
      context.response.content_type = "text/html"
      if context.request.path != "/"
        context.response.print serve_html(domain, path)
      else
        context.response.print serve_html(domain, "/index")
      end
    end
  end

  OptionParser.parse do |parser|
    parser.banner = "Welcome to The Beatles App!"

    parser.on "-v", "--version", "Show version" do
      puts "version 1.0"
      exit
    end
    parser.on "-h", "--help", "Show help" do
      puts parser
      exit
    end
    parser.on "-p", "--port", "Bind port" do
      server.bind_tcp "0.0.0.0", 80
      puts "Hostcraft is up..."
      server.listen
    end
  end
end
