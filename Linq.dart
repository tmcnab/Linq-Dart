#library('dart:linq');

#source('LinqException.dart');
#source('Clonable.dart');

/**
* Primary collection-manipulating class in dart:linq.
* ---
*
* &rarr; methods that return a [Queryable] return a sequence that contains cloned objects
*
* &rarr; unless otherwise indicated, all results and collections preserve sequence ordering
*
* &rarr; where methods that perform some kind of object comparison, [T] is required to implement the [Comparable](http://api.dartlang.org/docs/continuous/dart_core/Comparable.html) interface
*
* &rarr; some methods require that [T] implements the [Clonable] interface
*
* ---
*
* This library currently adopts the .NET naming convention instead of Dart's camel-case convention (which may be
* revised in the future). All examples in the documentation below use the [Pie](../Tests.dart/Pie.html) test class.
*/
class Queryable<T> implements Iterable<T>
{
  Collection<T> _source = null;
  List<T> _listSource = null;

  /**
  * Creates a [Queryable] sequence from an input that inherits from
  * [Collection](http://api.dartlang.org/dart_core/Collection.html). It uses this as the data source, preserving the
  * original object reference.
  */
  Queryable (Collection<T> source)
  {
    this._source = source;
    if (source != null) {
      this._listSource = new List.from(source);
    }
  }

  /**
  * Determines whether all elements of a sequence satisfy a condition.
  * ---
  */
  bool all ([bool fn(T element)]) {
    return this.where(fn).Count() == this._listSource.length;
  }

  /**
  * Determines whether any element of a sequence satisfies a condition.
  * ---
  */
  bool any ([Function fn])
  {
    if (fn == null) {
      return !this._source.isEmpty();
    }
    else {
      return this._source.some(fn);
    }
  }

  /**
  * Computes the average of a sequence.
  * ---
  *
  * &rarr; a [LinqException] may be thrown if the sequence does not contain at least one element
  *
  * &rarr; a [CastException](http://api.dartlang.org/docs/continuous/dart_core/CastException.html) may be thrown if the predicate does not return a [num]
  */
  num average ([num fn(T element)]) {
    num carry = 0;

    if (this._listSource.length <= 0) {
      throw new LinqException("Sequence does not contain at least one element.");
    }

    if (fn == null) {
      for (num n in (this._listSource as List<num>)) {
        carry += n;
      }
      return carry / this._listSource.length;
    }
    else {
      for (var i = 0; i < this._listSource.length; i++) {
        carry += fn(this._listSource[i]);
      }
      return carry / this._listSource.length;
    }
  }

  /**
  * Returns the current internal collection as a Collection<T>.
  * ---
  */
  Collection<T> asCollection ()
  {
    return _source;
  }

  /**
  * Concatenates this sequence instance with another.
  * ---
  */
  Queryable<T> concat (Collection<T> other) {
    this._listSource.addAll(other);
    return new Queryable(this._listSource);
  }

  /**
  * Determines whether a sequence contains a specified element by using the default equality comparer.
  * ---
  *
  * &rarr; a [CastException](http://api.dartlang.org/docs/continuous/dart_core/CastException.html) will be thrown if [T]
  * does not implement the [Comparable](http://api.dartlang.org/docs/continuous/dart_core/Comparable.html) interface
  */
  bool contains (T value) {
    for (T t in this._source) {
      if((t as Comparable).compareTo(value as Comparable) == 0) {
        return true;
      }
    }
    return false;
  }

  /**
  * Returns the number of elements in a sequence.
  * ---
  */
  int Count ([Function fn]) {
    if(fn == null) {
      return this._listSource.length;
    }
    else {
        return this._listSource.filter(fn).length;
    }
  }

  /**
  * Returns the elements of the specified sequence or a default value if the sequence is empty.
  * ---
  *
  * &rarr; if [defaultValue] is not provided, an empty [Queryable] of [T] will be returned
  */
  Queryable<T> defaultIfEmpty ([T defaultValue]) {
    if(this._listSource.length <= 0) {
      if(defaultValue != null) {
        return new Queryable([defaultValue]);
      }
      else {
        return new Queryable(new List<T>());
      }
    }
    else {
      return new Queryable(this._source);
    }
  }


  /**
  * Returns distinct elements from a sequence.
  * ---
  */
  Queryable<T> distinct () {
    for (T t in this._source) {
      if (!(new Queryable(this._listSource)).contains(t)) {
        this._listSource.add(t);
      }
    }

    return new Queryable(this._listSource);
  }

