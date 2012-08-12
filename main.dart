#import('dart:core');
#import('linq.dart');
#import('Tests/tests.dart');

void main() {

  // try out some code here when developing/making some examples (remove in production)
  var items = Pie.GetTestPies().map((p) => p.name);

  for (var i in items) {
    print(i);
  }

  // Run the test suite
  //new TestRunner();
}