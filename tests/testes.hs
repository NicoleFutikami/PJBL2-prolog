module Main where

import Tipos
import Classificacao
import Leitura
import Dados
import Data.List (isInfixOf)

-- Compara o resultado obtido com o esperado.
testar :: (Eq a, Show a) => String -> a -> a -> IO Bool
testar nome obtido esperado
  | obtido == esperado = do
      putStrLn ("OK - " ++ nome)
      return True
  | otherwise = do
      putStrLn ("FALHOU - " ++ nome)
      putStrLn ("  Esperado: " ++ show esperado)
      putStrLn ("  Obtido:   " ++ show obtido)
      return False

-- Partida utilizada nos testes individuais.
partidaTeste :: Partida
partidaTeste = Partida 1 "Athletico" 4 0 "Paraná"

partidaEmpate :: Partida
partidaEmpate = Partida 1 "Coritiba" 0 0 "Operário"

-- Classificacao final conferida manualmente.
tabelaEsperada :: [Linha]
tabelaEsperada =
  [ Linha "Athletico" 5 3 1 1 10 4
  , Linha "Coritiba"  5 3 1 1  6 3
  , Linha "Maringá"   5 2 1 2  6 5
  , Linha "Operário"  5 1 4 0  4 3
  , Linha "Londrina"  5 1 1 3  6 10
  , Linha "Paraná"    5 0 2 3  4 11
  ]

-- Classificacao esperada apos a terceira rodada.
tabelaRodada3 :: [Linha]
tabelaRodada3 =
  [ Linha "Coritiba"  3 2 1 0 5 1
  , Linha "Maringá"   3 2 0 1 5 3
  , Linha "Operário"  3 1 2 0 3 2
  , Linha "Athletico" 3 1 1 1 5 3
  , Linha "Londrina"  3 1 0 2 3 5
  , Linha "Paraná"    3 0 0 3 2 9
  ]

-- Erros esperados na entrada invalida de Dados.hs.
errosEsperados :: [Erro]
errosEsperados =
  [ TimeRepetidoNaRodada 1 "Athletico"
  , NumeroInvalido 4 "gols do mandante"
  , PlacarNegativo 5
  , MesmoTime 6
  , CamposInvalidos 7
  , RodadaInvalida 8
  , NomeVazio 9
  ]