  /**
  * Returns the element at a specified index in a sequence.
  * ---
  * 
  * &rarr; a [LinqException] will be thrown if [index] is less than zero or is greater than the length of the sequence
  *
  */
  T elementAt (int index) {
    if (index < 0 || index >= this._listSource.length) {
      throw new LinqException("Specified element lays outside the sequence.", new IndexOutOfRangeException(index));
    }
    else {
      return this._listSource[index];
    }
  }

  /**
  * Returns the element at a specified index in a sequence or a default value.
  * ---
  */
  T elementAtOrDefault (int index, [T defaultValue]) {
    if (index < 0 || index >= this._listSource.length) {
      return defaultValue;
    }
    else {
      return this._listSource[index];
    }
  }

  /**
  * Produces the set difference of two sequences by using the default equality comparer to compare values.
  * ---
  *
  * &rarr; [T] must implement the [Comparable](http://api.dartlang.org/dart_core/Comparable.html) interface
  */
  Queryable<T> except (Collection<T> other) {
    for (T t in other) {
      for (T u in this._listSource) {
        if((u as Comparable).compareTo(t as Comparable) == 0) {
          this._listSource.removeRange(this._listSource.indexOf(u), 1);
        }
      }
    }

    return new Queryable(this._listSource);
  }

  /**
  * Returns the first element or the first element in a sequence that satisfies a specified condition.
  * ---
  *
  * &rarr; a [LinqException] will be thrown if the predicate passed in does not match an element, or the sequence contains no elements
  */
  T First ([bool fn(T element)]) {
    if (fn == null) {
      try {
        return this._listSource[0];
      }
      catch (Exception ex) {
        throw new LinqException("Sequence does not contain more than zero elements.");
      }
    } else {
      try {
        return this.where(fn).toList()[0];
      }
      catch (Exception ex) {
        throw new LinqException("Predicate failed to match any elements within the sequence.");
      }
    }
  }

  /**
  * Returns the first element of a sequence, or a default value if the sequence contains no elements.
  * ---
  *
  * This method is just like [First], however if the sequence is empty or the predicate does not match an element in the
  * sequence, a null value will be returned instead of a [LinqException] being thrown.
  */
  T FirstOrDefault ([bool fn(T element)]) {
    if (fn == null) {
      var interim = this._listSource;
      if (interim.length > 0) {
        return interim [0];
      } else {
        return null;
      }
    } else {
      var interim = this.where(fn).toList();
      if (interim.length > 0) {
        return interim [0];
      } else {
        return null;
      }
    }
  }

  void forEach (Function fn) {
    this._listSource.forEach(fn);
  }

  /*
  Map<Dynamic, Collection<T>> GroupBy (Dynamic fn (T element)) {
    Map<Dynamic, Collection<T>> interim = new Map<Dynamic, Collection<T>>();

    return interim;
  }
  */

  /**
  * Produces the set intersection of two sequences by using the default equality comparer to compare values.
  * ---
  */
  Queryable<T> intersect (Collection<T> other) {
    List<T> interim = new List();

    for (T t in other) {
      if (this.contains(t)) {
        interim.add(t);
      }
    }

    return new Queryable(interim);
  }

  /**
  * Returns the underlying data source's iterator.
  * ---
  */
  Iterator<T> iterator() {
    return this._source.iterator();
  }

  /*
  Queryable<Object> Join (Collection<Object> inner, Object fn (T outerElement, Object innerElement)) {

    if (inner == null) {
      throw new LinqException("Argument 'inner' is null.", new NullPointerException());
    }

    if (fn == null) {
      throw new LinqException("Argument 'fn' is null.", new NullPointerException());
    }
  }
  */

  /**
  * Returns the last element of a sequence or the last element of a sequence that satisfies a specified condition.
  * ---
  *
  * &rarr; a [LinqException] will be thrown if the sequence contains no elements or the provided predicate fails to match any elements
  */
  T last ([bool fn(T element)]) {
    if (fn == null) {
      try {
        return this._listSource[this._listSource.length - 1];
      }
      catch (Exception ex) {
        throw new LinqException("Sequence does not contain more than zero elements.");
      }
    } else {
      try {
        var interim = this.where(fn).toList();
        return interim[interim.length - 1];
      }
      catch (Exception ex) {
        throw new LinqException("Predicate failed to match any elements within the sequence.");
      }
    }
  }

