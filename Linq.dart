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
  Collection<T> _source;

  /**
  * Creates a [Queryable] sequence from an input that inherits from
  * [Collection](http://api.dartlang.org/dart_core/Collection.html). It uses this as the data source, preserving the
  * original object reference.
  */
  Queryable (Collection<T> source)
  {
    this._source = source;
  }

  /**
  * Determines whether all elements of a sequence satisfy a condition.
  * ---
  *
  * Say we want to find out if all our pies are not free. We can test this with the [Any] method like so:
  *
  *     var pies = new Queryable(Pie.GetTestPies());
  *     var str = pies.All((p) => p.cost > 0) ? "No pies are free" : "There are free pies";
  *     print(str);
  *
  *     >> No pies are free
  */
  bool All ([bool fn(T element)]) {
    return this.Where(fn).ToList().length == this.ToList().length;
  }

  /**
  * Determines whether any element of a sequence satisfies a condition.
  * ---
  *
  * The following code example demonstrates how to use Any() to determine whether a sequence contains any elements:
  *
  *     Queryable<Pie> pies = new Queryable(Pie.GetTestPies());
  *     var hasPies = pies.Any() ? "are no" : "are";
  *     print("There ${hasPies} pies!");
  *
  * which produces the following output:
  *
  *     The are pies!
  *
  * You can also determine whether or not a test matches any elements with a predicate:
  *
  *     var hasFreePies = pies.Any((p) => p.cost <= 0) ? "are" : "are no";
  *     print("There ${hasFreePies} free pies.");
  *
  * which produces the following output:
  *
  *     There are no free pies.
  */
  bool Any ([Function fn])
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
  *
  * ---
  *
  * The [Average] method does what it says - computes the average value of a sequence:
  *
  *     var numbers = new Queryable([1,3,2,5,3,6,4]);
  *     print(numbers.Average());
  *
  *     >> 3.4285714285714284
  *
  * However, if your sequence isn't [num]-typed, you can specify a predicate to select what you would like to average.
  * In the following example, we're going to find out the average cost of a pie in our pie collection:
  *
  *     var pies = new Queryable(Pie.GetTestPies());
  *     print("Average Cost: \$${pies.Average((p) => p.cost)}");
  *
  *     >> Average Cost: $3.5916666666666663
  */
  num Average ([num fn(T element)]) {
    var _list = this.ToList();
    num carry = 0;

    if (_list.length <= 0) {
      throw new LinqException("Sequence does not contain at least one element.");
    }

    if (fn == null) {
      for (num n in (_list as List<num>)) {
        carry += n;
      }
      return carry / _list.length;
    }
    else {
      for (var i = 0; i < _list.length; i++) {
        carry += fn(_list[i]);
      }
      return carry / _list.length;
    }
  }

  /**
  * Returns the current internal collection as a Collection<T>.
  * ---
  *
  */
  Collection<T> AsCollection ()
  {
    return _source;
  }

  /**
  * Concatenates this sequence instance with another.
  * ---
  *
  * Say we have two sets of pies, one for vegitarians and one for omnivores:
  *
  *     var vegiePies = [ new Pie ("Leek", 4.99), new Pie ("Potato",   2.95) ];
  *     var  omniPies = [ new Pie ("Meat", 5.99), new Pie ("Shepards", 6.99) ];
  *
  * We can create new collection called `AllPies` which encompasses both
  * collections using the `Concat` method:
  *
  *     var allPies = new Queryable(vegiePies).Concat(omniPies);
  *     allPies.AsCollection().forEach((p) => print(p));
  *
  * Which yields the result:
  *
  *     Leek (4.99)
  *     Potato (2.95)
  *     Meat (5.99)
  *     Shepards (6.99)
  *
  * As you can guess, it appends the second collection to the first.
  */
  Queryable<T> Concat (Collection<T> other) {
    List<T> interim = new List.from(this._source as Iterable<T>);
    interim.addAll(other);
    return new Queryable(interim);
  }

  /**
  * Determines whether a sequence contains a specified element by using the default equality comparer.
  * ---
  *
  * &rarr; a [CastException](http://api.dartlang.org/docs/continuous/dart_core/CastException.html) will be thrown if [T]
  * does not implement the [Comparable](http://api.dartlang.org/docs/continuous/dart_core/Comparable.html) interface
  *
  * ---
  *
  * It's possible, but maybe you've forgotten whether your pie sequence contains a specific pie instance. We can use the
  * [Contains] method to determine whether or not it does contain the specific value
  *
  */
  bool Contains (T value) {
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
  *
  *
  */
  int Count ([Function fn]) {
    if(fn == null) {
      return (new List.from(this._source as Iterable<T>)).length;
    }
    else {
        return (new List.from(this._source.filter(fn))).length;
    }
  }

  /**
  * Returns the element at a specified index in a sequence.
  * ---
  *
  *
  */
  T ElementAt (int n) {
    var interim = new List.from(this._source as Iterable<T>);

    // Error check
    if(n < 0 || n >= interim.length) {
      throw new IndexOutOfRangeException(n);
    }
    else {
      return interim[n];
    }
  }

  /**
   * Returns the element at a specified index in a sequence or a default value
   * (null) if the index is out of range.
   */
  T ElementAtOrDefault (int n) {
    var interim = new List.from(this._source as Iterable<T>);

    // Error check
    if(n < 0 || n >= interim.length) {
      return null;
    }
    else {
      return interim[n];
    }
  }

  /**
   * Produces the set difference of two sequences by using the default equality comparer to compare values.
   * ---
   *
   * Returns the current sequence except the elements specified in the input collection. The generic type of the
   * sequences [T] must implement the [Comparable](http://api.dartlang.org/dart_core/Comparable.html) interface.
   *
   * ---
   *
   * So this method can be thought of as the opposite of the `Concat` method:
   * return all the elements except the ones we specify. Say we have our
   * complete pie collection and we want to remove the berry flavored pies:
   *
   *     var   allPies = Pie.GetTestPies();
   *     var berryPies = [ new Pie("Cherry", 4.29), new Pie("Blueberry", 4.29) ];
   *
   * With the `Except` operation we can, you guessed it, grab all the pies except those specified in `berryPies`:
   *
   *     allPies.Except(berryPies)
   *            .ForEach((p) => print(p));
   *
   *     >> Apple (3.29)
   *     >> Lemon (0.99)
   *     >> Meat (5.7)
   *     >> Meat (2.99)
   *
   */
  Queryable<T> Except (Collection<T> other) {
    var interim = this.ToList();

    for (T t in other) {
      for (T u in interim) {
        if((u as Comparable).compareTo(t as Comparable) == 0) {
           interim.removeRange(interim.indexOf(u), 1);
        }
      }
    }

    return new Queryable (interim);
  }

  /**
  * Returns the first element or the first element in a sequence that satisfies a specified condition.
  * ---
  *
  * &rarr; a [LinqException] will be thrown if the predicate passed in does not match an element, or the sequence contains no elements
  *
  * ---
  *
  * We can grab the first pie in the sequence thusly:
  *
  *     var allPies = new Queryable(Pie.GetTestPies());
  *     print(allPies.First());
  *
  *     >> Apple (3.29)
  *
  * Say we want to get the first pie in the sequence that costs more than $5. We can do this by supplying a predicate
  * which returns a boolean result:
  *
  *     print(allPies.First((p) => p.cost > 5));
  *
  *     >> Meat (5.7)
  */
  T First ([bool fn(T element)]) {
    if (fn == null) {
      try {
        return this.ToList()[0];
      }
      catch (Exception ex) {
        throw new LinqException("Sequence does not contain more than zero elements.");
      }
    } else {
      try {
        return this.Where(fn).ToList()[0];
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
      var interim = this.ToList();
      if (interim.length > 0) {
        return interim [0];
      } else {
        return null;
      }
    } else {
      var interim = this.Where(fn).ToList();
      if (interim.length > 0) {
        return interim [0];
      } else {
        return null;
      }
    }
  }

  void ForEach (Function fn) {
    this.ToList().forEach(fn);
  }

  /**
  * Returns the underlying data source's iterator.
  */
  Iterator<T> iterator() {
    return this._source.iterator();
  }

  /**
  * Returns the last element of a sequence or the last element of a sequence that satisfies a specified condition.
  * ---
  *
  * &rarr; a [LinqException] will be thrown if the sequence contains no elements or the provided predicate fails to match any elements
  *
  * ---
  *
  * The [Last] method grabs the last element in a [Queryable]. For example, we can grab the last element of our pie
  * collection with:
  *
  *     var pies = new Queryable(Pies.GetTestPies());
  *     print(pies.Last());
  *
  *     >> Meat (2.99)
  *
  * We can also use [Last] to get the last element that matches a predicate passed in. For example, we want to grab all
  * the pies that are over $4 and return the last one:
  *
  *     print(pies.Last((p) => p.cost > 4));
  *
  *     >> Meat (5.7)
  *
  */
  T Last ([bool fn(T element)]) {
    if (fn == null) {
      try {
        var interim = this.ToList();
        return interim[interim.length - 1];
      }
      catch (Exception ex) {
        throw new LinqException("Sequence does not contain more than zero elements.");
      }
    } else {
      try {
        var interim = this.Where(fn).ToList();
        return interim[interim.length - 1];
      }
      catch (Exception ex) {
        throw new LinqException("Predicate failed to match any elements within the sequence.");
      }
    }
  }

  T LastOrDefault ([bool fn(T element)]) {
    if (fn == null) {
      try {
        var interim = this.ToList();
        return interim[interim.length - 1];
      }
      catch (Exception ex) {
        return null;
      }
    } else {
      try {
        var interim = this.Where(fn).ToList();
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
  *
  * ---
  *
  * We can use the [Max] method to find the maximum value in a [Queryable] that contains some numbers:
  *
  *     var numbers = new Queryable([1,3,2,5,3,6,4]);
  *     print(numbers.Max());
  *
  *     >> 6
  *
  * We can also pass in a predicate which returns a [num] to select the maximum if [T] is not a [num]-typed collection.
  * For example, let's find out the most costly pie in our pie collection:
  *
  *     var pies = new Queryable(Pies.GetTestPies());
  *     print(pies.Max((p) => p.cost));
  *
  *     >> 5.7
  *
  */
  num Max ([num fn(T element)]) {
    var _list = this.ToList();

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
  * Sorts the elements of a sequence in ascending order according to a comparison function.
  * ---
  *
  * In the following example, we want to take our collection of pies and order them from cheapest to most expensive
  * using a comparison predicate:
  *
  *     var pies = new Queryable(Pie.GetTestPies());
  *     pies.OrderBy((p,q) => p.name.compareTo(q.name))
  *         .ForEach((i) => print(i));
  *
  *     >> Lemon (0.99)
  *     >> Meat (2.99)
  *     >> Apple (3.29)
  *     >> Cherry (4.29)
  *     >> Blueberry (4.29)
  *     >> Meat (5.7)
  */
  Queryable<T> OrderBy (int fn(T firstElement, T secondElement)) {
    var interim = this.ToList();
    interim.sort(fn);
    return new Queryable(interim);
  }

  /**
   * Orders a sequence in descending order according to the provided input
   * function. This operation is equivalent to:
   *
   *     OrderBy(fn).Reverse();
   *
   * ---
   *
   * In the following example, we want to take our collection of pies and order
   * them in descending order by the name of the pie:
   *
   *     var pies = new Queryable(Pie.GetTestPies());
   *     pies.OrderDescending((p,q) => p.name.compareTo(q.name))
   *         .ForEach((i) => print(i));
   *
   * which yields the result:
   *
   *     Meat (2.99)
   *     Meat (5.7)
   *     Lemon (0.99)
   *     Cherry (4.29)
   *     Blueberry (4.29)
   *     Apple (3.29)
   */
  Queryable<T> OrderByDescending (Function fn) {
    return this.OrderBy(fn).Reverse();
  }

  /**
  * Generates a sequence that contains one repeated value, [element], which must implement the [Clonable] interface
  * otherwise an exception will be thrown. [element] will be repeated [count] times in the output sequence.
  *
  * ---
  *
  * We want to create five pie instances, but all from the same object. Because Dart uses references for objects, we
  * need to create five new objects. You can do this with:
  *
  *     var templPie = new Pie("Bacon", 6.45);
  *     Queryable.Repeat(templPie, 5).ForEach((p) => print(p));
  *
  * which yields the following output:
  *
  *     Bacon (6.45)
  *     Bacon (6.45)
  *     Bacon (6.45)
  *     Bacon (6.45)
  *     Bacon (6.45)
  *
  * Each one of these objects are unique instances because [Pie] implements the [Clonable] interface.
  */
  static Queryable Repeat (Clonable element, int count) {
    var interim = new List();
    for (var i = 0; i < count; i++) {
      interim.add (element.clone());
    }
    return new Queryable(interim);
  }

  /**
  * Inverts the order of the elements in a sequence.
  */
  Queryable<T> Reverse () {
    List<T> interim = new List.from(this._source as Iterable<T>);
    List<T> newList = new List();

    for (var i = interim.length - 1; i >= 0; i--) {
      newList.add(interim[i]);
    }

    return new Queryable(newList);
  }

  /**
  * Projects each element of a sequence into a new form.
  * ---
  *
  * Say we want to create some strings for a website that shows all the pies and their costs. We could iterate over
  * the collection, or we could create a new representation of a pie using the [Select] method:
  *
  *     Queryable<Pie> pies = new Queryable(Pie.GetTestPies());
  *     pies.Select((p) => "Item: ${p.name}\tCost: \$${p.cost}")
  *         .ForEach((p) => print(p));
  *
  * So what we're doing is passing in a function that takes a pie (p) and returns a formatted string. For every item
  * in the [Queryable], we apply this function and stash the result, returning it in the output. After we get the
  * *projection* back from the [Select] method, we iterate over it with the [ForEach] method which prints the projected
  * [Pie] representation:
  *
  *     Item: Apple     Cost: $3.29
  *     Item: Cherry    Cost: $4.29
  *     Item: Lemon     Cost: $0.99
  *     Item: Blueberry Cost: $4.29
  *     Item: Meat      Cost: $5.7
  *     Item: Meat      Cost: $2.99
  */
  Queryable<Object> Select (Object fn(T element))
  {
    List<Object> interim = new List();
    for (T item in this._source) {
      interim.add(fn(item));
    }
    return new Queryable(interim);
  }


  ///
  /// If no filter function is provided, returns the only element of a sequence and throws an exception if there is not
  /// exactly one element in the sequence.
  ///
  /// If a filter is provided, returns the only element of a sequence that satisfies a specified condition, and throws
  /// an exception if less or more than one such element exists.
  ///
  T Single ([Function fn]) {
    if (fn == null) {
      List<T> interim = this.ToList();
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
  * If no filter function is provided, returns the only element of a sequence
  * and returns a default value (null) if none exists.
  *
  * If a filter is provided, returns the only element of a sequence that
  * satisfies a specified condition, and returns a default value (null) if
  * none or more than one exists.
  */
  T SingleOrDefault ([Function fn])
  {
      if (fn == null) {
          List<T> interim = this.ToList();
          if (interim.length != 1) {
              return null;
          } else {
              return interim [0];
          }
      }
      else {
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
  *
  * * If [count] is greater than the size of the sequence, a new [Queryable] of zero elements will be returned
  * * If [count] is less than or equal to zero, a new [Queryable] with all the elements of the current instance will be returned
  *
  * ---
  *
  * We want to grab all the pies, but not the first two. We can do this using the [Skip] method:
  *
  *     var pies = new Queryable(Pie.GetTestPies());
  *     pies.Skip(2).ForEach((p) => print(p));
  *
  * which outputs:
  *
  *     Lemon (0.99)
  *     Blueberry (4.29)
  *     Meat (5.7)
  *     Meat (2.99)
  */
  Queryable<T> Skip (int count) {
    if (count <= 0) {
      return new Queryable(this._source);
    }
    if(this._source.length < count) {
      return new Queryable([]);
    }
    List<T> interim = new List.from(this._source as Iterable<T>);
    return new Queryable(interim.getRange(count, interim.length-count));
  }

  /**
  * Returns a specified number of contiguous elements from the start of a sequence.
  */
  Queryable<T> Take (int count) {
    List<T> interim = new List.from(this._source as Iterable<T>);
    return new Queryable(interim.getRange(0, count >= interim.length ? interim.length : count));
  }

  /**
  * Returns this sequence as a new List<T>
  */
  List<T> ToList() {
    return new List.from(this._source as Iterable<T>);
  }

  /**
  * Filters a sequence of values based on a predicate.
  * ---
  *
  *
  */
  Queryable<T> Where (Function fn) {
    return new Queryable(_source.filter(fn));
  }

}