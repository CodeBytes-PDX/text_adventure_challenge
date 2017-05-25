#!/usr/bin/env ruby

require 'pry'

class Room

    attr_accessor :doors, :type, :items

    def initialize(room_type = 'room')
        @doors = []
        @items = []
        @type = room_type
    end # initialize

#    def add_door(door_position, door_type = 'normal', door_visible = true, door_locked = false)
#        @doors << Door.new(door_position, door_type, door_visible, door_locked)
#    end # add_door

    def describe
    end # describe

end

class Door

    attr_accessor :position, :type, :visible, :locked
    def initialize(position, type = 'normal', visible = true, locked = false)
        @visible = visible
        @position = position
        @type = type
    end # initialize

end

class Player
    attr_accessor :location, :position, :inventory, :holding
    def initialize(location, position = 'middle')
        @location = location
        @position = position
        @holding = ''
        @inventory = []
    end

    def move(direction)
        #binding.pry
        unless direction =~ /^(north|south)?(east|west)?$/
            return nil
        end
        if @position == 'middle'
            @position = direction
        else
            pos_ew = pos_ns = move_ew = move_ns = 0
            newpos = ''
            pos_ew = 1 if @position =~ /east/
            pos_ew = -1 if @position =~ /west/
            pos_ns = 1 if @position =~ /north/
            pos_ns = -1 if @position =~ /south/
            move_ew = 1 if direction =~ /east/
            move_ew = -1 if direction =~ /west/
            move_ns = 1 if direction =~ /north/
            move_ns = -1 if direction =~ /south/
            new_ns = pos_ns + move_ns
            new_ew = pos_ew + move_ew
            newpos = 'north' if new_ns == 1
            newpos = 'south' if new_ns == -1
            newpos += 'east' if new_ew == 1
            newpos += 'west' if new_ew == -1
            @position = (newpos == '' ? 'middle' : newpos)
        end
    end
end

class Item
    attr_accessor :name, :position
    def initialize (name, position)
        @name = name
        @position = position
    end
end

HELP = <<-EOH
Valid commands:
    look                view your surroundings
    go <direction>      move through a doorway
    search <direction>  locate hidden features
    get <object>        pick up an item
    drop <object>       put down an item
    hold <object>       ready an item for use
    quit                leave the game

Valid directions: n[orth] s[outh] e[ast] w[est]
                  n[orth]w[est] n[orth]e[ast]
                  s[outh]w[est] s[outh]e[ast]
                  up down
EOH

rooms = []

rooms[0] = Room.new
rooms[0].doors << Door.new('east')
rooms[0].items << Item.new('tapestry', 'south')
rooms[0].items << Item.new('chisel', 'middle')
rooms[0].items << Item.new('stone', 'middle')

rooms[1] = Room.new
rooms[1].doors << Door.new('west')
rooms[1].doors << Door.new('floor', 'trap', false)

rooms[2] = Room.new('passage')
rooms[2].doors << rooms[0].doors[0]
rooms[2].doors << rooms[1].doors[0]

rooms[3] = Room.new

#puts rooms.inspect

#pc = Player.new(rooms[rand(rooms.size)])
pc = Player.new(rooms[0])


while true do

    print "\nYou are in the #{pc.position} of a #{pc.location.type}.\n> "

    break unless command = gets
    command = command.chomp.downcase

    command = command.sub(/^pick up/, 'get')
    command = command.sub(/^put down/, 'drop')
    command = command.sub(/^move/, 'go')

    if command =~ /\s/
        cmd = command[0, command.index(' ')]
        args = command.split(/\s+/)
        args.shift
    else
        cmd = command
        args = nil
    end

    if cmd =~ /^(go|search|get|drop|hold)\s*$/
        if ! args
            puts 'Wh' + (cmd =~ /^(go|search)$/ ? 'ere' : 'at') + " do you want to #{cmd}?"
            next
        end
    else
#        puts "'#{command}'"
    end # if command

#binding.pry
    case cmd
        when 'look'
            print "You see "
            if pc.location.items.size == 0
                puts "no objects here."
            else
                puts "here:"
                pc.location.items.each { |item|
                    print "- a" + (item.name[0].match(/[aeiou]/) ? 'n' : '') + " #{item.name} "
                    if item.position == pc.position
                        puts "beside you"
                    else
                        puts "in the " + item.position + " of the room"
                    end # if item.position
                }
            end # if pc.location.items.size
        when 'go'
            direction = args.shift
            if pc.position == direction
                # player moves into a wall
                move_door = nil
                pc.location.doors.each { |door|
                    move_door = door if door.position == pc.position and door.visible
                }
                if move_door
                    if move_door.locked and pc.holding != 'key'
                        puts "The #{direction} door is locked."
                    else
                        puts "going to move through door"
                    end
                else
                    puts "You see no door here."
                end
            else
                res = pc.move(direction)
                puts "Invalid direction '#{direction}'." unless res
            end
        when 'search'
            puts "going to search "
        when 'help'
            puts HELP
        when 'quit'
            break
        else
            puts "Unknown command '#{command}'. " + HELP unless command == ''
    end # case

end # while

puts "\nThe world melts around you, and you wake up from a weird dream!"
