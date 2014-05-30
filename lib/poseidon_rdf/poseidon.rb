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

module PoseidonRdf

  module Poseidon
  
    def self.included(base)
      base.class_eval do
        extend  ClassMethods
        include InstanceMethods
        class_variable_set :@@poseidon_config, PoseidonRdf::PoseidonCore.new
      end
    end

    module ClassMethods
    
      def poseidon_config
        class_variable_get :@@poseidon_config
      end
      
      def poseidon_get(key)
        poseidon_config[key]
      end
      
      def poseidon_set(key, value)
        poseidon_config[key] = value
      end
      
      def poseidon_present?(key)
        poseidon_config.has_key?(key)
      end
      
      def poseidon_remove(key)
        poseidon_config.delete(key)
      end


      def generate_poseidon_rdf(mode = :owl)
        graph = RDF::Graph.new
        selfuri = poseidon_get :class_uri
        selfuri = RDF::URI(selfuri) unless selfuri.kind_of?(RDF::URI)
        mappings = {}
        mappings = PoseidonRdf::PoseidonCore::OWL_MAPPINGS if mode==:owl
        if mode==:owl
          graph << [selfuri, RDF.type, RDF::OWL[:Class]]
        end
        [:same_as, :see_also, :subclass_of].each do |field|
          if poseidon_present?(field)
            poseidon_get(field).each do |x|
              graph << [selfuri, mappings[field], RDF::URI(x)]
            end
          end
        end
        class_variable_set :@@poseidon_rdf_graph, graph
      end

      def poseidon_as_rdf(mode = :owl)
        unless class_variable_defined?(:@@poseidon_rdf_graph)
          generate_poseidon_rdf(mode)
        end
        class_variable_get :@@poseidon_rdf_graph
      end

      def poseidon_to_rdf(mode = :owl, format = :turtle)
        dump_opts = {prefixes: PoseidonRdf::PoseidonCore::CORE_PREFIXES}
        dump_opts[:base_uri] = poseidon_get(:base) if poseidon_present?(:base)
        poseidon_as_rdf(mode).dump(format, dump_opts ) # , opts.select{ |k,v| [:base_uri, :prefixes].include?(k)})
      end

      def poseidon_create_instance_uri(object)
        if poseidon_get(:instance_uri_scheme).kind_of?(Symbol)
          RDF::URI(object.send(poseidon_get(:instance_uri_scheme)))
        else
          RDF::URI(object.instance_eval('"%s"' % poseidon_get(:instance_uri_scheme)))
        end
      end

      # evaluates the block and stores the configuration in
      # the config hash.
      def poseidon(&block)
        poseidon_config.instance_exec &block
      end
    end

    module InstanceMethods
      def generate_poseidon_rdf(mode = :owl)
        graph = RDF::Graph.new
        selfuri = self.class.poseidon_create_instance_uri(self)
        selfuri = RDF::URI(selfuri) unless selfuri.kind_of?(RDF::URI)
        mappings = {}
        mappings = PoseidonRdf::PoseidonCore::OWL_MAPPINGS if mode==:owl
        if mode==:owl
          graph << [selfuri, RDF.type, self.class.poseidon_get(:class_uri)]
        end

        if self.class.poseidon_present?(:instance_attributes)
          self.class.poseidon_get(:instance_attributes).each do |k,v|
            v.each do |u|
              graph << [selfuri, u, self.send(k) ]
            end
          end
        end

        if self.class.poseidon_present?(:describe_members)
          self.class.poseidon_get(:describe_members).each do |member_key, member_hash|
            if self.respond_to?(member_key)
              members = self.send(member_key)
              members = [members] unless members.kind_of?(Enumerable)
              members.each do |member|
                graph << [selfuri, member_hash[:membership], member.class.poseidon_create_instance_uri(member)]
                if member_hash.has_key?(:with_data) && member_hash[:with_data]==true
                  graph << member.poseidon_as_rdf
                end
              end
            end
          end
        end
        instance_variable_set :@poseidon_rdf_graph, graph
      end


      def poseidon_as_rdf(mode = :owl)
        unless instance_variable_defined?(:@poseidon_rdf_graph)
          self.generate_poseidon_rdf(mode)
        end
        puts instance_variable_get :@poseidon_rdf_graph
        instance_variable_get :@poseidon_rdf_graph
      end

      def poseidon_to_rdf(mode = :owl, format = :turtle)
        dump_opts = {prefixes: PoseidonRdf::PoseidonCore::CORE_PREFIXES}
        dump_opts[:base_uri] = self.class.poseidon_get(:base) if self.class.poseidon_present?(:base)
        self.poseidon_as_rdf(mode).dump(format, dump_opts ) # , opts.select{ |k,v| [:base_uri, :prefixes].include?(k)})
      end
    end
  end
end