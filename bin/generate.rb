require 'redcarpet'
require 'haml'
require 'fileutils'

renderer = Redcarpet::Render::HTML.new(render_options = {})
markdown = Redcarpet::Markdown.new(renderer, extensions = { :tables => true })

# Render and write Post files
Dir.glob('.posts/**/*.md').each do |filepath|
  file = File.open(filepath, 'rb')

  # Let's expect that the post Markdown files exist in a subdirectory that the
  # rendered version should exists in on the server.  We'll assume that we only
  # have one level of subdirectory depth.

  # This looks like 'date_subdirectory/post_name.md'
  date_subdirectory_and_post_name = filepath.split('.posts/')[1]

  date_subdirectory = date_subdirectory_and_post_name.split('/')[0]

  post_name = File.basename(file, File.extname(file))

  post_content = markdown.render(file.read) || ''

  post = Haml::Engine
    .new(File.open('layout/template.html.haml').read)
    .render
    .gsub('<!-- ~~~CONTENT_PLACEHOLDER~~~ -->', post_content)

  if post_name == 'index'
    File.write("index.html", post)
  else
    post_name_directory = "#{date_subdirectory}/#{post_name}"
    FileUtils.mkdir_p(post_name_directory) unless File.directory? post_name_directory
    File.write("#{post_name_directory}/index.html", post)
  end
end

# Render and write Page files
Dir.glob('.pages/**/*.md').each do |filepath|
  file = File.open(filepath, 'rb')

  # Let's expect that the page Markdown files exist in a subdirectory that the
  # rendered version should exists in on the server.  We'll assume that we only
  # have one level of subdirectory depth.

  # This looks like 'subdirectory/page_name.md'
  subdirectory_and_page_name = filepath.split('.pages/')[1]

  subdirectory = subdirectory_and_page_name.split('/')[0]

  page_name = File.basename(file, File.extname(file))

  page_content = markdown.render(file.read) || ''

  page = Haml::Engine
    .new(File.open('layout/template.html.haml').read)
    .render
    .gsub('<!-- ~~~CONTENT_PLACEHOLDER~~~ -->', page_content)

  if page_name == 'index'
    File.write("index.html", page)
  else
    page_name_directory = "#{subdirectory}/#{page_name}"
    FileUtils.mkdir_p(page_name_directory) unless File.directory? page_name_directory
    File.write("#{page_name_directory}/index.html", page)
  end
end
