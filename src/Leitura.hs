module Leitura where

import Tipos
import Data.Char (isSpace)
import Data.List (dropWhileEnd)
import Text.Read (readMaybe)

-- Representa os possiveis erros de entrada.
data Erro
  = CamposInvalidos Int
  | NumeroInvalido Int String
  | PlacarNegativo Int
  | MesmoTime Int
  | TimeRepetidoNaRodada Int Time
  | RodadaInvalida Int
  | NomeVazio Int
  deriving (Show, Eq)

-- Remove espacos no inicio e no final de um texto.
limpar :: String -> String
limpar = dropWhileEnd isSpace . dropWhile isSpace

-- Separa uma String pelo caractere informado.
separar :: Char -> String -> [String]
separar sep = foldr dividir [""]
  where
    dividir :: Char -> [String] -> [String]
    dividir c (campo : resto)
      | c == sep = "" : campo : resto
      | otherwise = (c : campo) : resto
    dividir c []
      | c == sep = ["", ""]
      | otherwise = [[c]]

-- Converte um texto em numero de forma segura.
lerNumero :: Int -> String -> String -> Either Erro Int
lerNumero linha campo texto =
  maybe
    (Left (NumeroInvalido linha campo))
    Right
    (readMaybe texto)

-- Valida uma condicao ou retorna o erro informado.
validar :: Bool -> Erro -> Either Erro ()
validar True _ = Right ()
validar False erro = Left erro

-- Converte uma linha de texto em uma partida.
lerPartida :: Int -> String -> Either Erro Partida
lerPartida n texto =
  case map limpar (separar ';' texto) of
    [r, m, gm, gv, v] -> do
      numeroRodada <- lerNumero n "rodada" r
      golsM <- lerNumero n "gols do mandante" gm
      golsV <- lerNumero n "gols do visitante" gv

      validar (numeroRodada > 0)
        (RodadaInvalida n)

      validar (golsM >= 0 && golsV >= 0)
        (PlacarNegativo n)

      validar (not (null m) && not (null v))
        (NomeVazio n)

      validar (m /= v)
        (MesmoTime n)

      return Partida
        { rodada = numeroRodada
        , mandante = m
        , golsMandante = golsM
        , golsVisitante = golsV
        , visitante = v
        }

    _ -> Left (CamposInvalidos n)
