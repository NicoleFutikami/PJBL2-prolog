# Decisões de Modelagem — PjBL2

## 1. Objetivo

O projeto implementa uma tabela de classificação de um
campeonato fictício de futebol, utilizando os fundamentos
da programação funcional em Haskell.

O sistema foi dividido em três camadas: representação dos
dados, cálculo da classificação e leitura e validação.

## 2. Organização dos módulos

- Tipos.hs: tipos algébricos e consultas básicas.
- Classificacao.hs: cálculos e estatísticas.
- Leitura.hs: leitura, validação e formatação.
- Dados.hs: dados válidos e inválidos para demonstração.
- Main.hs: integração e execução do programa.
- Testes.hs: testes automatizados.

A divisão facilita a manutenção, os testes e a separação
de responsabilidades.

## 3. Tipos algébricos

O tipo Resultado foi implementado como um tipo soma,
com os construtores Vitoria, Empate e Derrota.

Essa escolha impede a representação de resultados
inexistentes por meio de Strings ou números arbitrários.

Partida e Linha foram implementados como records.
Os campos nomeados tornam o código mais legível e
diminuem a possibilidade de trocar valores por engano.

O tipo Time é um sinônimo de String, conforme solicitado
no enunciado.

## 4. Funções de ordem superior

A classificação foi implementada sem recursão explícita.

A função map gera uma linha para cada time.
A função filter seleciona partidas de um time ou rodada.
A função foldl acumula as estatísticas de cada equipe.

Escolhemos foldl porque o cálculo parte de uma linha
inicial zerada, atualizada conforme as partidas são
processadas.

A composição de funções permite combinar operações
sem criar variáveis intermediárias desnecessárias.

## 5. Critérios de classificação

A pontuação segue as regras tradicionais do futebol:

- Vitória: 3 pontos.
- Empate: 1 ponto.
- Derrota: 0 pontos.

A ordenação utiliza os seguintes critérios:

1. Maior quantidade de pontos.
2. Maior quantidade de vitórias.
3. Maior saldo de gols.
4. Maior quantidade de gols pró.
5. Ordem alfabética.

Utilizamos sortBy, comparing, Down e o operador <>.

Down permite ordenar valores em ordem decrescente.
O operador <> combina os critérios, utilizando o próximo
quando o resultado da comparação anterior é EQ.

A ordem alfabética garante uma classificação determinística
quando todos os critérios esportivos estão empatados.

## 6. Utilização de Maybe

Maybe foi utilizado para representar situações nas quais
um resultado pode não existir.

A função resultadoPara retorna Nothing quando o time
consultado não participou da partida.

As funções maiorGoleada e mediaGols retornam Nothing
quando o campeonato não possui partidas.

O uso de Maybe evita a necessidade de valores artificiais
e permite tratar explicitamente a ausência de resultados.

## 7. Utilização de Either

Either Erro Partida representa o sucesso ou a falha
durante a leitura de uma partida.

Right contém uma partida válida.
Left contém o erro encontrado.

A notação do permite encadear as validações e interromper
o processamento quando uma delas falha.

A função readMaybe foi escolhida em vez de read para
evitar exceções durante a conversão de números inválidos.

A função traverse permite realizar a leitura do campeonato
e propagar o primeiro erro encontrado.

## 8. Tratamento de erros

O sistema identifica:

- Quantidade incorreta de campos.
- Números inválidos.
- Placares negativos.
- Partidas entre um time e ele mesmo.
- Times repetidos na mesma rodada.
- Rodadas menores ou iguais a zero.
- Nomes de times vazios.

Linhas em branco e comentários são ignorados, preservando
a numeração original das linhas.

A função scanl mantém os estados intermediários dos
times registrados em cada rodada.

A função todosOsErros reúne os erros encontrados sem
interromper a análise no primeiro problema.

## 9. Campeonato de teste

Foi escolhido um campeonato fictício com seis equipes:

- Athletico.
- Coritiba.
- Londrina.
- Maringá.
- Operário.
- Paraná.

O campeonato possui cinco rodadas e quinze partidas.

Os resultados foram planejados para incluir:

- Empates sem gols.
- Vitória por quatro gols de diferença.
- Empate em pontos na classificação final.
- Desempate por quantidade de vitórias.
- Desempate por saldo de gols.
- Mudança de liderança após a terceira rodada.

Os resultados são fictícios e não representam partidas
oficiais desses clubes.

## 10. Separação entre funções puras e IO

As operações de cálculo, leitura e validação são funções
puras, podendo ser testadas independentemente da execução
do programa principal.

No programa principal, somente main utiliza IO.

Os dados são armazenados como String, evitando depender
de entrada pelo teclado e permitindo adaptar o programa
para execução no Haskell Playground.

## 11. Robustez

O sistema evita funções parciais como read, head,
maximum e foldr1.

O campeonato vazio é aceito e produz uma classificação
vazia, com Nothing para as estatísticas que dependem
da existência de partidas.

O aproveitamento de um time sem jogos é zero, evitando
divisão por zero.

Quando duas partidas possuem a mesma diferença máxima
de gols, maiorGoleada mantém a primeira encontrada.

## 12. Limitações conhecidas

O projeto foi desenvolvido para campeonatos de futebol
representados pelo formato textual especificado.

As principais limitações são:

- Os nomes dos times diferenciam maiúsculas e minúsculas.
- Não existe cadastro prévio de equipes.
- O sistema não verifica se todas as rodadas estão completas.
- Não existe validação de um calendário oficial de partidas.
- O sistema não implementa confronto direto como desempate.
- O tipo Int possui limites de representação, podendo
  ocorrer overflow com valores numéricos extremos.
- Cada linha malformada retorna seu primeiro erro local.
- A verificação de repetições considera as partidas que
  passaram pela validação individual.
- A tabela utiliza larguras mínimas fixas nas colunas
  numéricas, adequadas ao campeonato de demonstração.
- O uso de listas para controlar times e rodadas prioriza
  a simplicidade em vez do desempenho em grandes volumes.

Essas limitações foram consideradas aceitáveis para o
escopo acadêmico do projeto.

## 13. Possíveis melhorias futuras

- Cadastro e identificação única dos times.
- Validação de calendários completos.
- Leitura de arquivos externos.
- Relatórios estatísticos adicionais.
- Suporte a critérios específicos de outros campeonatos.
- Validação dos limites dos valores numéricos.
- Coleta de múltiplos erros em uma mesma linha.

## 14. Conclusão

A implementação aplica tipos algébricos, funções de ordem
superior, composição, Maybe, Either e funções puras para
resolver um problema de classificação esportiva.

As decisões priorizam legibilidade, segurança,
modularização e os conceitos de programação funcional
estudados na disciplina.