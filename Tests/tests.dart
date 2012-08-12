#library('dart:linq:tests');
#import('dart:core');
#import('../Linq.dart');
//#import('dart:unittest');
#import('/Applications/dart/dart-sdk/lib/unittest/unittest.dart');
#import('dart:io');
#import('dart:coreimpl');

#source('Pie.dart');
#source('Any.dart');

class TestRunner {
  TestRunner() {
    new AnyTests();
  }
}