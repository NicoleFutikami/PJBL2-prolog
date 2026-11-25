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

-- Ignora linhas vazias e comentarios, preservando
-- a numeracao original das linhas.
linhasUteis :: String -> [(Int, String)]
linhasUteis = filter (linhaUtil . snd) . zip [1..] . lines
  where
    linhaUtil :: String -> Bool
    linhaUtil texto =
      case limpar texto of
        [] -> False
        '#' : _ -> False
        _ -> True

-- Identifica os times que participaram de uma rodada.
chavesPartida :: Partida -> [(Int, Time)]
chavesPartida p =
  [ (rodada p, mandante p)
  , (rodada p, visitante p)
  ]

-- Registra os times das partidas validas.
registrar :: [(Int, Time)] -> Either Erro Partida -> [(Int, Time)]
registrar vistos (Left _) = vistos
registrar vistos (Right p) = chavesPartida p ++ vistos

-- Identifica os times repetidos na mesma rodada.
errosDeRepeticao :: [(Int, Time)] -> Partida -> [Erro]
errosDeRepeticao vistos p =
  map (uncurry TimeRepetidoNaRodada)
    (filter (`elem` vistos) (chavesPartida p))

-- Analisa cada linha e suas possiveis repeticoes.
analisarEntradas :: String -> [(Either Erro Partida, [Erro])]
analisarEntradas texto =
  zipWith analisar anteriores resultados
  where
    resultados :: [Either Erro Partida]
    resultados = map (uncurry lerPartida) (linhasUteis texto)

    anteriores :: [[(Int, Time)]]
    anteriores = scanl registrar [] resultados

    analisar :: [(Int, Time)] -> Either Erro Partida
             -> (Either Erro Partida, [Erro])
    analisar vistos resultado =
      (resultado, either (const []) (errosDeRepeticao vistos) resultado)

-- Le o campeonato, interrompendo no primeiro erro.
lerCampeonato :: String -> Either Erro [Partida]
lerCampeonato = traverse validarEntrada . analisarEntradas
  where
    validarEntrada :: (Either Erro Partida, [Erro])
                   -> Either Erro Partida
    validarEntrada (resultado, []) = resultado
    validarEntrada (_, erro : _) = Left erro

-- Retorna todos os erros encontrados no campeonato.
todosOsErros :: String -> [Erro]
todosOsErros = concatMap extrairErros . analisarEntradas
  where
    extrairErros :: (Either Erro Partida, [Erro]) -> [Erro]
    extrairErros (Left erro, repeticoes) = erro : repeticoes
    extrairErros (Right _, repeticoes) = repeticoes