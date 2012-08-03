#library('dart:linq');
#source('LinqException.dart');
#source('Clonable.dart');

/**
 * Primary collection-manipulating class in dart:linq.
 *
 *  * Methods that return a [Queryable] return a sequence that contains cloned objects
 *  * Unless otherwise indicated, all results and collections preserve sequence ordering
 *  * With methods that perform some kind of object comparison, [T] is required to implement the [Comparable](http://api.dartlang.org/docs/continuous/dart_core/Comparable.html) interface
 *  * Some methods require that [T] implements the [Clonable] interface
 *  * This library currently adopts the .NET naming convention instead of Dart's camel-case convention which may be revised in the future
 *
 *  All examples in the documentation below use the [Pie](../Tests.dart/Pie.html) test class.
 */
class Queryable <T> implements Iterable<T>
{
  Collection<T> _source;

  int _AscendingSort(T a, T b) => 0;
  int _DescendingSort(T a, T b) => 0;

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
  * If a predicate is provided, determines whether any element of a sequence satisfies it. If no predicate is provided,
  * returns whether or not the sequence contains any items.
  *
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
  * Returns the current internal collection as a Collection<T>.
  */
  Collection<T> AsCollection ()
  {
    return _source;
  }

  /**
   * Concatenates this sequence with another.
   *
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
   * Determines whether a sequence contains a specified element (default comparer)
   */
  bool Contains (T value) {
    return (new List.from(this._source as Iterable<T>)).indexOf(value) != -1;
  }

  /**
   * Returns a number that represents how many elements in the specified
   * sequence satisfy the input predicate (if provided).
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
   * Returns the current sequence except the elements specified in the input
   * collection. The generic type of the sequences (T) must implement the
   * [Comparable](http://api.dartlang.org/dart_core/Comparable.html) interface.
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
   * With the `Except` operation we can, you guessed it, grab all the pies
   * *except* the berry ones
   *
   *     allPies.Except(berryPies)
   *            .AsCollection()
   *            .forEach((p) => print(p));
   *
   * Which outputs the result:
   *     Apple (3.29)
   *     Lemon (0.99)
   *     Meat (5.7)
   *     Meat (2.99)
   *
   */
  Queryable<T> Except (Collection<T> other)
  {
    var interim = this.ToList();

    for (T t in other)
    {
      for (T u in interim)
      {
        if((u as Comparable).compareTo(t as Comparable) == 0)
        {
           interim.removeRange(interim.indexOf(u), 1);
        }
      }
    }

    return new Queryable (interim);
  }

   /**
   * Returns the first element of a sequence, or returns the first element in a
   * sequence that satisfies a specified condition. If the sequence is empty or
   * null or no element matches the predicate, a [LinqException](./LinqException.html)
   * will be thrown.
   *
   * ---
   *
   * We can grab the first pie in the sequence thusly:
   *
   *     var allPies = new Queryable(Pie.GetTestPies());
   *     print(allPies.First());
   *
   * which yields the expected result:
   *
   *     Apple (3.29)
   *
   * Say we want to get the first pie in the sequence that costs more than $5.
   * We can do this by supplying a predicate like:
   *
   *     print(allPies.First((p) => p.cost > 5));
   *
   * which gives us:
   *
   *     Meat (5.7)
   *
   */
    T First ([Function fn]) {
        if (fn == null)
        {
            return this.ToList() [0];
        }
        else
        {
            return this.Where(fn).ToList() [0];
        }
    }

  /**
  * Returns the first element of the sequence or a default value (null), or
  * returns the first element in a sequence that satisfies a specified
  * condition or a default value (null).
  */
  T FirstOrDefault ([Function fn])
  {
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
  * Orders a sequence in ascending order according to the provided input
  * function.
  *
  * ---
  *
  * In the following example, we want to take our collection of pies and order
  * them from cheapest to most expensive using a comparison predicate:
  *
  *     var pies = new Queryable(Pie.GetTestPies());
  *     pies.OrderBy((p,q) => p.name.compareTo(q.name))
  *         .ForEach((i) => print(i));
  *
  * which yields the result:
  *
  *     Lemon (0.99)
  *     Meat (2.99)
  *     Apple (3.29)
  *     Cherry (4.29)
  *     Blueberry (4.29)
  *     Meat (5.7)
  *
  */
  Queryable<T> OrderBy (Function fn) {
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

  ///
  /// Inverts the order of the elements in a sequence.
  ///
  Queryable<T> Reverse () {
    List<T> interim = new List.from(this._source as Iterable<T>);
    List<T> newList = new List();

    for (var i = interim.length - 1; i >= 0; i--) {
      newList.add(interim[i]);
    }

    return new Queryable(newList);
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
  * Bypasses the specified number ([count]) of elements from the start of a sequence and returns the remaining elements
  * as a new [Queryable] sequence.
  *
  * * If [count] is greater than the size of the sequence, a new [Queryable] of zero elements will be returned
  * * If [count] is less than or equal to zero, a new [Queryable] with all the elements of the current instance will be
  *   returned.
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

  ///
  /// Returns a specified number of contiguous elements from the start of a sequence.
  ///
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
   * Filters a sequence of values based on a predicate
   */
  Queryable<T> Where (Function fn) {
    return new Queryable(_source.filter(fn));
  }
}