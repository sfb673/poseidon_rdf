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

  it 'configures itself correctly using the poseidon method' do

    RdfExamples::SimpleClassConfigExample.poseidon_get(:class_type).first.should_not =~ /example.1/

  end

  it 'works with multiple classes' do

    a = RdfExamples::SimpleClassConfigExample.poseidon_get(:class_type)
    b = RdfExamples::OtherClassConfigExample.poseidon_get(:class_type)
    # puts a
    # puts b
    a.should_not eq b

  end

  # it 'works with fields with multiple values ' do
  #   a = RdfExamples::MultiValueExample.poseidon_get(:class_type)
  #   puts a
  #   puts a.class.name
  #   puts a.size
  #   a.each do |i|
  #     puts ">%s<" % i
  #     puts i.class.name
  #   end
  #   puts '-' * 60
  #   puts RdfExamples::MultiValueExample.poseidon_to_rdf
  #   puts '-' * 60
  # end

end
