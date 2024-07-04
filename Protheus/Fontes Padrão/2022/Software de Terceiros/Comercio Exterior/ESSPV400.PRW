/*
Programa   : EECPS400
Objetivo   : Chamar a rotina de Processo de Serviços com a opção Venda de Serviços
Retorno    : Nil
Autor      : Rafael Ramos Capuano - RRC
Data/Hora  : 17/08/2012 11:13 
Revisao    : 
*/

#Include 'Protheus.ch'
#Include "Average.ch"
Function EECPS400(aCab,aItens,aAnexos,nOpcAuto,lCallInv)
return ESSPV400(aCab,aItens,aAnexos,nOpcAuto,lCallInv)

Function ESSPV400(aCab,aItens,aAnexos,nOpcAuto,lCallInv)
Local cTipo  := "V"
Local cOpcao := "CONTROLE_SERVICOS_VENDA" 
Default lCallInv := .F.

If AvFlags(cOpcao)
   ESSPS400(cTipo,aCab,aItens,aAnexos,nOpcAuto,lCallInv)
Else
   EasyHelp("Este ambiente não está preparado para executar esta rotina.  Favor aplicar o update USSIGAESS() ou entrar em contato com o suporte Trade-Easy.","Aviso")
EndIf   

Return .T.

/* 
Funcao     : MenuDef() 
Parametros : Nenhum 
Retorno    : aRotina 
Objetivos  : Chamada da função MenuDef no programa onde a função está declarada. 
Autor      : Felipe Sales Martinez
Data       : 22/11/2012
*/ 
Static Function MenuDef() 
Private cAvStaticCall := "EECPS400"
Private cPed := "V"

   aRotina := StaticCall(ESSPS400, MenuDef) 

Return aRotina 