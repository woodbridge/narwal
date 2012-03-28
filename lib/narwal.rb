$:.unshift File.join(File.dirname(__FILE__), *%w[.. lib])

require "narwal/version"
require 'sqlite3'
require 'grit'
require 'pathname'
require 'terminal-table'
require 'time'

module Narwal
  def self.open_database(path)
    SQLite3::Database.new path
  end

  def self.ensure_schema(db)
    sql_file = File.expand_path(File.join(File.dirname(__FILE__), "../data/schema.sql"))
    schema = File.read sql_file
    db.execute schema
  end

  def self.add_repo(db, path)
    name = Pathname.new(path).basename.to_s
    repo = Grit::Repo.new path
    now = Time.now.to_i

    latest_commit = repo.commits.first.sha
    db.execute "insert into repos (name, path, latest_commit) values (?, ?, ?) ", name, path, latest_commit
  end

  def self.find_database
    open_database Dir['*.db'].first
  end

  def self.list_repos(db)
    repos = db.execute "select path, name, latest_commit, last_clock_in from repos"
    rows = repos.reduce([]) do |rows, repo|
      path =          repo[0]
      name =          repo[1]
      latest_commit = repo[2]
      last_clock_in = repo[3]

      if last_clock_in.nil?
        last_clock_in = "Never clocked in."
      end

      latest_commit_message = Grit::Repo.new(path).commit(latest_commit).message

      row = [name, path, latest_commit_message, last_clock_in]
      rows << row
    end

    puts Terminal::Table.new rows: rows, headings: ['Name', 'Repo Path', 'Latest Commit', 'Last Clock In']
  end

  def self.open_repo(name, db)
    already_open = find_current_repo db

    if already_open && name == already_open
      puts "#{name} is already open."
      exit
    elsif already_open && name != already_open
      puts "#{already_open} is already open.  Close it and switch to #{name}?"

      print "[Y/N] >> "
      input = STDIN.gets

      if ['y', 'Y'].include? input.chomp

        puts "closing #{already_open}"
        close_repo(db)
        db.execute "update repos set open = 0 where name = ?", already_open

        repos = db.execute "select id, name, path, latest_commit from repos where name = ?", name

        if repos.any?
          repo = repos.first

          res = db.execute "update repos set open = 1 where id = ?", repo.first
          puts "opening #{repo}"
        end
      end
    else

      db.execute 'update repos set open = 1 where name = ?', name

      puts "Opened #{name}. Get hacking."
    end
  end

  def self.find_current_repo(db)
    repos = db.execute("select name from repos where open = 1")
    if repos.any?
      repos.first.first
    else
      nil
    end
  end

  def self.close_repo(name = nil, db)
    repo = name || self.find_current_repo(db)
    if repo
      db.execute('update repos set open = 0 where open = 1')
    end
  end

  case ARGV[0]
  when "init"
    path = ARGV[1] || "database.db"
    db = self.open_database path
    ensure_schema db
  when "add"
    path = ARGV[1] || ""
    db = find_database

    if File.exist?(path) and File.exist? File.join(path, ".git")
      add_repo(db, path)
      puts "Added #{path} to repo list."
    else
      puts "No git repo in #{path}"
    end
  when "repos"
    list_repos(find_database)
  when "open"
    if !ARGV[1]
      puts "tell me a repo"
      exit
    else
      open_repo ARGV[1], find_database
    end
  when "current"
    current = find_current_repo find_database
    if current
      puts "Currently tracking #{current}"
    else
      puts "not tracking any repo right now."
    end
  when "close"
    puts "Closing open repo..."
    close_repo find_database
  end
end