  T lastOrDefault ([bool fn(T element)]) {
    if (fn == null) {
      try {
        return this._listSource[this._listSource.length - 1];
      }
      catch (Exception ex) {
        return null;
      }
    } else {
      try {
        var interim = this.where(fn).toList();
        return interim[interim.length - 1];
      }
      catch (Exception ex) {
        return null;
      }
    }
  }

  /**
  * Returns the maximum value in a sequence.
  * ---
  *
  * &rarr; a [CastException](http://api.dartlang.org/docs/continuous/dart_core/CastException.html) will be thrown if
  * [T] is not a [num] or if a predicate is provided, the predicate does not return a [num]
  *
  * &rarr; a [LinqException] will be thrown if the sequence contains zero elements
  */
  num max ([num fn(T element)]) {
    var _list = this._listSource;

    if (_list.length <= 0) {
      throw new LinqException("Sequence does not contain at least one element.");
    }

    if (fn == null) {

      if (_list.length == 1) {
        return (_list[0] as num);
      }

      num interim = _list[0] as num;
      for (var i = 1; i < _list.length; i++) {
        interim = (_list[i] as num) > interim ? (_list[i] as num) : interim;
      }
      return interim;
    }
    else {

      if (_list.length == 1) {
        return fn(_list[0]);
      }

      num interim = fn(_list[0]);
      for (var i = 1; i < _list.length; i++) {
        interim = fn(_list[i]) > interim ? fn(_list[i]) : interim;
      }
      return interim;
    }
  }

  /**
   * Returns the minimum value in a sequence.
   * ---
   *
   * &rarr; a [CastException](http://api.dartlang.org/docs/continuous/dart_core/CastException.html) will be thrown if
   * [T] is not a [num] or if a predicate is provided, the predicate does not return a [num]
   *
   * &rarr; a [LinqException] will be thrown if the sequence contains zero elements
   */
   num min ([num fn(T element)]) {
     var _list = this._listSource;

     if (_list.length <= 0) {
       throw new LinqException("Sequence does not contain at least one element.");
     }

     if (fn == null) {

       if (_list.length == 1) {
         return (_list[0] as num);
       }

       num interim = _list[0] as num;

       for (var i = 1; i < _list.length; i++) {
         interim = (_list[i] as num) < interim ? (_list[i] as num) : interim;
       }

       return interim;
     }
     else {

       if (_list.length == 1) {
         return fn(_list[0]);
       }

       num interim = fn(_list[0]);
       for (var i = 1; i < _list.length; i++) {
         interim = fn(_list[i]) < interim ? fn(_list[i]) : interim;
       }
       return interim;
     }
   }

  /**
  * Sorts the elements of a sequence in ascending order according to a comparison function.
  * ---
  */
  Queryable<T> orderBy (int fn(T firstElement, T secondElement)) {
    var interim = this.toList();
    interim.sort(fn);
    return new Queryable(interim);
  }

  /**
  * Orders a sequence in descending order according to the provided input function.
  * ---
  */
  Queryable<T> orderByDescending (Function fn) {
    return this.orderBy(fn).reverse();
  }

  /**
  * Generates a sequence that contains one repeated value, [element], which must implement the [Clonable] interface
  * otherwise an exception will be thrown. [element] will be repeated [count] times in the output sequence.
  * ---
  */
  static Queryable repeat (Clonable element, int count) {
    var interim = new List();
    for (var i = 0; i < count; i++) {
      interim.add (element.clone());
    }
    return new Queryable(interim);
  }

  /**
  * Inverts the order of the elements in a sequence.
  * ---
  */
  Queryable<T> reverse () {
    List<T> newList = new List();

    for (var i = this._listSource.length - 1; i >= 0; i--) {
      newList.add(this._listSource[i]);
    }

    return new Queryable(newList);
  }

  /**
  * Projects each element of a sequence into a new form.
  * ---
  */
  Queryable<Dynamic> select (Dynamic fn(T element))
  {
    List<Object> interim = new List();
    for (T item in this._source) {
      interim.add(fn(item));
    }
    return new Queryable(interim);
  }


