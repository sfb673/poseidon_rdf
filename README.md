# POSEIdON_RDF

[![Gem Version](https://badge.fury.io/rb/poseidon_rdf.svg)](http://badge.fury.io/rb/poseidon_rdf)

POSEIdON (short for "Pimp your Objects with SEmantic InformatiON") is a small
library that lets you add RDF information to classes and their instances.
It can also add methods `as_rdf` and `to_rdf` to those classes and objects that
can be used to retrieve RDF representations in various formats, based on
the functionality provided by the [RDF gem](http://rubygems.org/gems/rdf).

__Notes on v2.0:__ This is a complete rewrite of the first POSEIdON code,
with a complete redesign of the core functionality. It changes the names
of user methods as well, so you will need to adjust your POSEIdON
definitions in your code (if you used POSEIdON 1.x, that is). 

## How to use this gem

First, include the main POSEIdON module in classes where you want to use
RDF generation features:

```ruby
class Foo
  include PoseidonRdf::Poseidon
  # etc.
end
```

Now, your class contains a bunch of high-level class and instance methods for
adding RDF triples. Methods for output and serialisation of the resulting RDF
are also added.

In order to configure your class to use POSEIdON, you call the `poseidon`
method with a block that contains statements using the POSEIdON DSL:

### Example

```Ruby
class Foo
  include Poseidon
  poseidon do
    base 'http://example.org/'
    class_uri 'http://example.org/Foo'
    same_as 'http://example.org/SomeOtherFoo'
    instance_uri_scheme 'http://example.org/Foo/#{id}'
    ...
  end
end
```

This DSL will be explained step by step in the following sections.

## The POSEIdON DSL

### Class-related configuration

The DSL is divided into two sections: One that specifies how *classes*
can be represented as RDF, and another section for the configuration
of their *instances*. First, I will explain what you can do to
represent classes.

#### Identifying URIs for classes

Every RDF entity needs an URI to identify itself. In order to define
such an identifier for your class, use the `class_uri` method.
In order to reduce the lines in example code, this and the following
examples assume we want to configure a class named `Foo`, as in the
first sample above. The following examples show a POSEIdON configuration
along with the resulting snippet of RDF (in Turtle notation).

```Ruby
poseidon do
  base 'http://example.org/'
  class_uri 'http://example.org/Foo'
end
```

```
@base <http://example.org/> .
<Foo> a <owl:Class> .
```

First, a base URI is defined for the RDF output. In combination 
with `<Foo>` this results in the URI we gave in the `class_uri` 
configuration statement.

In addition, the RDF generator will automatically add a statement
that gives the type of your Ruby Class as `rdfs:Class` or
`owl:Class`, depending on the RDF formalism you chose for output
(see below).

In these examples, values are given as strings. It is possible to
use other objects as values (such as accessing class or instance
methods by using symbols). See below for the options.

#### Relations to other classes

You can declare *equivalence* relations and *subclass* relations
for your Ruby class:

```Ruby
poseidon do
  base 'http://example.org/'
  class_uri 'http://example.org/Foo'
  same_as 'http://example.org/SomeOtherFoo'
  subclass_of 'http://example.org/AMoreGeneralFoo'
end
```

```
@base <http://example.org/> .
<Foo> a <owl:Class> ;
  owl:sameAs <http://example.org/SomeOtherFoo> ;
  rdfs:subClassOf <http://example.org/AMoreGeneralFoo> .
```

### Instance-related configuration 

There are other options to configure how *instances* of a class
should be exported.

#### Identifying URIs for classes

First, every instance itself needs an identifier. With 
`instance_uri_scheme` you can provide a string that can be
evaluated in the context of the instance object. The result
should be an URL-compatible string that is unique for each
instance object. If you have some kind of id attribute, this
is an ideal candidate.

Let us assume that the `Foo` class has a numeric identifier
accessible via the instance method `id`, and there is one
instance object with the ID `1`. Then, the following
code defines a string scheme for instances:

```Ruby
poseidon do
  base 'http://example.org/'
  class_uri 'http://example.org/Foo'
  instance_uri_scheme 'http://example.org/Foo/#{id}'
end
```

```
@base <http://example.org/> .
<Foo> a <owl:Class> .

<Foo/1> a <Foo> .
```

It is important to use **single quotes** for the string scheme
in order to avoid the string to be evaluated right away. The
string scheme internally uses the interpolation `#{id}`, but
the interpolation will be computed in the context of the 
object to be represented, so for our single object, this part
of the string will yield `'1'`.

#### Mapping attributes to RDF statements

You can declare how atomic attributes of an instance shall be
represented in RDF. For this you basically need to provide
information about the URI that shall serve as the RDF
*predicate* linking the instance (subject) to the attribute
(object). 

This can be done with the `instance_attributes` method
(assuming that the instance object has an attribute `name`
set to the value of 'Bar'):

```Ruby
poseidon do
  base 'http://example.org/'
  class_uri 'http://example.org/Foo'
  instance_uri_scheme 'http://example.org/Foo/#{id}'
  instance_attributes :name, 'http://example.org/hasName'
end
```

```
@base <http://example.org/> .
<Foo> a <owl:Class> .

<Foo/1> a <Foo> ;
  <hasName> "Bar" .
```

You provide a Hash to this method, where the keys are symbols
indicating the method names for your attributes, and the values
are (in the default case) strings indicating the predicate URI.

> Note: In the future, it will also be possible to use more
complicated configurations here, e.g., if you need to transform
attribute values first, or if you need to export the value of
an attribute more than one time using different predicates.

You can call `instance_attributes` multiple times without 
losing information from earlier calls.

#### Mapping member objects to RDF statements

This method is useful for atomic attributes (such as strings or
numbers). If you need to export more complex objects along with
an instance, you can do so with `describe_member` This method
evaluates one or more member objects and

1. expresses their membership inside the instance using a given
   predicate URI,
2. and, optionally, adds their RDF to the output.
   
In both cases, the class of the member objects needs to be configured
to use POSEIdON, too. However, in the first case, only the instance
URI has to be configured.

Let us assume that our instance of Foo has the following member
objects:

1. an `owner`, which is some kind of person or agent for whom
   RDF descriptions are already available at some external URL,
2. and a collection `tidbits` of instances of the `Tidbit` class
   which we want to describe in RDF inside the main RDF of the
   Foo instance itself.

The owner object points to the existing RDF description with an URL
field, and the Foo instance possesses two tidbits, a "gadget" and
a "gimmick". 

This can be configured with the following configuration:

```Ruby
poseidon do
  ...
  describe_member :owner, {
      membership: 'http://example.org/belongsTo',
      with_data: false
    }
  describe_member :tidbits, {
      membership: 'http://example.org/hasTidBit',
      with_data: true
  }
end
```

The first configuration gives a membership predicate URI
for the owner relation,
and tells POSEIdON *not to export* the owner's RDF data
except for its instance URI.

The second configuration gives a membership predicate URI
for the possession of the tidbit, and tells POSEIdON
*export* the tidbits' RDF *along with the Foo RDF*:

```
@base <http://example.org/> .
<Foo/1> a <Foo> ;
  <belongsTo> <http://some/external/uri> ;
  <hasTidBit> <Tidbit/1>, <Tidbit/2> .

<Tidbit/1> a <Tidbit> ;
  <hasName> "gadget" .
  
<Tidbit/2> a <Tidbit> ;
  <hasName> "gimmick" .

```

We see that POSEIdON checks whether the member object is an enumeration.
If yes, every item in the enumeration will be exported. If not, the
single member will be exported. 

> The configuration for the owner and for the `Tidbit` class is omitted here, but the
  example should be clear, anyway. 

## How to provide values

URIs can be given in the following formats:

1. As `RDF::URI` objects. These will be used without change.
2. As __strings__. These will be used as-is, and will automatically be
   converted to URIs.
3. As __symbols__. These stand for methods that will be called during
   RDF generation. Depending on the context, class or instance methods
   will be called. Their result will be converted to RDF URIs, if they
   are of a different type.

Thus, it is also possible to use predefined or ad-hoc vocabularies from
[the Ruby RDF library](https://github.com/ruby-rdf/rdf) here, such as
`FOAF.surname`, `DC.title`, and so on.

[The people example](examples/rdf_examples/person.rb) contains some of
these predefined vocabularies in action.

## Export

When POSEIdON has been mixed in, two methods are provided to classes
and instances that generate and serialise RDF:

1. `poseidon_as_rdf`, which generates the RDF graph,
2. and `poseidon_to_rdf`, which returns a serialised string of the
   RDF in a given format.
    
`poseidon_to_rdf(mode, format)` expects two parameters:

1. The __mode__, which determines what RDF vocabularies to use. At
   the moment this defaults to `:owl`, which is also the only option
   (but more will follow).
2. The __format__, which selects an RDF serialisation format. It
   defaults to `:turtle`, other options are `:ntriples` or `:rdfxml`.


### Providing standard `as_rdf` and `to_rdf` methods

The two methods `as_rdf` and `to_rdf` are not automatically defined because
they could cause conflicts. If you want them, include the module
`PoseidonRdf::StandardMethods` after `include PoseidonRdf::Poseidon`.

Now, if you want to change mode or format, you can do so using the 
following methods:

```Ruby
@example_class.poseidon_set_standard_mode(:owl)
@example_class.poseidon_set_standard_format(:rdfxml)
```

While the mode must be adjusted for every class that has POSEIdON mixed in,
the format change is only relevant to classes that act as a starting point
of RDF generation – that is, those that actually call `to_rdf` (since the
collection of RDF under the hood only consists of calls to `as_rdf`, where
the serialisation format is irrelevant).


## Release history:

### 2.0 (29.05.2014)

Major redesign, improvement of DSL and internal functionality.
Re-release under the available gem name "poseidon_rdf".

### 1.1.1 (17 July 2013)

- Turtle format
- minor bux fixes

### 1.0.0 (23 June 2013) initial relase

- initial, minimal release

## Plans

_(none at the moment.)_


## Contributing to POSEIdON
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2012–2104 Peter Menke, SFB 673.
Licensed under the GNU LGPL v3. See LICENSE.txt for further details.

