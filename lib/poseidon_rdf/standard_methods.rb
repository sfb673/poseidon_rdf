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

  module StandardMethods

    def self.included(base)
      base.class_eval do
        extend  ClassMethods
        include InstanceMethods
        class_variable_set :@@poseidon_standard_mode, :owl
        class_variable_set :@@poseidon_standard_format, :turtle

      end
    end

    module ClassMethods

      def as_rdf
        self.poseidon_as_rdf
      end

      def to_rdf
        self.poseidon_to_rdf(class_variable_get(:@@poseidon_standard_mode), class_variable_get(:@@poseidon_standard_format))
      end

      def poseidon_set_standard_mode(mode)
        class_variable_set :@@poseidon_standard_mode, mode
      end

      def poseidon_set_standard_format(format)
        class_variable_set :@@poseidon_standard_format, format
      end

    end

    module InstanceMethods

      def as_rdf
        poseidon_as_rdf
      end

      def to_rdf
        poseidon_to_rdf(self.class.class_variable_get(:@@poseidon_standard_mode), self.class.class_variable_get(:@@poseidon_standard_format))
      end

    end

  end

end