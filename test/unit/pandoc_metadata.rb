require 'minitest/autorun'
require 'pandocomatic'

class TestPandocMetadata < Minitest::Test
    def test_load_no_metadata()
        inputs = [
            "",
            "---\n...\n",
            "---\n---\n", 
            "This\nis a document\nwithout metadata",
            "This is\n a document\n\n---\n...\nwith metadata, albeit empty",
            "\n\n---\n# comment: also counts as empty\n...\n\n"
        ]
        inputs.each do |input|
            metadata = Pandocomatic::PandocMetadata.load(input)
            assert_empty metadata
        end
    end

    def test_load_single_metadata_block()
        inputs = {
            "---\nkey: value\n---\n" => {
                "key" => "value"
            },
            "---\nkey: 2\n---\n" => {
                "key" => 2
            },
            "---\nkey: true\n---\n" => {
                "key" => true
            },
            "---\nkey: 2.05\n---\n" => {
                "key" => 2.05
            },
            "---\nkey: [1, 2, 3, 4]\n---\n" => {
                "key" => [1, 2, 3, 4]
            },
            "---\nkey:\n  subkey: value\n---\n" => {
                "key" => { "subkey" => "value" }
            }
        }

        inputs.each do |input, output|
            metadata = Pandocomatic::PandocMetadata.load(input)
            assert metadata.has_key? "key"
            assert metadata["key"] = output["key"]
        end
    end

    def test_load_multiple_metadata_blocks()
        inputs = {
            "---\nkey: value\n---\n\nsome text\n\n---\nkey2: 3\n...\n\n and so on" => {
                "key" => "value",
                "key2" => 3
            },
            "---\nkey: 2\n---\n---\nkey2: [1,2,3]\n---\n" => {
                "key" => 2,
                "key2" => [1, 2, 3]
            }
        }

        inputs.each do |input, output|
            metadata = Pandocomatic::PandocMetadata.load(input)
            assert metadata.has_key? "key"
            assert metadata["key"] = output["key"]
            assert metadata.has_key? "key2"
            assert metadata["key2"] = output["key2"]
        end
    end

    def test_load_single_pandocomatic_property()
        input = "---\npandocomatic_:\n  pandoc:\n    from: markdown\n    to: pdf\n...\n\nA document with a pandocomatic metadata property in a single metadata block."
        metadata = Pandocomatic::PandocMetadata.load(input)
        assert metadata.has_key? "pandocomatic_"
        assert metadata.has_pandocomatic?
        assert metadata.has_pandoc_options?
        assert metadata.pandoc_options["from"] = "pdf"

        input = "---\ntitle: A document with two metadata blocks\n...\nThen some text, followed by the second block with a pandocomatic property\n---\npandocomatic_:\n  pandoc:\n    from: markdown\n    to: pdf\n...\n\nA document with a pandocomatic metadata property in two metadata blocks."
        metadata = Pandocomatic::PandocMetadata.load(input)
        assert metadata.has_key? "pandocomatic_"
        assert metadata.has_pandocomatic?
        assert metadata.has_pandoc_options?
        assert metadata.unique?
        assert metadata.pandoc_options["from"] = "pdf"
    end

    def test_load_multiple_pandocomatic_properties()
        input = "---\ntitle: A document with two metadata blocks and two pandocomatic properties\npandocomatic_:\n  pandoc:\n    from: latex\n...\nThen some text, followed by the second block with a pandocomatic property\n---\npandocomatic_:\n  pandoc:\n    from: markdown\n    to: pdf\n...\n\nA document with two pandocomatic metadata properties in two metadata blocks."
        metadata = Pandocomatic::PandocMetadata.load(input)
        assert metadata.has_key? "pandocomatic_"
        assert metadata.has_pandocomatic?
        assert metadata.has_pandoc_options?
        refute metadata.unique?
        assert metadata.pandoc_options["from"] = "latex"
    end
end
