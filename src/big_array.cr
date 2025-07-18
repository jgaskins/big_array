class BigArray(T)
  include Indexable(T)
  include Indexable::Mutable(T)

  # How much to resize by each time the
  RESIZE_COEFFICIENT = 1.5

  # The minimum capacity of a buffer to allocate
  MIN_CAPACITY = 8i64

  @buffer : Pointer(T)
  @capacity : Int64
  getter size : Int64
  protected setter size

  def self.build(capacity : Int64, &)
    array = new(initial_capacity: capacity)
    array.size = yield(array.to_unsafe).to_i64
    array
  end

  def initialize(initial_capacity @capacity = 0)
    @size = 0
    case capacity
    when .negative?
      raise ArgumentError.new("Array sizes must not be negative")
    when 0
      # Don't allocate unless we need to hold actual data.
      @buffer = Pointer(T).null
    else
      @buffer = Pointer(T).malloc({capacity, MIN_CAPACITY}.max)
    end
  end

  @[AlwaysInline]
  def unsafe_fetch(index : Int)
    @buffer[index]
  end

  @[AlwaysInline]
  def unsafe_put(index : Int, value : T)
    @buffer[index] = value
  end

  def <<(value : T) : self
    ensure_capacity size + 1i64
    @buffer[size] = value
    @size += 1i64
    self
  end

  def +(other : BigArray(U)) : BigArray(T | U) forall U
    new_size = size + other.size
    BigArray(T | U).build(new_size) do |buffer|
      buffer.copy_from(@buffer, size)
      (buffer + size).copy_from(other.to_unsafe, other.size)
      new_size
    end
  end

  def each_index(&) : Nil
    index = 0i64
    while index < size
      yield index
      index += 1i64
    end
  end

  def to_unsafe
    @buffer
  end

  private def ensure_capacity(size : Int64) : Nil
    return if @capacity >= size

    capacity = {
      # We need to be able to accommocate at least the size we're given
      size,
      # If we're only increasing the size by 1 a bunch of times, we don't want
      # to reallocate each time. Multiplying capacity by a resize coefficient
      # each time results in fewer reallocations.
      (@capacity * RESIZE_COEFFICIENT).to_i64,

      # If we're allocating at all, make sure we're allocating at least the
      # minimum capacity so that building the array up from nothing doesn't
      # result in rapid-fire allocations up front.
      MIN_CAPACITY,
    }.max
    @buffer = @buffer.realloc(capacity)
    # Only set the new capacity if the buffer realloc succeeds
    @capacity = capacity
  end
end
