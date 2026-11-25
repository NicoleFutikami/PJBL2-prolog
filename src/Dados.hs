module Dados where

-- Campeonato ficticio de futebol com seis times
-- e cinco rodadas, no formato todos contra todos.

dadosCampeonato :: String
dadosCampeonato = unlines
  [ "# rodada;mandante;gols mandante;gols visitante;visitante"

  -- Primeira rodada
  , "1;Athletico;4;0;Paraná"
  , "1;Coritiba;0;0;Operário"
  , "1;Londrina;2;1;Maringá"
  , ""

  -- Segunda rodada
  , "2;Athletico;1;1;Operário"
  , "2;Paraná;1;2;Maringá"
  , "2;Coritiba;2;0;Londrina"

  -- Terceira rodada
  , "3;Athletico;0;2;Maringá"
  , "3;Operário;2;1;Londrina"
  , "3;Paraná;1;3;Coritiba"

  -- Quarta rodada
  , "4;Athletico;3;1;Londrina"
  , "4;Maringá;0;1;Coritiba"
  , "4;Operário;0;0;Paraná"

  -- Quinta rodada
  , "5;Athletico;2;0;Coritiba"
  , "5;Londrina;2;2;Paraná"
  , "5;Maringá;1;1;Operário"
  ]

-- Entrada invalida para testar o tratamento de erros.

dadosComErros :: String
dadosComErros = unlines
  [ "# Exemplos de erros de entrada"
  , "1;Athletico;4;0;Paraná"
  , "1;Athletico;2;1;Coritiba"
  , "2;Coritiba;dois;0;Londrina"
  , "3;Operário;-1;0;Maringá"
  , "4;Paraná;0;0;Paraná"
  , "5;Coritiba;2"
  , "0;Coritiba;2;1;Londrina"
  , "6; ;1;2;Maringá"
  ]