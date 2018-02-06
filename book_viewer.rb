require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"

before do
  @toc = File.readlines('data/toc.txt')
  @chapters = Dir.entries("data/")
                 .select { |file| file.start_with?'chp' }
end

get "/" do
  @title = "The Adventures of Sherlock Holmes"
  
  erb :home
end

get "/chapters/:number" do
  number = params[:number].to_i
  redirect '/' unless (1..@toc.size).cover? number

  @chapter_name = @toc[number - 1]
  @title = "Chapter #{number}: #{@chapter_name}"
  @chapter = File.read("data/chp#{number}.txt")

  erb :chapter
end

get "/show/:name" do
  params[:name]
end

get "/search" do
  @results = chapters_matching

  erb :search
end

not_found do
  redirect '/'
end

helpers do
  def in_paragraphs(text)
    text.split(/\n{2}/).map.with_index do |paragraph, idx|
      "<p id=paragraph#{idx}>#{paragraph}</p>"
    end.join
  end

  def highlight(text, query)
    text.gsub(query, "<strong>#{query}</strong>")
  end
end

def chapters_matching
  term = params[:query].downcase

  @chapters.each_with_object({}) do |chapter, results|
    if File.read("data/#{chapter}").downcase.include? term
      chapter_number = chapter.scan(/[0-9]+/)[0].to_i
      results[chapter_number] = @toc[chapter_number - 1]
    end
  end.sort.to_h
end