---
layout: post
title: "Publicando gems Ruby com GitHub Actions"
description: "Automatize a publicação de gems Ruby com GitHub Actions"
tags: [automation, ruby, git, github]
---

Neste post, vou mostrar como usar o GitHub Actions pra automatizar a publicação de gems sempre que uma nova versão é criada.

###### Vamos ver os seguintes tópicos:
- Criação e publicação de gems
- Introdução ao GitHub Actions
- Versionamento de gems e manutenção do changelog
- Configuração do GitHub Actions pra publicar gems
- Automação da publicação com a criação de tags

### Criação e publicação de gems

Em Ruby, bibliotecas de código são chamadas de gems. Elas podem ser encontradas e instaladas a partir de um repositório público chamado [RubyGems](https://rubygems.org/){:target="_blank"}, o principal serviço de hospedagem e gestão de gems da comunidade Ruby.

Pra criar uma nova gem, você pode usar o comando `bundle gem`, que vem com a gem `bundler`.

```shell
$ bundle gem my_gem
```

Esse comando gera os arquivos e diretórios necessários pra gem.

```shell
my_gem
├── Gemfile
├── README.md
├── Rakefile
├── lib
│   ├── my_gem
│   │   └── version.rb
│   └── my_gem.rb
├── my_gem.gemspec
└── spec
    ├── my_gem_spec.rb
    └── spec_helper.rb
```

Quando a gem estiver pronta, é só rodar o `gem build`, que cria um arquivo `.gem` pronto pra ser publicado no RubyGems.

```shell
$ gem build my_gem.gemspec
```

Depois de gerar a gem, é só publicar no RubyGems com o comando `gem push`.

```shell
$ gem push my_gem-0.1.0.gem
```

Obs.: é preciso ter uma conta no RubyGems e estar autenticado pra publicar gems.

### GitHub Actions

Assim como outras ferramentas de CI/CD, o GitHub Actions permite automatizar tarefas como testes, lint e deploys. A configuração fica em arquivos YAML que definem quais processos serão executados, disparados por eventos específicos, como um commit em determinada branch.

O exemplo abaixo mostra um workflow simples do GitHub Actions que roda os testes de uma aplicação Ruby sempre que um novo commit é enviado pra branch `main`:

```yaml
name: RSpec tests

on: 
  push:
    branches:
      - main

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout code
      uses: actions/checkout@v2

    - name: Set up Ruby
      uses: actions/setup-ruby@v1
      with:
        ruby-version: '3.4'

    - name: Install dependencies
      run: bundle install

    - name: Run tests
      run: bundle exec rspec
```

### Versionamento de gems e manutenção do changelog

Quando estamos satisfeitos com o código da gem e queremos lançar uma nova versão, precisamos seguir algumas práticas pra garantir que a gem fique corretamente versionada e documentada.

Vamos usar como exemplo a gem [lean-microsoft-graph](https://github.com/betogrun/lean-microsoft-graph){:target="_blank"}, em que uma nova funcionalidade foi adicionada e algumas dependências foram atualizadas neste [Pull Request](https://github.com/betogrun/lean-microsoft-graph/pull/58){:target="_blank"}.

Depois do merge do código, podemos criar um novo Pull Request alterando o número da versão e atualizando o arquivo `CHANGELOG.md`.

Antes de continuar, vale mencionar as diretrizes do [Versionamento Semântico](https://semver.org/lang/pt-BR/){:target="_blank"}, que seguem o formato `MAJOR.MINOR.PATCH`.

###### O número da versão é incrementado de acordo com o tipo de mudança:
- **Major**: pra mudanças incompatíveis na API
- **Minor**: pra novas funcionalidades compatíveis com versões anteriores
- **Patch**: pra correções de bugs compatíveis com versões anteriores

O arquivo de versão fica em `lib/lean/microsoft/graph/version.rb`. Uma funcionalidade nova sem quebra de compatibilidade pede um bump de minor, o que daria `0.4.0`; esta versão saiu como patch, `0.3.4`, e é essa que vamos usar daqui pra frente.

```ruby
module LeanMicrosoftGraph
  VERSION = "0.3.4"
end
```

Agora precisamos atualizar o arquivo `CHANGELOG.md` com as mudanças da nova versão.

```markdown
# Changelog

<!-- Additional logs omitted for brevity. -->

## [0.3.4] - 2024-08-30

### Added

- Ability to retrieve users by id with `client.users.get_by_id('id')`.

### Changed

- Upgrade dependencies: faraday, mocha and minitest.

<!-- Additional logs omitted for brevity. -->

[0.3.4]: https://github.com/betogrun/lean-microsoft-graph/releases/tag/v0.3.4
```

Dê uma olhada no site [Keep a Changelog](https://keepachangelog.com/pt-BR/){:target="_blank"} pra saber mais sobre como documentar as mudanças no arquivo `CHANGELOG.md`.

A essa altura, já daria pra gerar e publicar a gem manualmente, mas a ideia é automatizar esse processo com o GitHub Actions.

### Configuração do GitHub Actions pra publicar gems

Pra automatizar o processo, precisamos criar um workflow do GitHub, que é um arquivo YAML no diretório .github/workflows. Se ele ainda não existir, dá pra criar o arquivo manualmente ou deixar o GitHub gerar um inicial. No caso da gem [lean-microsoft-graph](https://github.com/betogrun/lean-microsoft-graph){:target="_blank"}, já havia um arquivo ruby.yml responsável por rodar os testes unitários, como mostra este [Pull Request](https://github.com/betogrun/lean-microsoft-graph/pull/19/files){:target="_blank"}.


O GitHub Actions vai precisar de um token de autenticação pra publicar a gem no RubyGems. Esse token deve ser guardado nos secrets do repositório e passado ao workflow como variável de ambiente. O token pode ser obtido no site do RubyGems.

###### Siga estes passos pra adicionar o token aos secrets do repositório:
1. Abra `Settings` no repositório.
2. Navegue até `Secrets and variables` e clique em `Actions`.
3. Clique em `New repository secret`.
4. Dê ao secret o nome RUBYGEMS_AUTH_TOKEN, cole o token obtido e clique em `Add Secret`.

Agora precisamos adicionar ao arquivo YAML um novo job com os steps de publicação.
Também daria pra fazer isso em um workflow separado, mas aqui vamos usar o arquivo que já existe.

O novo job se chama `publish`:

```yaml
jobs:
  publish:
    needs: test
    runs-on: ubuntu-latest
    if: startsWith(github.ref, 'refs/tags/v')
```

###### No exemplo acima, nós:
- Adicionamos a palavra-chave `needs` pra indicar que o job de publicação deve esperar o job de testes terminar com sucesso antes de rodar. Isso cria uma dependência que garante que os testes sejam executados primeiro.
- Definimos o ambiente em que o job vai rodar. Neste exemplo, o job roda na versão mais recente do Ubuntu.
- Incluímos uma condição no job pra garantir que ele só rode quando uma nova tag que comece com `v` for criada, indicando o lançamento de uma versão.

Agora precisamos do step que prepara o ambiente. Neste exemplo, configuramos o Ruby e escolhemos a versão:

```yaml
  steps:
    - uses: actions/checkout@v3  # Check out the repository code

    - name: Set up Ruby
      uses: ruby/setup-ruby@v1
      with:
        ruby-version: '3.4'  # Specify the Ruby version to use
```

Falta o step que gera e publica a gem.<br>
Primeiro, criamos o diretório `.gem` e o arquivo de credenciais. Depois, definimos as permissões do arquivo e gravamos nele o token de autenticação.

```yaml
    - name: Publish to RubyGems
      run: |
        mkdir -p $HOME/.gem
        touch $HOME/.gem/credentials
        chmod 0600 $HOME/.gem/credentials
        printf -- "---\n:rubygems_api_key: ${GEM_HOST_API_KEY}\n" > $HOME/.gem/credentials
```

Em seguida, geramos a gem e enviamos pro RubyGems:

```yaml
        gem build *.gemspec
        gem push *.gem
```

Não dá pra esquecer a palavra-chave `env`, que pega o token de autenticação do RubyGems nos secrets do repositório:

```yaml
      env:
        GEM_HOST_API_KEY: ${{ secrets.RUBYGEMS_AUTH_TOKEN  }}
```

O job completo de publicação da gem deve ficar assim:

```yaml
publish:
    needs: test
    runs-on: ubuntu-latest
    if: startsWith(github.ref, 'refs/tags/v')
    steps:
      - uses: actions/checkout@v3
      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.4'
      - name: Publish to RubyGems
        run: |
          mkdir -p $HOME/.gem
          touch $HOME/.gem/credentials
          chmod 0600 $HOME/.gem/credentials
          printf -- "---\n:rubygems_api_key: ${GEM_HOST_API_KEY}\n" > $HOME/.gem/credentials
          gem build *.gemspec
          gem push *.gem
        env:
          GEM_HOST_API_KEY: ${{ secrets.RUBYGEMS_AUTH_TOKEN  }}
```

### Automação da publicação com a criação de tags

Por fim, depois do merge do [Pull Request](https://github.com/betogrun/lean-microsoft-graph/pull/60){:target="_blank"} que atualiza a versão da gem e o changelog, o próximo passo é criar a tag da nova versão com o seguinte comando:

```shell
$ git tag -a v0.3.4 -m "Version 0.3.4"
```

A flag `-a` cria uma tag anotada, e a flag `-m` adiciona uma mensagem à tag. As duas são opcionais.

Depois disso, precisamos enviar a tag pro repositório remoto no GitHub:

```shell
$ git push origin v0.3.4
```

Depois que a tag é enviada, o workflow do GitHub Actions é disparado, e a gem é gerada e publicada no RubyGems.

O resultado do workflow pode ser conferido na aba Actions do repositório.

![Workflow do GitHub Actions](/images/post_2024_8_30/github-actions.png){: .zooming}

A nova versão da gem fica disponível no RubyGems, e as mudanças aparecem na [página da gem](https://rubygems.org/gems/lean-microsoft-graph){:target="_blank"}.

### Conclusão

Este post mostrou como automatizar a publicação de gems Ruby com o GitHub Actions e também passou pelas boas práticas de versionamento e de manutenção do changelog.<br>
Fique à vontade pra contar como você usa o GitHub Actions nos seus workflows e como prefere versionar e publicar gems.

### Referências

- [RubyGems](https://rubygems.org/){:target="_blank"}
- [GitHub Actions](https://docs.github.com/pt/actions){:target="_blank"}
- [Versionamento Semântico](https://semver.org/lang/pt-BR/){:target="_blank"}
- [Keep a Changelog](https://keepachangelog.com/pt-BR/){:target="_blank"}