  /**
  * Returns the only element of a sequence or the only element that matches a predicate
  * ---
  *
  * &rarr; a [LinqException] will be thrown if there is not exactly one element in the sequence or only one element that
  * matches the predicate [fn]
  */
  T single (bool fn(T element)) {
    if (fn == null) {
      List<T> interim = this._listSource;
      if (interim.length != 1) {
        throw new LinqException("Source collection must contain one item.");
      } else {
        return interim [0];
      }
    } else {
      List<T> result = new List.from(this._source.filter(fn) as Iterable<T>);
      if (result.length != 1) {
          throw new LinqException("Filtered source collection must match one item.");
      } else {
          return result [0];
      }
    }
  }

  /**
  * Returns the only element of a sequence or default, or the only element that matches a predicate or default
  * ---
  */
  T singleOrDefault (bool fn(T element)) {
    if (fn == null) {
      List<T> interim = this._listSource;
      if (interim.length != 1) {
        return null;
      } else {
        return interim [0];
      }
    } else {
      List<T> result = new List.from(this._source.filter(fn) as Iterable<T>);
      if (result.length != 1) {
        return null;
      } else {
        return result [0];
      }
    }
  }

  /**
  * Bypasses a specified number of elements in a sequence and then returns the remaining elements.
  * ---
  */
  Queryable<T> skip (int count) {
    if (count <= 0) {
      return new Queryable(this._source);
    }

    if (this._source.length < count) {
      return new Queryable([]);
    }

    List<T> interim = new List.from(this._source as Iterable<T>);
    return new Queryable(interim.getRange(count, interim.length - count));
  }

  /**
  * Bypasses elements in a sequence as long as a specified condition is true and then returns the remaining elements.
  * ---
  */
  Queryable<T> skipWhile(bool fn(T element)) {
    int index;

    for (index = 0; index < this._listSource.length; index++) {
      if (!fn(this._listSource[index])) {
        break;
      }
    }

    return new Queryable(this._listSource).skip(index);
  }

  /**
  * Computes the sum of a sequence.
  * ---
  */
  num sum ([num fn(T element)]) {
    if (this._source == null) {
      throw new LinqException("Source sequence is null", new NullPointerException());
    }

    if (this._listSource.length == 0) {
      return 0;
    }

    // Get down to summing
    num carry = 0;
    if (fn == null) {
      // Treat the source as a num type
      for (var i = 0; i < this._listSource.length; i++) {
        carry += this._listSource as num;
      }
    }
    else {
      // Project source sequence into num elements
      for (var i = 0; i < this._listSource.length; i++) {
        carry += fn(this._listSource[i]);
      }
    }

    return carry;
  }


  /**
  * Returns a specified number of contiguous elements from the start of a sequence.
  * ---
  */
  Queryable<T> take (int count) {
    return new Queryable(this._listSource.getRange(0, count >= this._listSource.length ? this._listSource.length : count));
  }

  /**
  * Returns elements from a sequence as long as a specified condition is true.
  * ---
  */
  Queryable<T> takeWhile(bool fn(T element)) {
    List<T> interim = new List<T>();

    for (T t in this._source) {
      if (fn(t)) {
        interim.add(t);
      }
      else {
        break;
      }
    }

    return new Queryable(interim);
  }

  /**
  * Returns this sequence as a new List<T>.
  * ---
  */
  List<T> toList() {
    return new List.from(this._source as Iterable<T>);
  }

  /**
  * Produces the set union of two sequences
  * ---
  */
  Queryable<T> union (Iterable<T> other) {
    List<T> interim = new List<T>();

    for (T t in this._source) {
      for (T u in other) {
        if((t as Comparable).compareTo(u as Comparable) == 0) {
          interim.add(t);
        }
      }
    }

    return new Queryable(interim);
  }

  /**
  * Filters a sequence of values based on a predicate.
  * ---
  */
  Queryable<T> where (Function fn) {
    return new Queryable(this._source.filter(fn));
  }

  /**
  * Applies a specified function to the corresponding elements of two sequences, producing a sequence of the results.
  * ---
  */
  Queryable<Dynamic> zip (Collection<T> other, Object fn (T first, T second)) {

    if (this._listSource == null) {
      throw new LinqException("Source sequence is null.", new NullPointerException());
    }

    if (other == null) {
      throw new LinqException("Input sequence is null.", new NullPointerException());
    }

    List<Object> interim = new List<Object>();
    List<T> otherListSource = new List.from(other);

    int len = this._listSource.length < otherListSource.length ? this._listSource.length : otherListSource.length;

    for (var i = 0; i < len; i++) {
      interim.add(fn(this._listSource[i], otherListSource[i]));
    }

    return new Queryable(interim);
  }

}