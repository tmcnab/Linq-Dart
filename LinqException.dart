
class LinqException implements Exception {

  var _message;

  LinqException (String message) {
    this._message = message;
  }

  String toString() {
    return this._message;
  }
}