RSpec.describe VimMappingManager do
  before do
    OutputFile.reset!
    VimMappingManager.reset!
  end

  context 'Command' do
    it 'renders simple commands' do
      config_file do
        command('CommandX', ':trigger', desc: 'CommandX desc')
      end

      expected = <<-EXPECTED
        " CommandX desc
        command! CommandX :trigger
      EXPECTED

      renders_properly(expected)
    end

    it 'renders commands with filetype' do
      config_file do
        command('CommandX', ':trigger', desc: 'CommandX desc', filetype: :ruby)
      end

      expected = <<-EXPECTED
        " CommandX desc
        autocmd FileType ruby command! CommandX :trigger
      EXPECTED

      renders_properly(expected)
    end
  end

  context 'withuot Prefix' do
    context 'Normal commands' do
      it 'renders simple normal commands' do
        config_file do
          normal 'X', ':RUN', desc: 'DO X'
        end

        expected = <<-EXPECTED
        " DO X
        nnoremap <silent> X :RUN
        EXPECTED

        renders_properly(expected)
      end

      it 'renders normal commands with filetype' do
        config_file do
          normal 'X', ':RUN', desc: 'DO X', filetype: :ruby
        end

        expected = <<-EXPECTED
        " DO X
        autocmd FileType ruby nnoremap <silent> X :RUN
        EXPECTED

        renders_properly(expected)
      end
    end

    context 'Visual commands' do
      it 'renders simple visual commands' do
        config_file do
          visual 'X', ':RUN', desc: 'DO X'
        end

        expected = <<-EXPECTED
        " DO X
        xnoremap <silent> X :RUN
        EXPECTED

        renders_properly(expected)
      end

      it 'renders visual commands with filetype' do
        config_file do
          visual 'X', ':RUN', desc: 'DO X', filetype: :ruby
        end

        expected = <<-EXPECTED
        " DO X
        autocmd FileType ruby xnoremap <silent> X :RUN
        EXPECTED

        renders_properly(expected)
      end
    end
  end

  context 'with Prefix' do
    context 'Normal commands' do
      it 'renders simple normal commands' do
        config_file do
          prefix('p', name: 'SamplePrefix', desc: 'Does stuff') do
            normal 'X', ':RUN', desc: 'DO X'
          end
        end

        expected = <<-EXPECTED
          " DO X
          nnoremap <silent> pX :RUN
          call extend(g:which_key_map_sampleprefix, {'X':'Do x'})
        EXPECTED

        renders_properly(expected)
      end

      it 'renders normal commands with filetype on the command level' do
        config_file do
          prefix('p', name: 'SamplePrefix', desc: 'Does stuff') do
            normal 'X', ':RUN', desc: 'DO X', filetype: :ruby
          end
        end

        expected = <<-EXPECTED
          " DO X
          autocmd FileType ruby nnoremap <silent> pX :RUN
          autocmd FileType ruby call extend(g:which_key_map_sampleprefix, {'X':'Do x'})
        EXPECTED

        renders_properly(expected)
      end

      it 'renders normal commands with filetype on the prefix level' do
        config_file do
          prefix('p', name: 'SamplePrefix', desc: 'Does stuff', filetype: :ruby) do
            normal 'X', ':RUN', desc: 'DO X'
          end
        end

        expected = <<-EXPECTED
          " DO X
          autocmd FileType ruby nnoremap <silent> pX :RUN
          autocmd FileType ruby call extend(g:which_key_map_sampleprefix, {'X':'Do x'})
        EXPECTED

        renders_properly(expected)
      end
    end

    context 'Visual commands' do
      it 'renders simple visual commands' do
        config_file do
          prefix('p', name: 'SamplePrefix', desc: 'Does stuff') do
            visual 'X', ':RUN', desc: 'DO X'
          end
        end

        expected = <<-EXPECTED
          " DO X
          xnoremap <silent> pX :RUN
        EXPECTED

        renders_properly(expected)
      end

      it 'renders visual commands with filetype on the command level' do
        config_file do
          prefix('p', name: 'SamplePrefix', desc: 'Does stuff') do
            visual 'X', ':RUN', desc: 'DO X', filetype: :ruby
          end
        end

        expected = <<-EXPECTED
          " DO X
          autocmd FileType ruby xnoremap <silent> pX :RUN
        EXPECTED

        renders_properly(expected)
      end

      it 'renders visual commands with filetype on the prefix level' do
        config_file do
          prefix('p', name: 'SamplePrefix', desc: 'Does stuff', filetype: :ruby) do
            visual 'X', ':RUN', desc: 'DO X'
          end
        end

        expected = <<-EXPECTED
          " DO X
          autocmd FileType ruby xnoremap <silent> pX :RUN
        EXPECTED

        renders_properly(expected)
      end
    end


    it 'renders the header properly' do
      config_file do
        prefix(';', name: 'SamplePrefix', desc: 'Does stuff') do
        end
      end

      expected = <<-EXPECTED
        " ----------------------------------------------------------------
        " Prefix SamplePrefix
        " Key ;
        " Does stuff
        " ----------------------------------------------------------------
        let g:which_key_map_sampleprefix = { 'name' : '+SamplePrefix' }
        call which_key#register(';', 'g:which_key_map_sampleprefix')
        nnoremap ; :<c-u>WhichKey ';'<CR>
        vnoremap ; :<c-u>WhichKeyVisual ';'<CR>
      EXPECTED

      renders_properly(expected)
    end

    it 'renders nested prefixes' do
      config_file do
        prefix('a', name: 'SamplePrefix', desc: 'Does stuff') do
          prefix('b', name: 'SampleNestedPrefix', desc: 'Does more stuff') do
            prefix('c', name: 'SampleNestedPrefix', desc: 'Does even more stuff') do
              normal 'D', ':RUN', desc: 'DO C'
            end
          end
        end
      end

      expected = <<-EXPECTED
        " DO C
        nnoremap <silent> abcD :RUN
        call extend(g:which_key_map_sampleprefix['b']['c'], {'D':'Do c'})
      EXPECTED

      renders_properly(expected)
    end
  end

  context 'with Leader' do
    context 'Normal commands' do
      it 'renders simple normal commands' do
        config_file do
          leader('<space>') do
            normal 'X', ':RUN', desc: 'DO X'
          end
        end

        expected = <<-EXPECTED
          " DO X
          nnoremap <silent> <leader>X :RUN
          call extend(g:which_key_map, {'X':'Do x'})
        EXPECTED

        renders_properly(expected)
      end

      it 'renders normal commands with filetype on the command level' do
        config_file do
          leader('<space>') do
            normal 'X', ':RUN', desc: 'DO X', filetype: :ruby
          end
        end

        expected = <<-EXPECTED
          " DO X
          autocmd FileType ruby nnoremap <silent> <leader>X :RUN
          autocmd FileType ruby call extend(g:which_key_map, {'X':'Do x'})
        EXPECTED

        renders_properly(expected)
      end
    end

    context 'Visual commands' do
      it 'renders simple visual commands' do
        config_file do
          leader('<space>') do
            visual 'X', ':RUN', desc: 'DO X'
          end
        end

        expected = <<-EXPECTED
          " DO X
          xnoremap <silent> <leader>X :RUN
        EXPECTED

        renders_properly(expected)
      end

      it 'renders visual commands with filetype on the command level' do
        config_file do
          leader('<space>') do
            visual 'X', ':RUN', desc: 'DO X', filetype: :ruby
          end
        end

        expected = <<-EXPECTED
          " DO X
          autocmd FileType ruby xnoremap <silent> <leader>X :RUN
        EXPECTED

        renders_properly(expected)
      end
    end

    it 'renders the header properly' do
      config_file do
        leader('<space>') do
        end
      end

      expected = <<-EXPECTED
        " ----------------------------------------------------------------
        " Leader
        " ----------------------------------------------------------------
        let mapleader='<space>'

        if !exists('g:which_key_map')
          let g:which_key_map = {}
        endif
        call which_key#register('<leader>', 'g:which_key_map')
        nnoremap <leader> :<c-u>WhichKey '<leader>'<CR>
        vnoremap <leader> :<c-u>WhichKeyVisual '<leader>'<CR>
      EXPECTED

      renders_properly(expected)
    end

    it 'renders nested prefixes' do
      config_file do
        leader('<space>') do
          prefix('a', name: 'SampleNestedPrefix', desc: 'Does more stuff') do
            prefix('b', name: 'SampleNestedPrefix', desc: 'Does even more stuff') do
              normal 'C', ':RUN', desc: 'DO C'
            end
          end
        end
      end

      expected = <<-EXPECTED
        " DO C
        nnoremap <silent> <leader>abC :RUN
        call extend(g:which_key_map['a']['b'], {'C':'Do c'})
      EXPECTED

      renders_properly(expected)
    end
  end

  def config_file(&block)
    VimMappingManager.call(&block)
  end

  def renders_properly(expected)
    VimMappingManager.render

    actual = OutputFile.output

    # Helps on debuging
    path = File.expand_path('./last_render_spec.vimrc')
    File.open(path, 'w+') { |file| file.write(actual) }

    actual = actual.gsub(/^ +/, '')
    expected = expected.gsub(/^ +/, '')


    expect(actual.lines).to include(*expected.lines)
  end
end
