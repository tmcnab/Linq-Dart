#library('dart:linq');

class LinqException implements Exception {
  var _message;

  LinqException (String message) {
    this._message = message;
  }

  String toString() {
    return this._message;
  }
}


class Queryable<T> {
  Collection<T> _source;

  int _AscendingSort(T a, T b) => 0;
  int _DescendingSort(T a, T b) => 0;

  Queryable(Collection<T> source) {
    this._source = source;
  }

  /**
   * Determines whether any element of a sequence satisfies a condition (if provided).
   */
  bool Any ([Function fn]) {
    if(fn == null) {
      return !this._source.isEmpty();
    }
    else {
      return this._source.some(fn);
    }
  }

  Collection<T> AsCollection () {
    return _source;
  }

  /**
   * Concatenates this sequence with another (appended)
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
   * sequence satisfy a condition (if provided).
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
    * Returns the first element of a sequence, or returns the first element in a
    * sequence that satisfies a specified condition.
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
        if (fn == null)
        {
            var interim = this.ToList();
            if (interim.length > 0)
                return interim [0];
            else
                return null;
        }
        else
        {
            var interim = this.Where(fn).ToList();
            if (interim.length > 0)
                return interim [0];
            else
                return null;
        }
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
   * If no filter function is provided, returns the only element of a sequence
   * and throws an exception if there is not exactly one element in the sequence.
   *
   * If a filter is provided, returns the only element of a sequence that
   * satisfies a specified condition, and throws an exception if less or more
   * than one such element exists.
   */
  T Single ([Function fn]) {
    if (fn == null)
    {
      List<T> interim = this.ToList();
      if (interim.length != 1)
        throw new LinqException("Source collection must contain one item.");
      else
        return interim [0];
    }
    else
    {
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
   */
  Queryable<T> Skip (int count) {
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
   * Filters a sequence of values based on a predicate
   */
  Queryable<T> Where (Function fn) {
    return new Queryable(_source.filter(fn));
  }
}