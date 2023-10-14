# require "bundler/gem_tasks"
require "rake/testtask"

# puts "Dir: #{File.expand_path('.')}"

Rake::TestTask.new(:test) do |t|
  require './lib/required'
  t.libs << "tests"
  # t.libs << "lib/required"
  t.test_files = FileList["tests/**/*_test.rb"]
  # t.verbose = true
end



task :test_p do
  # files_list = Dir["#{__dir__}/tests/produce/books/**/recipe.yaml"]+

  require_relative 'tests/lib/produce_module'

  class PdfNotMatchError < StandardError; end

  files_list = Dir.glob("#{__dir__}/tests/produce/{collections,books}/**/recipe.{yml,yaml}")
  filtre = ENV['TEST']
  if filtre
    files_list.select! { |pth| pth.match?(filtre) }
  end
  clear
  ENV['TEST'] = "true"
  puts "Nombre de livres à fabriquer : #{files_list.count}".bleu
  files_list.each do |fbook|
    book_rpath = File.dirname(fbook).sub(/#{__dir__}\/tests\/produce\//,'')
    STDOUT.write "Test de fabrication du livre '#{book_rpath}'".bleu
    begin
      produce_book(book_rpath)
      puts "\r👍 Le livre #{book_rpath} est conforme à ce qui est attendu".vert
    rescue PdfNotMatchError => e
      puts "\r👎 Problème avec le livre #{book_rpath}#{" "*20}\n".rouge
      puts e.message.rouge
    rescue Exception => e
      puts " "*20 + "\n"
      puts e.message.rouge
      puts e.backtrace[0..4].join("\n").rouge
    end
      
  end
end

task :default => :test
