require 'forwardable'
require 'uri'
require 'fileutils'
require_relative 'json_file'
require_relative 'config'
require_relative 'consul'
require_relative 'azure/ssh_proxy'
require_relative 'azure/cluster_info'

path = File.expand_path(File.join(CONFIG_DIR, "clusters"))

unless File.exists?(path)
  FileUtils.mkdir_p(File.dirname(path))
  File.open(path, mode: "w", universal_newline: true) do |f|
    f << "{}"
  end
end

WAKE_CLUSTERS = JSONFile.new(path)

class WakeCluster
  extend Forwardable

  NoDefaultClusterSet = Class.new(StandardError)

  def self.default
    name = WakeConfig.get("default_cluster")

    if name
      get(name)
    else
      fail NoDefaultClusterSet
    end
  end

  def self.clusters
    WAKE_CLUSTERS
  end

  def self.get(name)
    if clusters.key?(name)
      new(name)
    end
  end

  def self.reload
    clusters.reload
  end

  def reload
    self.class.reload
    self
  end

  def ssh_proxy
    Azure::SSHProxy.new(cluster: self)
  end

  def consul
    @consul ||= Wake::Consul::Base.new(self)
  end

  def azure
    @azure ||= Azure::ClusterInfo.new(self)
  end

  attr_reader :name

  def initialize(name)
    @name = name
  end

  def full_key(key)
    "#{name}.#{key}"
  end

  def inspect
    "#<#{self.class.name} {#{name.inspect}}>"
  end

  def [](key)
    self.class.clusters[full_key(key)]
  end

  def require(key)
    self.class.clusters.require(full_key(key))
  end

  def update(key, value)
    self.class.clusters.update(full_key(key), value)
    @azure = nil
  end

  def to_hash
    self.class.clusters[name].merge("name" => name)
  end

  def iaas
    self["iaas"]
  end

  def dns_zone
    self["dns_zone"]
  end

  def collaborators
    self["collaborators"] || []
  end

  def delete
    self.class.clusters.delete(name)
  end
end
