require 'minitest/autorun'
require 'pandocomatic'

class TestConfiguration < Minitest::Test

    def test_extend_simple_value()
        assert_equal 1, Pandocomatic::Configuration.extend_value(1, 2)
        assert_equal 2, Pandocomatic::Configuration.extend_value(2, 1)
        assert_equal "some string", Pandocomatic::Configuration.extend_value("some string", "or another string")
        assert_equal true, Pandocomatic::Configuration.extend_value(true, false)
        assert_equal false, Pandocomatic::Configuration.extend_value(false, true)
        assert_equal [1], Pandocomatic::Configuration.extend_value([1], false)
        assert_equal true, Pandocomatic::Configuration.extend_value(true, nil)
        assert_nil Pandocomatic::Configuration.extend_value(nil, 2)
    end
    
    def test_extend_hash_empty()
        hash = { "a" => 1 }
        assert_equal hash, Pandocomatic::Configuration.extend_value(hash, {})
        assert_nil Pandocomatic::Configuration.extend_value(nil, hash)
        extended = Pandocomatic::Configuration.extend_value(hash, {})
        assert_instance_of Hash, extended
        assert extended.has_key? "a"
        assert extended["a"], 1
    end

    def test_extend_hash_add_property()
        current = {"a" => 1}
        parent = {"b" => 2}
        extended = Pandocomatic::Configuration.extend_value(current, parent)
        assert_instance_of Hash, extended
        assert extended.has_key? "a"
        assert extended.has_key? "b"
        assert extended["a"], 1
        assert extended["b"], 2
    end

    def test_extend_hash_replace_property()
        current = {"a" => 1, "b" => 3}
        parent = {"b" => 2}
        extended = Pandocomatic::Configuration.extend_value(current, parent)
        assert_instance_of Hash, extended
        assert extended.has_key? "a"
        assert extended.has_key? "b"
        assert extended["b"], 3
    end
    
    def test_extend_hash_remove_property()
        current = {"a" => 1, "b" => nil}
        parent = {"b" => 2}
        extended = Pandocomatic::Configuration.extend_value(current, parent)
        assert_instance_of Hash, extended
        assert extended.has_key? "a"
        refute extended.has_key? "b"
    end
        
    def test_extend_array_empty()
        array = [1]
        assert_equal array, Pandocomatic::Configuration.extend_value(array, [])
        assert_nil Pandocomatic::Configuration.extend_value(nil, array)
        extended = Pandocomatic::Configuration.extend_value(array, [])
        assert_instance_of Array, extended
        assert_includes extended, 1
    end
        
    def test_extend_array_add_value()
        current = [1]
        parent = [2]
        extended = Pandocomatic::Configuration.extend_value(current, parent)
        assert_includes extended, 1
        assert_includes extended, 2
        assert extended.count, 2
        current = [1]
        parent = [1]
        extended = Pandocomatic::Configuration.extend_value(current, parent)
        assert_includes extended, 1
        assert extended.count, 1
    end
        
    def test_extend_array_remove_value()
        current = {
            'remove' => 2
        }
        parent = [1, 2]
        extended = Pandocomatic::Configuration.extend_value(current, parent)
        assert_instance_of Array, extended
        assert_includes extended, 1
        refute_includes extended, 2
        assert extended.count, 1

        current = {
            'remove' => [ 2, 1]
        }
        parent = [1, 2]
        extended = Pandocomatic::Configuration.extend_value(current, parent)
        refute_includes extended, 1
        refute_includes extended, 2
        assert extended.count, 0
    end
    
    def test_extend_array_remove_and_add_value()
        current = {
            'remove' => 2,
            'add' => [3]
        }
        parent = [1, 2]
        extended = Pandocomatic::Configuration.extend_value(current, parent)
        assert_instance_of Array, extended
        assert_includes extended, 1
        refute_includes extended, 2
        assert_includes extended, 3
        assert extended.count, 2

        current = {
            'remove' => [ 2, 1],
            'add' => 3
        }
        parent = [1, 2]
        extended = Pandocomatic::Configuration.extend_value(current, parent)
        refute_includes extended, 1
        refute_includes extended, 2
        assert_includes extended, 3
        assert extended.count, 1
    end

    def test_incompatible_combinations()
        current = 3
        parent = [1]
        extended = Pandocomatic::Configuration.extend_value(current, parent)
        assert_instance_of Integer, extended
        assert_equal 3, extended
        
        current = 3
        parent = {"a" => 1}
        extended = Pandocomatic::Configuration.extend_value(current, parent)
        assert_instance_of Integer, extended
        assert_equal 3, extended
    end

end
