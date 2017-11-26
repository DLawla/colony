# frozen_string_literal: true

module HasMusic
  def self.included(base)
    attr_accessor :music, :music_toggle_button, :current_song_index
    attr_reader :songs

    base.extend(ClassMethods)
  end

  module ClassMethods
  end

  def load_music
    @songs = [Gosu::Song.new('media/music/telostheme.ogg'),
              Gosu::Song.new('media/music/groovy.ogg')]
    @current_song_index = rand(@songs.length)
    @music = @songs[$window.current_song_index]

    @music_toggle_button = Button.new(@width - 40, 0, '', width: 18, height: 18, opacity: 50) do |button|
      if $window.music.paused?
        $window.play_music
      else
        $window.pause_music
      end
    end

    next_song_image = Gosu::Image.new("media/next_song.gif")
    next_song = Button.new(@width - 18, 0, '', image: next_song_image, width: 18, height: 18, opacity: 50) do |button|
      $window.next_song
    end

    $window.add_menu_controls [@music_toggle_button, next_song]
  end

  def loop_through_songs
    $window.next_song unless Gosu::Song.current_song
  end

  def play_music
    @music_toggle_button.image = Gosu::Image.new("media/sound.gif")
    $window.music.play
  end

  def pause_music
    @music_toggle_button.image = Gosu::Image.new("media/sound_off.gif")
    $window.music.pause
  end

  def next_song
    $window.music.stop
    $window.current_song_index = ($window.current_song_index + 1) % $window.songs.size
    $window.music = $window.songs[$window.current_song_index]

    $window.play_music unless $window.starting_menu?
  end
end