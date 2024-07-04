/*
Programa   : EFFAC120
Objetivo   : Utilizar as funcionalides dos Menus Funcionais em funções que não estão 
             definidas em um programa com o mesmo nome da função. 
Autor      : Rodrigo Mendes Diaz 
Data/Hora  : 25/04/07 11:46:13 
Obs.       : Criado com gerador automático de fontes 
*/ 

/* 
Funcao     : MenuDef() 
Parametros : Nenhum 
Retorno    : aRotina 
Objetivos  : Chamada da função MenuDef no programa onde a função está declarada. 
Autor      : Rodrigo Mendes Diaz 
Data/Hora  : 25/04/07 11:46:13 
*/ 
Static Function MenuDef() 
Private cAvStaticCall := "EFFAC120"

   aRotina := StaticCall(EFFCAD00, MenuDef) 

Return aRotina 
