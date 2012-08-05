/**
* Defines an interface that implementers use to create deep copies of an
* object instance.
*/
interface Clonable<T> {

  /**
  * Returns a deep-copy (new instance) of T.
  */
  T clone ();
}
