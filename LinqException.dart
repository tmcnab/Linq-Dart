/**
*
*/
class LinqException implements Exception {

  String _message;
  String get message() => this._message;

  Exception _innerException;
  Exception get innerException() => this._innerException;

  /**
  *
  */
  LinqException (String message, [Exception innerException]) {
    this._message = message;
    this._innerException = innerException;
  }

  String toString() {
    return this._message;
  }
}