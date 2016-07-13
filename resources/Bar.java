class Bar {
  public static final int x = 10;

  public static int bar(int x) {
    int y = x / 2;
    return y;
  }

  public static int foo(int x) {
    int y = x * 2;
    return bar(y);
  }

  public static void main(String args[]) {
    int z = foo(x);
  }
}