main :: IO ()
main = do

  putStrLn "=== TESTES DA CAMADA 1 ==="

  testes1 <- sequence
    [ testar "Participacao do mandante"
        (participou "Athletico" partidaTeste) True

    , testar "Participacao do visitante"
        (participou "Paraná" partidaTeste) True

    , testar "Time ausente"
        (participou "Coritiba" partidaTeste) False

    , testar "Vitoria do mandante"
        (resultadoPara "Athletico" partidaTeste)
        (Just Vitoria)

    , testar "Derrota do visitante"
        (resultadoPara "Paraná" partidaTeste)
        (Just Derrota)

    , testar "Resultado de time ausente"
        (resultadoPara "Coritiba" partidaTeste)
        Nothing

    , testar "Empate do mandante"
        (resultadoPara "Coritiba" partidaEmpate)
        (Just Empate)

    , testar "Empate do visitante"
        (resultadoPara "Operário" partidaEmpate)
        (Just Empate)

    , testar "Times de campeonato vazio"
        (times []) []
    ]

  putStrLn "\n=== TESTES DA CAMADA 2 ==="

  testes2 <- sequence
    [ testar "Pontos da vitoria"
        (pontos Vitoria) 3

    , testar "Pontos do empate"
        (pontos Empate) 1

    , testar "Pontos da derrota"
        (pontos Derrota) 0

    , testar "Linha de time sem partidas"
        (linhaDoTime [] "Athletico")
        (Linha "Athletico" 0 0 0 0 0 0)

    , testar "Pontos de uma linha"
        (pontosLinha (Linha "A" 5 3 1 1 10 4))
        10

    , testar "Saldo positivo"
        (saldo (Linha "A" 5 3 1 1 10 4))
        6

    , testar "Saldo negativo"
        (saldo (Linha "B" 5 0 2 3 4 11))
        (-7)

    , testar "Aproveitamento sem partidas"
        (aproveitamento (linhaVazia "A"))
        0.0

    , testar "Aproveitamento de 100 por cento"
        (aproveitamento (Linha "A" 1 1 0 0 2 0))
        100.0

    , testar "Classificacao vazia"
        (classificacao []) []

    , testar "Maior goleada em lista vazia"
        (maiorGoleada []) Nothing

    , testar "Media de gols em lista vazia"
        (mediaGols []) Nothing

    , testar "Media de gols em empate sem gols"
        (mediaGols [partidaEmpate])
        (Just 0.0)

    , testar "Desempate por numero de vitorias"
        (compararLinhas
          (Linha "A" 5 2 1 2 6 5)
          (Linha "B" 5 1 4 0 4 3))
        LT

    , testar "Desempate por saldo de gols"
        (compararLinhas
          (Linha "A" 5 3 1 1 10 4)
          (Linha "B" 5 3 1 1 6 3))
        LT

    , testar "Desempate por gols pro"
        (compararLinhas
          (Linha "A" 2 1 0 1 5 4)
          (Linha "B" 2 1 0 1 3 2))
        LT

    , testar "Desempate por ordem alfabetica"
        (compararLinhas
          (linhaVazia "A")
          (linhaVazia "B"))
        LT
    ]

  putStrLn "\n=== TESTES DO CAMPEONATO COMPLETO ==="

  testesCampeonato <-
    case lerCampeonato dadosCampeonato of
      Left erro ->
        testar "Entrada valida" (Left erro)
          (Right () :: Either Erro ()) >>= \ok -> return [ok]

      Right partidas -> sequence
        [ testar "Entrada valida" True True

        , testar "Quantidade de partidas"
            (length partidas) 15

        , testar "Times em ordem alfabetica"
            (times partidas)
            ["Athletico", "Coritiba", "Londrina",
             "Maringá", "Operário", "Paraná"]

        , testar "Classificacao final completa"
            (classificacao partidas)
            tabelaEsperada

        , testar "Classificacao apos terceira rodada"
            (classificacao (ateRodada 3 partidas))
            tabelaRodada3

        , testar "Quantidade de partidas ate rodada 3"
            (length (ateRodada 3 partidas)) 9

        , testar "Nenhuma partida ate rodada zero"
            (ateRodada 0 partidas) []

        , testar "Maior goleada do campeonato"
            (maiorGoleada partidas)
            (Just partidaTeste)

        , testar "Media de gols do campeonato"
            (mediaGols partidas)
            (Just 2.4)

        , testar "Soma dos gols pro e gols contra"
            (sum (map golsPro (classificacao partidas)))
            (sum (map golsContra (classificacao partidas)))

        , testar "Tabela formatada contem o lider"
            ("Athletico" `isInfixOf`
              tabelaFormatada (classificacao partidas))
            True
        ]

  putStrLn "\n=== TESTES DA CAMADA 3 ==="

  testes3 <- sequence
    [ testar "Separacao de campos"
        (separar ';' "1;A;2;0;B")
        ["1", "A", "2", "0", "B"]

    , testar "Separacao com campos vazios"
        (separar ';' ";A;")
        ["", "A", ""]

    , testar "Leitura de partida valida"
        (lerPartida 1 "1;A;2;0;B")
        (Right (Partida 1 "A" 2 0 "B"))

    , testar "Campos invalidos"
        (lerPartida 1 "1;A;2")
        (Left (CamposInvalidos 1))

    , testar "Numero invalido no placar"
        (lerPartida 1 "1;A;dois;0;B")
        (Left (NumeroInvalido 1 "gols do mandante"))

    , testar "Numero invalido na rodada"
        (lerPartida 1 "abc;A;2;0;B")
        (Left (NumeroInvalido 1 "rodada"))

    , testar "Placar negativo"
        (lerPartida 1 "1;A;-1;0;B")
        (Left (PlacarNegativo 1))

    , testar "Mesmo time"
        (lerPartida 1 "1;A;2;0;A")
        (Left (MesmoTime 1))

    , testar "Rodada invalida"
        (lerPartida 1 "0;A;2;0;B")
        (Left (RodadaInvalida 1))

    , testar "Nome vazio"
        (lerPartida 1 "1;;2;0;B")
        (Left (NomeVazio 1))

    , testar "Time repetido na rodada"
        (lerCampeonato "1;A;2;0;B\n1;C;1;0;A")
        (Left (TimeRepetidoNaRodada 1 "A"))

    , testar "Dois times repetidos na rodada"
        (todosOsErros "1;A;2;0;B\n1;A;1;0;B")
        [TimeRepetidoNaRodada 1 "A",
         TimeRepetidoNaRodada 1 "B"]

    , testar "Mesmo time em rodadas diferentes"
        (lerCampeonato "1;A;2;0;B\n2;A;1;0;C")
        (Right [Partida 1 "A" 2 0 "B",
                Partida 2 "A" 1 0 "C"])

    , testar "Campeonato vazio"
        (lerCampeonato "") (Right [])

    , testar "Ignorar comentarios e linhas vazias"
        (lerCampeonato "# comentario\n\n1;A;2;0;B")
        (Right [Partida 1 "A" 2 0 "B"])

    , testar "Preservar numeracao original"
        (lerCampeonato "# comentario\n\n1;A;dois;0;B")
        (Left (NumeroInvalido 3 "gols do mandante"))

    , testar "Remover espacos excedentes"
        (lerPartida 1 " 1 ; A ; 2 ; 0 ; B ")
        (Right (Partida 1 "A" 2 0 "B"))

    , testar "Retornar primeiro erro"
        (lerCampeonato dadosComErros)
        (Left (TimeRepetidoNaRodada 1 "Athletico"))

    , testar "Relatorio completo de erros"
        (todosOsErros dadosComErros)
        errosEsperados

    , testar "Nenhum erro em entrada valida"
        (todosOsErros dadosCampeonato)
        []

    , testar "Nenhum erro em entrada vazia"
        (todosOsErros "") []

    , testar "Tabela vazia possui cabecalho"
        ("POS" `isInfixOf` tabelaFormatada [])
        True
    ]

  let resultados =
        testes1 ++ testes2 ++ testesCampeonato ++ testes3

      aprovados = length (filter id resultados)
      total = length resultados

  putStrLn "\n========================================"
  putStrLn ("Testes aprovados: " ++ show aprovados
            ++ "/" ++ show total)
  putStrLn "========================================"

  if and resultados
    then putStrLn "TODOS OS TESTES PASSARAM!"
    else ioError (userError "Existem testes com falha.")