# encoding: utf-8
# This file is part of the poseidon_rdf gem.
# Copyright (c) 2012-2014 Peter Menke, SFB 673, Universität Bielefeld
# http://www.sfb673.org
#
# poseidon_rdf is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as
# published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# poseidon_rdf is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with poseidon_rdf. If not, see
# <http://www.gnu.org/licenses/>.

class PoseidonRdf::PoseidonCore

  include RDF

  CORE_VOCABULARIES = {
    prov: Vocabulary.new('http://www.w3.org/ns/prov#')
  }

  CORE_PREFIXES = {
    rdf: 'http://www.w3.org/1999/02/22-rdf-syntax-ns#',
    rdfs: RDFS,
    owl: OWL,
    foaf: FOAF,
    prov: Vocabulary.new('http://www.w3.org/ns/prov#')
  }

  OWL_MAPPINGS = {
      class_type: RDF.type,
      class_name: OWL[:Class],
      same_as: OWL.sameAs,
      see_also: RDFS.seeAlso,
      subclass_of: RDFS.subClassOf
  }

  def config
    @config ||= Hash.new
  end

  def [](key)
    config[key]
  end

  def []=(key, val)
    config[key] = val
  end

  def append(key, val)
    if has_key?(key)
      stack = config[key]
      unless stack.kind_of? Enumerable
        stack = [ stack ].flatten
        config[key] = stack
      end
    else
      config[key] = []
    end
    config[key] << val
  end

  def has_key?(key)
    config.has_key?(key)
  end

  def delete(key)
    config.delete(key)
  end

  # Setter methods

  def poseidon_cast_value_for_class(val)
    if val.kind_of?(Symbol)
      result = self.class.send(val)
      return result.kind_of?(RDF::URI) ? result : RDF::URI(result)
    elsif val.kind_of?(RDF::URI)
      return val
    else
      return RDF::URI(val)
    end
  end

  def poseidon_class_set(key, val)
    config[key] = poseidon_cast_value_for_class(val)
  end

  # base uri
  def base(val)
    poseidon_class_set :base, val
  end

  def class_uri(val)
    poseidon_class_set :class_uri, val
  end

  def class_type(*vals)
    vals.each do |val|
      append :class_type, poseidon_cast_value_for_class(val)
    end
  end

  def same_as(*vals)
    vals.each do |val|
      append :same_as, poseidon_cast_value_for_class(val)
    end
  end

  def see_also(*vals)
    vals.each do |val|
      append :see_also, poseidon_cast_value_for_class(val)
    end
  end

  def subclass_of(*vals)
    vals.each do |val|
      append :subclass_of, poseidon_cast_value_for_class(val)
    end
  end

  # instance related stuff

  def instance_uri_scheme(string)
    config[:instance_uri_scheme] = string
  end

  # directives for inclusion of members
  # possible are:
  # 1. export only their identifiers and the membership
  # 2. export 1. and their actual data

  def describe_member(member_key, opts = {})
    config[:describe_members] = Hash.new unless config.has_key?(:describe_members)
    member_hash = Hash.new
    [:membership, :with_data].each do |field|
      if opts.has_key?(field)
        member_hash[field] = opts[field]
      end
    end
    # membership : predicate that expresses relation from self to member
    # with_data  : if true, actual data is exported
    config[:describe_members][member_key] = member_hash
  end


  # hash where keys are attribute names, and values are
  # arrays of URIs that are used as predicates.
  def instance_attributes(hash)
    config[:instance_attributes] = Hash.new unless config.has_key?(:instance_attributes)

    hash.each do |k,v|
      entry = config[:instance_attributes][k] || []
      if v.kind_of?(RDF::URI)
        entry << v
      else
        entry << RDF::URI(v)
      end
      config[:instance_attributes][k] = entry
    end

  end

end