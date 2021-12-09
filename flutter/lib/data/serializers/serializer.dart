/// Middleware that parses a type [T] to/from a JSON representation.
abstract class Serializer<T extends Object, U> {
  T from(U json);
  U to(T object);
}
