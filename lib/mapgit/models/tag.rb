class Mapgit::Tag < Struct.new(:hash, :tag)
  def self.from_line(line)
    values = line.split(/\s/).reject(&:empty?)
    raise "bad data" unless values.length == 2
    # TODO Validate the validity of the geodata
    new(*values)
  end
end
