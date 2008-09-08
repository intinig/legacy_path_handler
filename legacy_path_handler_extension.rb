require_dependency 'application'

class LegacyPathHandlerExtension < Radiant::Extension
  version "0.1"
  description "Handles 301 redirection to avoid breaking old URLs"
  url "http://tempe.st/legacy_path_handler"

  class PathHandlerStore
    def self.paths
      @path_handlers_source ||= File.readlines(File.join(File.dirname(__FILE__), 'config/path_handlers.txt'))
      if @path_handlers.blank?
        @path_handlers = {}
        @path_handlers_source.each do |line|
          @path_handlers[line.split[0]] = line.split[1]
        end
      end
      @path_handlers
    end      
  end
    
  def activate
        
    SiteController.class_eval do
      before_filter :handle_legacy_paths
      
      protected
      def handle_legacy_paths
        if (destination = PathHandlerStore.paths[params[:url].join('/')])
          headers["Status"] = "301 Moved Permanently"
          redirect_to destination
        end
      end
    end
  end
    
end