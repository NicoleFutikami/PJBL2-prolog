
module Tipos where

import Data.List (nub, sort)

type Time = String

data Resultado = Vitoria | Empate | Derrota
  deriving (Show, Eq)

data Partida = Partida
  { rodada :: Int
  , mandante :: Time
  , golsMandante :: Int
  , golsVisitante :: Int
  , visitante :: Time
  } deriving (Show, Eq)

data Linha = Linha
  { time :: Time
  , jogos :: Int
  , vitorias :: Int
  , empates :: Int
  , derrotas :: Int
  , golsPro :: Int
  , golsContra :: Int
  } deriving (Show, Eq)

-- Verifica se um time participou da partida.
participou :: Time -> Partida -> Bool
participou t p = t == mandante p || t == visitante p

-- Retorna o placar da perspectiva do time informado.
placarPara :: Time -> Partida -> Maybe (Int, Int)
placarPara t p
  | t == mandante p = Just (golsMandante p, golsVisitante p)
  | t == visitante p = Just (golsVisitante p, golsMandante p)
  | otherwise = Nothing

-- Determina o resultado a partir do placar.
resultadoDoPlacar :: (Int, Int) -> Resultado
resultadoDoPlacar (gp, gc) = case compare gp gc of
  GT -> Vitoria
  EQ -> Empate
  LT -> Derrota

-- Retorna o resultado do ponto de vista do time.
resultadoPara :: Time -> Partida -> Maybe Resultado
resultadoPara t p = resultadoDoPlacar <$> placarPara t p

nomesDaPartida :: Partida -> [Time]
nomesDaPartida p = [mandante p, visitante p]

-- Lista os times sem repeticao e em ordem alfabetica.
times :: [Partida] -> [Time]
times = sort . nub . concatMap nomesDaPartida
