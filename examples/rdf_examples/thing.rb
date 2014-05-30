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

class RdfExamples::Thing

  attr_accessor :id
  attr_accessor :name

  include PoseidonRdf::Poseidon

  poseidon do
    base 'http://example.org/examples/'
    class_uri 'http://example.org/examples/things'
    same_as PoseidonRdf::PoseidonCore::CORE_VOCABULARIES[:prov].Entity
    instance_attributes name: RDF.label
    instance_uri_scheme 'http://example.org/examples/things/#{id}'
  end

  def initialize(param_id, param_name)
    @id = param_id
    @name = param_name
  end


end