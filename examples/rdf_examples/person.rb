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

class RdfExamples::Person

  attr_accessor :id
  attr_accessor :firstname
  attr_accessor :lastname
  attr_accessor :email
  attr_accessor :things

  include PoseidonRdf::Poseidon

  poseidon do
    base 'http://example.org/examples/'
    class_uri 'http://example.org/examples/people'
    same_as RDF::FOAF.Person
    subclass_of RDF::FOAF.Agent

    instance_uri_scheme 'http://example.org/examples/people/#{id}'

    instance_attributes firstname: RDF::FOAF.givenname,
                        lastname: RDF::FOAF.surname,
                        email: RDF::FOAF.mbox

    describe_member :things, {
        membership: 'possessesThing',
        with_data: true
    }
  end

  def initialize(param_id, param_firstname, param_lastname, param_email)
    @id=param_id
    @firstname=param_firstname
    @lastname=param_lastname
    @email=param_email
    @things = []
  end

end