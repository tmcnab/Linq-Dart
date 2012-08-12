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
    return this.Where(fn).ToList().length == this._listSource.length;
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
    this._listSource.addAll(other);
    return new Queryable(this._listSource);
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
  *  * if [defaultValue] is not provided, an empty [Queryable] of [T] will be returned
  *
  * ---
  *
  * Say that we want to filter out pies down using some specific contstraints but we don't know whether it'll
  * actually return results. We can use the [DefaultIfEmpty] method to provide a default output *if* this
  * collection of pies does happen to contain no values:
  *
  *     var pies = new Queryable(Pies.GetTestPies());
  *     pies.Where((p) => p.cost > 3.5 && p.cost < 4)
  *         .DefaultIfEmpty()
  *         .ForEach((p) => print(p));
  *
  *
  *
  */
  Queryable<T> DefaultIfEmpty ([T defaultValue]) {
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
  *
  * We have our pie list, but let's say we add a duplicate Lemon pie to our collection:
  *
  *     var pieList = new List.from(Pie.GetTestPies() as Iterable<Pie>);
  *     pieList.add(new Pie("Lemon", 0.99));
  *     var pies = new Queryable(pieList);
  *
  * We know that there are now two duplicate Lemon pies in our `pies` sequence, but we can use the [Distinct] method to
  * remove the duplicates from the collection:
  *
  *     pies.Distinct()
  *         .ForEach((p) => print(p));
  *
  *     >> Apple (3.29)
  *     >> Cherry (4.29)
  *     >> Lemon (0.99)
  *     >> Blueberry (4.29)
  *     >> Meat (5.7)
  *     >> Meat (2.99)
  *
  * Because [Distinct] uses the default comparer for [Pie] which compares two pies as strings, it sees `Meat (5.7)` and
  * `Meat (2.99)` as two distinct elements.
  */
  Queryable<T> Distinct () {
    for (T t in this._source) {
      if (!(new Queryable(this._listSource)).Contains(t)) {
        this._listSource.add(t);
      }
    }

    return new Queryable(this._listSource);
  }

  /**
  * Returns the element at a specified index in a sequence.
  * ---
  * * a [LinqException] will be thrown if [index] is less than zero or is greater than the length of the sequence
  *
  */
  T ElementAt (int index) {
    // Error checking
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
  *
  * Like [ElementAt], this method returns the element at the specified index in the sequence. If the element lays
  * outside the bounds of the sequence, instead of throwing a [LinqException], a default value will be returned. If
  * [defaultValue] isn't provided, a null value will be returned.
  */
  T ElementAtOrDefault (int index, [T defaultValue]) {
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
  * Returns the current sequence except the elements specified in the input collection. The generic type of the
  * sequences [T] must implement the [Comparable](http://api.dartlang.org/dart_core/Comparable.html) interface.
  *
  * ---
  *
  * So this method can be thought of as the opposite of the `Concat` method: return all the elements except the ones we
  * specify. Say we have our complete pie collection and we want to remove the berry flavored pies:
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
  *
  * We have our list of pies, but perhaps we want to find out from another bakery what the overlap between what they're
  * selling and what we're selling is. [Intersect] allows us to do that. For example, we have our list of pies:
  *
  *     var pies = new Queryable(Pie.GetTestPies());
  *
  * we create a second collection with the competitor's pies:
  *
  *     var otherPies = new List.from([
  *       new Pie("Raspberry", 4.3),
  *       new Pie("Cherry", 4.29),
  *       new Pie("Gooseberry", 3.19),
  *       new Pie("Blueberry", 4.29),
  *       new Pie("Mulberry", 1.99)
  *     ]);
  *
  * We then ask for the *intersection* of `pies` with `otherPies` to find out what both of us are selling:
  *
  *     pies.Intersect(otherPies)
  *         .ForEach((p) => print(p));
  *
  *     >> Cherry (4.29)
  *     >> Blueberry (4.29)
  *
  * Remember that this is using the comparer defined in [Pie] which uses both the name and cost to determine if two
  * objects represent the same value.
  */
  Queryable<T> Intersect (Collection<T> other) {
    List<T> interim = new List();

    for (T t in other) {
      if (this.Contains(t)) {
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
   * Returns the minimum value in a sequence.
   * ---
   *
   * &rarr; a [CastException](http://api.dartlang.org/docs/continuous/dart_core/CastException.html) will be thrown if
   * [T] is not a [num] or if a predicate is provided, the predicate does not return a [num]
   *
   * &rarr; a [LinqException] will be thrown if the sequence contains zero elements
   *
   * ---
   *
   * We can use the [Min] method to find the minimum value in a [Queryable] that contains some numbers:
   *
   *     var numbers = new Queryable([1,3,2,5,3,6,4]);
   *     print(numbers.Min());
   *
   *     >> 1
   *
   * We can also pass in a predicate which returns a [num] to select the maximum if [T] is not a [num]-typed collection.
   * For example, let's find out the most costly pie in our pie collection:
   *
   *     var pies = new Queryable(Pies.GetTestPies());
   *     print(pies.Min((p) => p.cost));
   *
   *     >> 0.99
   *
   */
   num Min ([num fn(T element)]) {
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
  *     >> Item: Apple     Cost: $3.29
  *     >> Item: Cherry    Cost: $4.29
  *     >> Item: Lemon     Cost: $0.99
  *     >> Item: Blueberry Cost: $4.29
  *     >> Item: Meat      Cost: $5.7
  *     >> Item: Meat      Cost: $2.99
  */
  Queryable<Dynamic> Select (Dynamic fn(T element))
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
  *
  * ---
  *
  * While it goes without saying that a predicate-less call to [Single] will return the element, [Single] is great for
  * pulling unique items out of a collection. For example, let's grab the object associated with an Apple pie:
  *
  *     var pies = new Queryable(Pie.GetTestPies());
  *     print(pies.Single((p) => p.name == "Apple"));
  *
  *     >> Apple (3.29)
  */
  T Single (bool fn(T element)) {
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
  * Returns the only element of a sequence or default, or the only element that matches a predicate or default
  * ---
  *
  * [SingleOrDefault] is exactly the same as [Single], however instead of throwing an exception it returns a default
  * value ([null]).
  */
  T SingleOrDefault (bool fn(T element)) {
    if (fn == null) {
      List<T> interim = this.ToList();
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
  Queryable<T> SkipWhile(bool fn(T element)) {
    int index;

    for (index = 0; index < this._listSource.length; index++) {
      if (!fn(this._listSource[index])) {
        break;
      }
    }

    return new Queryable(this._listSource).Skip(index);
  }

  /**
  * Computes the sum of a sequence.
  * ---
  * * a [LinqException] will be thrown if the source sequence is null
  */
  num Sum ([num fn(T element)]) {
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
  Queryable<T> Take (int count) {
    return new Queryable(this._listSource.getRange(0, count >= this._listSource.length ? this._listSource.length : count));
  }

  /**
  * Returns elements from a sequence as long as a specified condition is true.
  * ---
  */
  Queryable<T> TakeWhile(bool fn(T element)) {
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
  List<T> ToList() {
    return new List.from(this._source as Iterable<T>);
  }

  /**
  * Produces the set union of two sequences
  * ---
  */
  Queryable<T> Union (Iterable<T> other) {
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
  Queryable<T> Where (Function fn) {
    return new Queryable(this._source.filter(fn));
  }

  /**
  * Applies a specified function to the corresponding elements of two sequences, producing a sequence of the results.
  * ---
  */
  Queryable<Object> Zip (Collection<T> other, Object fn (T first, T second)) {

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