/*
Programa   : EICGI401
Objetivo   : Utilizar as funcionalides dos Menus Funcionais em funções que não estão 
             definidas em um programa com o mesmo nome da função. 
Autor      : Rodrigo Mendes Diaz 
Data/Hora  : 25/04/07 11:46:07 
Obs.       : Criado com gerador automático de fontes 
*/ 


/* 
Funcao     : MenuDef() 
Parametros : Nenhum 
Retorno    : aRotina 
Objetivos  : Chamada da função MenuDef no programa onde a função está declarada. 
Autor      : Rodrigo Mendes Diaz 
Data/Hora  : 25/04/07 11:46:07 
*/ 
Static Function MenuDef() 
  
Local aRotina := {}
 
Private cAvStaticCall := "EICGI401"

Return StaticCall(EICGI400, MenuDef) 