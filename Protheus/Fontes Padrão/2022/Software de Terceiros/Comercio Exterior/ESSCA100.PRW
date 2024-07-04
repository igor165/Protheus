/*
Programa   : ESSCA100
Objetivo   : Chamar a rotina de Processo de Serviços com a opção Aquisição de Serviços
Retorno    : Nil
Autor      : 
Data/Hora  : 
Revisao    : 
*/
#Include 'Protheus.ch'
#Include "Average.ch"

Function ESSCA100()
Local cTipo  := "A"
Local cOpcao := "CONTROLE_SERVICOS_AQUISICAO" 

If AvFlags(cOpcao)
   ESSCI100(cTipo)
Else
   EasyHelp("Este ambiente não está preparado para executar esta rotina.  Favor aplicar o update USSIGAESS() ou entrar em contato com o suporte Trade-Easy.","Aviso")
EndIf   

Return .T.