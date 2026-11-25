
module Classificacao where

import Tipos

-- Pontuacao de cada resultado.
pontos :: Resultado -> Int
pontos Vitoria = 3
pontos Empate = 1
pontos Derrota = 0

-- Cria uma linha inicial com todos os valores zerados.
linhaVazia :: Time -> Linha
linhaVazia t = Linha
  { time = t
  , jogos = 0
  , vitorias = 0
  , empates = 0
  , derrotas = 0
  , golsPro = 0
  , golsContra = 0
  }

-- Atualiza as estatisticas de um time apos uma partida.
atualizarLinha :: Linha -> Partida -> Linha
atualizarLinha l p =
  case placarPara (time l) p of
    Nothing -> l
    Just (gp, gc) ->
      let resultado = resultadoDoPlacar (gp, gc)
      in l
        { jogos = jogos l + 1
        , vitorias = vitorias l + indicador (resultado == Vitoria)
        , empates = empates l + indicador (resultado == Empate)
        , derrotas = derrotas l + indicador (resultado == Derrota)
        , golsPro = golsPro l + gp
        , golsContra = golsContra l + gc
        }

-- Converte uma condicao em 1 ou 0.
indicador :: Bool -> Int
indicador True = 1
indicador False = 0

-- Acumula o desempenho do time ao longo do campeonato.
linhaDoTime :: [Partida] -> Time -> Linha
linhaDoTime partidas t =
  foldl atualizarLinha (linhaVazia t)
    (filter (participou t) partidas)

-- Calcula o total de pontos conquistados.
pontosLinha :: Linha -> Int
pontosLinha l =
  pontos Vitoria * vitorias l
  + pontos Empate * empates l
  + pontos Derrota * derrotas l

-- Calcula o saldo de gols.
saldo :: Linha -> Int
saldo l = golsPro l - golsContra l

-- Calcula o percentual de aproveitamento.
aproveitamento :: Linha -> Double
aproveitamento l
  | jogos l == 0 = 0
  | otherwise =
      100 * fromIntegral (pontosLinha l)
      / (3 * fromIntegral (jogos l))
