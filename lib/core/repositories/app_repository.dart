
/// Base contract for application data repositories.
///
/// Feature-specific repositories can implement this interface to provide
/// data from Firebase, REST APIs, local storage, or other sources.
abstract interface class AppRepository<T> {
  /// Loads all records managed by this repository.
  Future<List<T>> getAll();

  /// Loads one record by its identifier.
  Future<T?> getById(String id);
}
