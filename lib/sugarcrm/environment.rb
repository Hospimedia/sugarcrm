require 'singleton'

module SugarCRM; class Environment
  include Singleton
  
  attr_reader :config
  
  def initialize
    @config = {}
    
    default_config_path = File.join(File.dirname(__FILE__), 'config', 'config.yaml')
    load_config default_config_path if File.exists? default_config_path
  end
  
  def load_config(path)
    config = YAML.load_file(path)
    config["config"].each{|k,v|
      @config[k.to_sym] = v
    }
  end
  
  # load all the monkey patch files in the provided folder
  def monkey_patch_folder=(folder, dirstring=nil)
    path = File.expand_path(folder, dirstring)
    Dir[File.join(path, '**', '*.rb').to_s].each { |f| load(f) }
  end
  
  def self.method_missing(method_id, *args, &block)
    self.instance.send(method_id, *args, &block)
  end
end; end