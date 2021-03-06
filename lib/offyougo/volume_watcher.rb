require 'set'

module Offyougo
  module VolumeWatcher
    class Base
      def initialize(sender)
        @sender = sender
        @running = true
        @volumes = Set.new
      end

      def start
        Thread.new do
          while @running
            volumes = scan
            added = volumes - @volumes
            removed = @volumes - volumes
            if added
              added.each do |volume|
                @sender.volume_added(volume) if @running
              end
            end
            if removed
              removed.each do |volume|
                @sender.volume_removed(volume) if @running
              end
            end
            @volumes = volumes
            sleep 1
          end
        end.run.join
      end

      def stop
        @running = false
      end
    end

    class MacOSX < Base
      def scan
        Set.new Dir.glob('/Volumes/*').select {|f| File.directory? f}
      end
    end
  end
end