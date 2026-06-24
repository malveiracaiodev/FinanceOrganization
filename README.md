# 🌌 Finance Organization - Mark I

O **Mark I** é um app de controle financeiro pessoal que eu criei em Flutter para resolver um problema real: parar de se perder com contas diárias e compras parceladas no cartão de crédito. 

A ideia dele é ser direto ao ponto, com um visual dark focado no espaço (Astra Theme) e rodando 100% local no aparelho para manter os dados seguros.

## 🚀 O que o app faz de verdade

* **Dashboard Sem Enrolação:** Mostra o saldo real atualizado na hora, já descontando o que você gastou no dia, o que previu gastar e as parcelas do mês.
* **Controle de Parcelas Inteligente:** Você cadastra a compra (Ex: Notebook de 12x), o app calcula o valor mensal e joga na fatura atual. Quando o mês vira, ele sabe o progresso (2x de 12x, 3x de 12x...) sem você precisar fazer conta de cabeça.
* **Fechamento de Mês Manual:** Um botão para resetar o mês atual e salvar o histórico. O saldo que sobrou vai direto para uma linha do tempo para você acompanhar os meses passados.
* **Histórico Editável:** Deu ruim ou esqueceu de lançar algo em um mês antigo? Dá para editar os registros passados direto pela tela de histórico.

## 🛠️ Por dentro do código (Tech Stack)

* **Framework:** Flutter (Canal Stable)
* **Linguagem:** Dart
* **Banco de Dados:** `shared_preferences` (Salvando tudo localmente em formato JSON estruturado).
* **UI:** Design escuro customizado com transições de tela usando `Navigator.pushReplacement` para economizar memória do celular.

## 🛸 Como funciona o Build Automático (CI/CD)

Como eu desenvolvo direto pelo navegador no `vscode.dev`, configurei um fluxo com o **GitHub Actions** (`build.yml`). 

Toda vez que eu dou um `git push` no código:
1. Os servidores do GitHub criam uma máquina virtual Linux.
2. Limpam o cache antigo com `flutter clean` e instalam as dependências.
3. Compilam o projeto gerando o arquivo `.apk` final em modo Release.
4. O instalador fica pronto para baixar direto na aba **Actions** do repositório!

## 🏃 Como rodar local

Se quiser testar a máquina na sua máquina física:

1. Baixe as dependências:
   ```bash
   flutter pub get
