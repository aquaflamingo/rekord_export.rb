require 'pry'

require 'nokogiri'

module RekordExport
  class Converter
    def initialize(rekordbox_xml_path)
      @rekordbox_xml_path = rekordbox_xml_path
    end

    def convert_to_m3u
      doc = parse_rekordbox_xml(@rekordbox_xml_path)
      collection_node = doc.xpath('/DJ_PLAYLISTS/COLLECTION').first
      playlists_node = doc.xpath('/DJ_PLAYLISTS/PLAYLISTS').first

      tracks = extract_tracks_from_collection(collection_node)
      playlists = extract_playlists(playlists_node)

      generate_m3u_files(playlists, tracks)
    end

    def convert_to_itunes
      doc = parse_rekordbox_xml(@rekordbox_xml_path)
      collection_node = doc.xpath('/DJ_PLAYLISTS/COLLECTION').first
      playlists_node = doc.xpath('/DJ_PLAYLISTS/PLAYLISTS').first

      tracks = extract_tracks_from_collection(collection_node)
      playlists = extract_playlists(playlists_node)

      generate_itunes_xml(playlists, tracks)
    end

    private

    def parse_rekordbox_xml(file_path)
      file = File.open(file_path)
      doc = Nokogiri::XML(file)
      file.close
      doc
    end

    def extract_tracks_from_collection(collection_node)
      tracks = {}
      collection_node.xpath('TRACK').each do |track|
        track_id = track.attr('TrackID')
        location = track.attr('Location')
        tracks[track_id] = location
        #
        # tracks[track_id] = location.gsub('file://localhost/', '') # Remove URL prefix
      end
      tracks
    end

    def extract_playlists(playlists_node)
      playlists = []
      playlists_node.xpath('NODE').each do |node|
        extract_playlist_nodes(node, playlists)
      end
      playlists
    end

    def extract_playlist_nodes(node, playlists, current_path = [])
      name = node.attr('Name')
      type = node.attr('Type')

      if type == '1' # Playlist
        current_path << name
        playlist = {
          name: current_path.join(' - '),
          tracks: node.xpath('TRACK').map { |track| track.attr('Key') }
        }
        playlists << playlist
        current_path.pop
      elsif type == '0' # Folder
        current_path << name
        node.xpath('NODE').each do |child_node|
          extract_playlist_nodes(child_node, playlists, current_path)
        end
        current_path.pop
      end
    end

    def generate_m3u_files(playlists, tracks)
      playlists.each do |playlist|
        # Replace unsafe characters in the playlist name
        safe_name = playlist[:name].gsub(/[\/\\]/, '_')
        safe_name.sub!(/^ROOT - /, '') # Remove "ROOT - " prefix  file_name = "#{safe_name}.m3u"
        file_name = "#{safe_name}.m3u"
        File.open(file_name, 'w') do |file|
          file.puts "#EXTM3U"
          playlist[:tracks].each do |track_id|
            track_path = tracks[track_id]
            file.puts track_path if track_path
          end
        end
        puts "Generated #{file_name}"
      end
    end

   def generate_itunes_xml(playlists, tracks)
      builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
        xml.doc.create_internal_subset(
          'plist',
          "-//Apple//DTD PLIST 1.0//EN",
          "http://www.apple.com/DTDs/PropertyList-1.0.dtd"
        )
        xml.plist(version: '1.0') do
          xml.dict do
            xml.key 'Major Version'
            xml.integer '1'
            xml.key 'Minor Version'
            xml.integer '1'
            xml.key 'Date'
            xml.date Time.now.utc
            xml.key 'Tracks'
            xml.dict do
              tracks.each do |track_id, location|
                xml.key track_id
                xml.dict do
                  xml.key 'Track ID'
                  xml.integer track_id
                  xml.key 'Location'
                  xml.string location
                end
              end
            end
            xml.key 'Playlists'
            xml.array do
              playlists.each_with_index do |playlist, index|
                xml.dict do
                  xml.key 'Name'
                  xml.string playlist[:name].sub(/^ROOT - /, '')
                  xml.key 'Playlist ID'
                  xml.integer index + 1
                  xml.key 'Playlist Persistent ID'
                  xml.string "DUMMYID#{index + 1}"
                  xml.key 'All Items'
                  xml.true_
                  xml.key 'Playlist Items'
                  xml.array do
                    playlist[:tracks].each do |track_id|
                      xml.dict do
                        xml.key 'Track ID'
                        xml.integer track_id
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end

      File.open('library.xml', 'w') do |file|
        file.write(builder.to_xml)
      end

      puts 'Generated iTunesMusicLibrary.xml'
    end


    def generate_m3u_files_with_dirs(playlists, tracks)
  playlists.each do |playlist|
    # Replace unsafe characters in the playlist name and remove "ROOT - " prefix
    safe_name = playlist[:name].gsub(/[\/\\]/, '_')
    safe_name.sub!(/^ROOT - /, '')

    # Split the safe_name into directories and filename
    path_elements = safe_name.split(' - ')
    file_name = path_elements.pop
    dir_path = File.join(*path_elements)

    # Create the directories if they don't exist
    begin
      FileUtils.mkdir_p(dir_path) unless dir_path.empty?
    rescue Errno::EACCES => e
      puts "Error creating directory: #{e.message}"
      next
    end

      file_path = if dir_path.empty? 
          "#{file_name}.m3u" 
                else
                  File.join(dir_path, "#{file_name}.m3u")
                end

    begin
      File.open(file_path, 'w') do |file|
        file.puts "#EXTM3U"
        playlist[:tracks].each do |track_id|
          track_path = tracks[track_id]
          file.puts track_path if track_path
        end
      end
      puts "Generated #{file_path}"
    rescue Errno::EACCES => e
      puts "Error writing file: #{e.message}"
    end
  end
    end
  end
end

