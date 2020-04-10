class Dog
  attr_accessor :id, :name, :breed
  
  def initialize (attributes)
    attributes.each {|key, value| self.send(("#{key}="), value)}
    @id ||= nil
  end
  
  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)
    SQL
    DB[:conn].execute(sql)
  end
  
  def self.drop_table
    sql = <<-SQL
    DROP TABLE IF EXISTS dogs
    SQL
    DB[:conn].execute(sql)
  end
  
  def self.create(name:, breed:)
    dog = self.new(name, breed)
    dog.save
    dog
  end
  
  def self.new_from_db(row)
    dog = self.new(row[0], row[1], row[2])
    dog
  end
  
  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM dogs WHERE name = ?
    SQL
    row = DB[:conn].execute(sql, name)[0]
    self.new_from_db(row)
  end
  
  def self.find_by_id(id)
    sql = <<-SQL
    SELECT * FROM dogs WHERE id = ?
    SQL
    row = DB[:conn].execute(sql, id)[0]
    self.new_from_db(row)
  end
  
  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
    SELECT * FROM dogs WHERE name = ? and breed = ?
    SQL
    result = DB[:conn].execute(sql, name, breed)
    if result.empty?
      self.create(name, breed)
    else
      row = result[0]
      new_from_db(row)
    end
  end
  
  def update
    sql = <<-SQL
    UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
  
  def save
    self.tap do |dog|
      if dog.id
        update
      else
        sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
        SQL
        DB[:conn].execute(sql, dog.name, dog.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      end
    end
  end
  
end