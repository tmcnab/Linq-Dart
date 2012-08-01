class Pie 
{
    String name;
    double cost;

    Pie (var name, var cost) {
        this.cost = cost;
        this.name = name;
    }

    String toString() {
        return "${this.name} (${this.cost})";
    }

    static Collection<Pie> GetTestPies() {
        List<Pie> pies = new List();

        pies.add(new Pie("Apple", 3.29));
        pies.add(new Pie("Cherry", 4.29));
        pies.add(new Pie("Lemon", 0.99));
        pies.add(new Pie("Blueberry", 4.29));
        pies.add(new Pie("Meat", 5.70));
        pies.add(new Pie("Meat", 2.99));

        return pies;
    }

    bool Equals (Pie B) {
        if(this.cost == B.cost && this.name == B.name) {
            return true;
        } else {
            return false;
        }
    }
}

