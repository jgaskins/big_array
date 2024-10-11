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

  def self.build(capacity : Int64)
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
      @buffer = Pointer(T).null
    else
      @buffer = Pointer(T).malloc(capacity)
    end
  end

  def unsafe_fetch(index : Int)
    @buffer[index]
  end

  def unsafe_put(index : Int, value : T)
    @buffer[index] = value
  end

  def <<(value : T) : self
    ensure_capacity size + 1
    @buffer[size] = value
    @size += 1
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

  def to_unsafe
    @buffer
  end

  private def ensure_capacity(size : Int64)
    if @capacity < size
      old_capacity = @capacity
      resize_candidates = {(@capacity * RESIZE_COEFFICIENT).to_i64, size, MIN_CAPACITY}
      @capacity = resize_candidates.max
      @buffer = @buffer.realloc(@capacity)
    end
  end
end
