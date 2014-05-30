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

require 'spec_helper'

describe PoseidonRdf do

  it 'can describe a real example from the domain of people' do
    person_class = RdfExamples::Person.poseidon_to_rdf
    alice  = RdfExamples::Person.new 1, 'Alice', 'Example',   'alice@example.com'
    bob    = RdfExamples::Person.new 2, 'Bob',   'Example',   'bob@example.com'
    carol  = RdfExamples::Person.new 2, 'Carol', 'Example',   'carol@example.com'
    alice.things   << RdfExamples::Thing.new(101, 'apple')
    bob.things << RdfExamples::Thing.new(102, 'book')
    carol.things << RdfExamples::Thing.new(103, 'candle')
    carol.things << RdfExamples::Thing.new(104, 'cinnamon bun')
    # puts '-' * 60
    # puts person_class
    # puts '-' * 60
    person_class.should_not be nil
    alice.should respond_to :poseidon_as_rdf
    # puts '-' * 60
    # puts alice.poseidon_to_rdf
    # puts '-' * 60
    # puts bob.poseidon_to_rdf
    # puts '-' * 60
    # puts carol.poseidon_to_rdf
    # puts '-' * 60
  end

end
