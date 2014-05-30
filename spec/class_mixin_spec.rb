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

describe PoseidonRdf::Poseidon do


  before :each do
    
  end

  it 'knows all class mixin modules' do
    
    PoseidonRdf::Poseidon.should_not be nil
    PoseidonRdf::Poseidon::ClassMethods.should_not be nil
    
  end
  
  it 'provides correct methods for classes with mixin' do
    @exclass = MixinExamples::ExampleClassMixin
    @anclass = MixinExamples::AnotherExampleClassMixin   
    
    @exclass.should respond_to :poseidon_config
    @exclass.should respond_to :poseidon_get
    @exclass.should respond_to :poseidon_set
    @exclass.should respond_to :poseidon_remove
    @exclass.should respond_to :poseidon_present?
    # puts MixinExamples::ExampleClassMixin.poseidon_config.class.name
  end
  
  it 'can set, check and get poseidon config entries' do
    @exclass = MixinExamples::ExampleClassMixin

    @exclass.poseidon_present?(:foo).should be false
    @exclass.poseidon_get(:foo).should eq nil
    
    value = 'bar'
    
    @exclass.poseidon_set(:foo, value)
    
    @exclass.poseidon_present?(:foo).should eq true
    @exclass.poseidon_get(:foo).should eq value
    
    @exclass.poseidon_remove(:foo) 
  end
  
  it 'uses independent configs with multiple classes' do
    @exclass = MixinExamples::ExampleClassMixin
    @anclass = MixinExamples::AnotherExampleClassMixin   
    
    @exclass.poseidon_present?(:foo).should eq false
    @anclass.poseidon_present?(:foo).should eq false
    value = 'bar'
    @exclass.poseidon_set(:foo, value)
    @exclass.poseidon_present?(:foo).should eq true
    @anclass.poseidon_present?(:foo).should eq false
  end

  it 'knows the standard as/to methods' do
    @exclass = MixinExamples::ExampleClassMixin
    @exclass.should respond_to :as_rdf
    # puts @exclass.to_rdf
    # @exclass.poseidon_set_standard_format(:rdfxml)
    # puts @exclass.to_rdf
  end

end
