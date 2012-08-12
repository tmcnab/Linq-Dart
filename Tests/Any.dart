
class AnyTests {
  AnyTests() {
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
  }
}
