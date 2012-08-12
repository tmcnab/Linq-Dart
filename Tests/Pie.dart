/**
* Test class for LINQ unit testing and documentation examples. This object is
* immutable.
*/
class Pie implements Comparable, Clonable
{
  /**
  * Creates a new instance of the `Pie` class using a given name and cost.
  */
  Pie (String name, double cost) {
    this._cost = cost;
    this._name = name;
  }

  String _name;
  double _cost;

  /**
  * Returns the name of the pie.
  */
  String get name() => _name;

  /**
  * Returns the cost of the pie.
  */
  double get cost() => _cost;

  /**
  * Returns the `String` representation of a `Pie` instance in the form of:
  *
  *     <name> (<cost>)
  */
  String toString() {
    return "${this._name} (${this._cost})";
  }

  /**
  * Returns a collection of pies for use in examples and unit tests. In order,
  * they are:
  *
  *  * Apple     $3.29
  *  * Cherry    $4.29
  *  * Lemon     $0.99
  *  * Blueberry $4.29
  *  * Meat      $5.70
  *  * Meat      $2.99
  */
  static Collection<Pie> GetTestPies() {
    return [
      new Pie("Apple", 3.29),
      new Pie("Cherry", 4.29),
      new Pie("Lemon", 0.99),
      new Pie("Blueberry", 4.29),
      new Pie("Meat", 5.70),
      new Pie("Meat", 2.99)
    ];
  }

  Pie clone () {
    return new Pie(this._name, this._cost);
  }

  /**
  * Comparison function for use in LINQ comparison operations. Calls the
  * `Pie.toString()` method and calls/returns the default string comparitor.
  */
  int compareTo (Comparable other) {
      return this.toString().compareTo(other.toString());
  }
}

