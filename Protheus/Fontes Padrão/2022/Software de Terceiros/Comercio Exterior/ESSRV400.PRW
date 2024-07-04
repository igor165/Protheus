/*
Programa   : ESSRV400
Objetivo   : Chamar a rotina de Registro de Serviços com a opção Venda de Serviços
Retorno    : Nil
Autor      : Rafael Ramos Capuano - RRC
Data/Hora  : 31/08/2012 14:51 
Revisao    : 
*/

#Include 'Protheus.ch'
#Include "Average.ch"
Function ESSRV400(aCab,aItens,aAnexos,nOpcAuto,lCallInv)
Local cTipo  := "V"
Local cOpcao := "CONTROLE_SERVICOS_VENDA"
Default lCallInv := .F. 

If AvFlags(cOpcao)
   ESSRS400(cTipo,aCab,aItens,aAnexos,nOpcAuto,lCallInv)
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
Private cAvStaticCall := "ESSRV400"
Private cTpReg := "V"
Private aRotina      := {}//FSY - 26/12/2013 - (Opção: Conhecimento) Variavel deve ser private, utilizado para exibir as opções no menu principal
   aRotina := StaticCall(ESSRS400, MenuDef) 

Return aRotina 