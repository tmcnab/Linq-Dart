#import('dart:core');
#import('unittest/unittest.dart');
#import('linq.dart');
#source('Pie.dart');

void main() {

  print(new Queryable(Pie.GetTestPies()).First());
  print(new Queryable(Pie.GetTestPies()).First((p) => p.cost > 5));
  /*
  group ('Any', () {
      Queryable<Pie> allpies = new Queryable(Pie.GetTestPies());
      Queryable<Pie>  nopies = new Queryable(new List());
      Queryable<Pie> nullpies = new Queryable(null);

      test ('1', () { expect(allpies.Any(),                   equals(true));  });
      test ('2', () { expect(nopies.Any(),                    equals(false)); });
      test ('3', () { expect(allpies.Any((p) => p.cost > 3),  equals(true));  });
      test ('4', () { expect(allpies.Any((p) => p.cost > 20), equals(false)); });
      test ('5', () { expect(nopies.Any( (p) => p.cost > 20), equals(false)); });
      test ('6', () { expect(allpies.Any((p) => p.cost == 0), equals(false)); });
  });

  group ('First', () {
      Queryable<Pie> allpies = new Queryable(Pie.GetTestPies());
      Pie firstPie = new Pie("Apple", 3.29);
      Pie anotherPie = new Pie("Blueberry", 4.29);

      test ('1', () { expect(allpies.First().compareTo(firstPie),                               equals(true));  });
      test ('2', () { expect(allpies.First().compareTo(anotherPie),                             equals(false)); });
      test ('3', () { expect(allpies.First((p) => p.name == "Blueberry").compareTo(anotherPie), equals(true));  });
  });
  */

}