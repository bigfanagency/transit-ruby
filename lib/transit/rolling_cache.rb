# Copyright (c) Cognitect, Inc.
# All rights reserved.

module Transit
  class RollingCache
    FIRST_ORD = 33
    CACHE_SIZE = 94**2
    MIN_SIZE_CACHEABLE = 4

    def initialize
      clear
    end

    def clear
      @key_to_value = {}
      @value_to_key = {}
    end

    def maybe_encache(name, as_map_key)
      cacheable?(name, as_map_key) ? encache(name) : name
    end

    def decode(name, as_map_key=false)
      @key_to_value[name] || maybe_encache(name, as_map_key)
    end

    def encode(name, as_map_key=false)
      @value_to_key[name] || maybe_encache(name, as_map_key)
    end

    def cache_key?(name)
      @key_to_value.has_key?(name)
    end

    def size
      @key_to_value.size
    end

    def cache_full?
      @key_to_value.size >= CACHE_SIZE
    end

    def cacheable?(str, as_map_key=false)
      str.size >= MIN_SIZE_CACHEABLE && (as_map_key || str.start_with?("~#","~$","~:"))
    end

    private

    def encache(name)
      clear if cache_full?

      @value_to_key[name] || begin
                               key = encode_key(@key_to_value.size)
                               @value_to_key[name] = key
                               @key_to_value[key]  = name
                             end
    end

    def encode_key(i)
      hi = i / 94;
      lo = i % 94;
      if hi == 0
        "^#{(lo+FIRST_ORD).chr}"
      else
        "^#{(hi+FIRST_ORD).chr}#{(lo+FIRST_ORD).chr}"
      end
    end

    def decode_key(s)
      if s.length == 2
        s.chr.ord - FIRST_ORD
      else
        ((s[0].ord - FIRST_ORD) * 94) + (s[1].ord - FIRST_ORD)
      end
    end
  end
end
