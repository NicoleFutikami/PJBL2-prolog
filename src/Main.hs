
module Main where

import Tipos
import Classificacao
import Leitura
import Dados

-- Formata uma partida para exibicao.
formatarPartida :: Partida -> String
formatarPartida p =
  mandante p ++ " "
  ++ show (golsMandante p)
  ++ " x "
  ++ show (golsVisitante p)
  ++ " " ++ visitante p
  ++ " (Rodada " ++ show (rodada p) ++ ")"

-- Funcao principal do programa.
main :: IO ()
main = do
  putStrLn "========================================"
  putStrLn "    CAMPEONATO PARANAENSE - PjBL2"
  putStrLn "========================================"

  case lerCampeonato dadosCampeonato of
    Left erro ->
      putStrLn ("Erro no campeonato: " ++ show erro)

    Right partidas -> do

      putStrLn "\n=== CLASSIFICACAO FINAL ==="
      putStrLn (tabelaFormatada (classificacao partidas))

      putStrLn "\n=== CLASSIFICACAO APOS A 3a RODADA ==="
      putStrLn
        (tabelaFormatada
          (classificacao (ateRodada 3 partidas)))

      putStrLn "\n=== ESTATISTICAS DO CAMPEONATO ==="

      putStrLn
        ("Quantidade de times: "
          ++ show (length (times partidas)))

      putStrLn
        ("Quantidade de partidas: "
          ++ show (length partidas))

      putStrLn
        ("Maior goleada: "
          ++ maybe "Nenhuma partida"
                   formatarPartida
                   (maiorGoleada partidas))

      putStrLn
        ("Media de gols por partida: "
          ++ maybe "Nenhuma partida"
                   show
                   (mediaGols partidas))

      putStrLn "\n=== APROVEITAMENTO DOS TIMES ==="

      mapM_
        (\l -> putStrLn
          (time l ++ ": "
            ++ show (aproveitamento l) ++ "%"))
        (classificacao partidas)

  putStrLn "\n=== TESTE COM ENTRADA INVALIDA ==="

  case lerCampeonato dadosComErros of
    Left erro ->
      putStrLn ("Primeiro erro: " ++ show erro)

    Right _ ->
      putStrLn "Nenhum erro encontrado."

  putStrLn "\n=== RELATORIO COMPLETO DE ERROS ==="

  mapM_ print (todosOsErros dadosComErros)

  putStrLn "\n=== TESTE COM CAMPEONATO VAZIO ==="

  print (lerCampeonato "")
  print (maiorGoleada [])
  print (mediaGols [])

  putStrLn "\n=== FIM DO PROGRAMA ==="
