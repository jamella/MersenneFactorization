#!/usr/bin/env ruby

require 'openssl'
require 'optparse'

class MersenneFactorization
  def initialize n=nil
    @N = n.to_i
  end

  def file_input file
    raise "File does not exits" if !File.exist? "#{file}"
    rsa = OpenSSL::PKey::RSA.new File.read "#{file}"
    @N = rsa.params["n"].to_i
  end

  def exploit
    raise "No factorization target found" if @N.nil?
    return expcore
  end

private
  def expcore
  #two mersenne prime product
    mers = mersenne_file.drop_while {|i| i>@N}
    mers.each do |p|
      mers.each do |q|
        break if p*q > @N
        if p*q == @N
          p, q = q, p if q > p
          return p, q
        end
      end
    end
    return nil
  end

  def mersenne_file
    mers = []
    File.open("./mersenne_primes").each do |line|
      mers << 2 ** line.match(/\d+\s+(\d+)/)[1].to_i - 1
    end
    return mers
  end
end

class ARGVParser
  def initialize
    @@options = {}
    @banner = "Usage ./mersennefactorization.rb [options]"

    OptionParser.new do |opts|
      opts.banner = @banner
      
      opts.on("-f F", String, "File to read moduli (n)") do |v|
        @@options[:F] = v
      end

      opts.on("-n N", String, "Input moduli from stdin") do |v|
        @@options[:N] = v
      end
    end.parse!
    exit if sanitycheck == false
  end
  
  def options
    @@options
  end

private
  def sanitycheck
    if @@options[:F].nil? && @@options[:N].nil?
      puts "#{@banner} # -h for help"
      return false
    end
  end
end


opts = ARGVParser.new
if !opts.options[:N].to_i.nil?
  n = opts.options[:N].to_i
  ff = MersenneFactorization.new n
  p ff.exploit
end

if !opts.options[:F].nil?
  file = opts.options[:F]
  ff = MersenneFactorization.new
  ff.file_input file
  p ff.exploit
end
