/*
Programa   : EDCBA404 -  Destruição
Objetivo   : Utilizar as funcionalides dos Menus Funcionais em funções que não estão 
             definidas em um programa com o mesmo nome da função. 
Autor      : Allan Oliveira Monteiro 
Data/Hora  : 09/09/10 - 14:32 
Obs.       : Criado com gerador automático de fontes 
*/ 

/* 
Funcao     : MenuDef() 
Parametros : Nenhum 
Retorno    : aRotina 
Objetivos  : Chamada da função MenuDef no programa onde a função está declarada. 
Autor      : Allan Oliveira Monteiro 
Data/Hora  : 09/09/10 - 14:32 
*/ 
Static Function MenuDef() 

   aRotina := StaticCall(EDCBA400, MenuDef) 

Return aRotina 
