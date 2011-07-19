require 'fileutils'
require 'yaml'

vimeo_info = YAML.load(File.open('vimeo.yaml').read)
vimeo_info.each do |event_id, info|
  event_file = event_id + '.yaml'
  if File.exists?(event_file)
    event = YAML.load(File.open(event_file).read)
    vimeo_url = info[:url]
    vimeo_id = vimeo_url.sub(%r{http://vimeo.com/}, '')
    backup_file = event_file + '~'
    FileUtils.cp(event_file, backup_file)
    begin
      File.open(event_file, 'a') {|f| f.puts('vimeo_id: ' + vimeo_id) }
    rescue => e
      $stderr.puts(e.message);
      FileUtils.mv(backup_file, event_file)
    end
  end
end
