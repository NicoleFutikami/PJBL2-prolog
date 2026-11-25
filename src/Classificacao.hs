
module Classificacao where

import Tipos
import Data.List (sortBy)
import Data.Ord (comparing, Down(..))

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


indicador :: Bool -> Int
indicador True = 1
indicador False = 0

linhaDoTime :: [Partida] -> Time -> Linha
linhaDoTime partidas t =
  foldl atualizarLinha (linhaVazia t)
    (filter (participou t) partidas)

pontosLinha :: Linha -> Int
pontosLinha l =
  pontos Vitoria * vitorias l
  + pontos Empate * empates l
  + pontos Derrota * derrotas l


saldo :: Linha -> Int
saldo l = golsPro l - golsContra l


aproveitamento :: Linha -> Double
aproveitamento l
  | jogos l == 0 = 0
  | otherwise =
      100 * fromIntegral (pontosLinha l)
      / (3 * fromIntegral (jogos l))


compararLinhas :: Linha -> Linha -> Ordering
compararLinhas =
     comparing (Down . pontosLinha)
  <> comparing (Down . vitorias)
  <> comparing (Down . saldo)
  <> comparing (Down . golsPro)
  <> comparing time


classificacao :: [Partida] -> [Linha]
classificacao partidas =
  sortBy compararLinhas
    (map (linhaDoTime partidas) (times partidas))

ateRodada :: Int -> [Partida] -> [Partida]
ateRodada n = filter ((<= n) . rodada)



diferencaGols :: Partida -> Int
diferencaGols p = abs (golsMandante p - golsVisitante p)

maiorGoleada :: [Partida] -> Maybe Partida
maiorGoleada = foldl escolher Nothing
  where
    escolher :: Maybe Partida -> Partida -> Maybe Partida
    escolher Nothing p = Just p
    escolher (Just melhor) p
      | diferencaGols p > diferencaGols melhor = Just p
      | otherwise = Just melhor


mediaGols :: [Partida] -> Maybe Double
mediaGols [] = Nothing
mediaGols partidas =
  Just (sum (map totalGols partidas) / fromIntegral (length partidas))
  where
    totalGols :: Partida -> Double
    totalGols p = fromIntegral (golsMandante p)
                + fromIntegral (golsVisitante p)

