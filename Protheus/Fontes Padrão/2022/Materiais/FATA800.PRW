#INCLUDE "FATA800.ch"
#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FATA800
Rotina de exporta��o inicial para integra��o com Neogrid S&OP

A integra��o possui a funcionalidade de fazer a troca de dados de venda 
e produ��o em tempo real onde, a partir de hist�ricos da empresa � 
efetuado um planejamento dimensionado para atender o mercado de acordo 
com a demanda,evitando estoques acima ou abaixo da necessidade.

@author Alexandre Bueno da Silva
@since 25/06/2014
@version MP11.8, MP12
/*/
//-------------------------------------------------------------------

Function FATA800

Local bProcess 	:= {|oSelf| FATA800X(oSelf) }
Local cPerg 	:= "FATA800"  
Local cDescProc	:= ''
Local oProcess 	:= Nil


Pergunte(cPerg,.F.)

cDescProc := STR0001  //"Rotina para exporta��o inicial dos arquivos "
cDescProc += STR0002 //"necess�rios para a integra��o entre o ERP "
cDescProc += STR0003 //"Protheus e o sistema Neogrid S&OP."

oProcess := tNewProcess():New("FATA800",STR0004,bProcess,cDescProc,cPerg,/*aInfoCustom*/, .T.,5, /*"Descri��o do painel Auxiliar"*/, .T. )  //"Exporta��o Inicial Neogrid S&OP"

Return                                       

//-------------------------------------------------------------------
/*/{Protheus.doc} FATA800X
Grava��o dos Par�metros MV_FATSOPD e MV_FATSOPP.

@param oProcess - Objeto do Processo

@return lRet 	  - Retorno do processo 
@author Alexandre Bueno da Silva
@since 25/06/2014
@version MP11.8, MP12
/*/
//-------------------------------------------------------------------
Static Function FATA800X(oProcess)   

Local lRet		:= .T.
Local nEntDD1	:= MV_PAR01
Local cPathExp	:= MV_PAR02
Local cMsgErro	:= ''
Local cLogErro	:= ''
Local dDtIni	:= ctod('')
Local dDtFim	:= dDataBase

// Faz a verifica��o dos par�metros (obrigat�rios)
If Empty(nEntDD1)

	cMsgErro := STR0005 //"� obrigat�rio a informa��o do par�metro de Entidade DD1."
	cLogErro := STR0006 //"Execu��o abortada por falta de informa��o do par�metro Entidade DD1"
	
ElseIf Empty(cPathExp)

	cMsgErro := STR0007 //"� obrigat�rio a informa��o do par�metro de path de gera��o dos arquivos de exporta��o."
	cLogErro := STR0008 //"Execu��o abortada por falta de informa��o do par�metro Path de Gera��o"
	
EndIf

//Par�metros corretos, continua processamento
If (lRet := Empty(cMsgErro))

	//Calcula data inicial de processamento com tr�s anos de anteced�ncia � data atual
	dDtIni := stod(AllTrim(StrZero(Year(dDtFim)-3,4))+AllTrim(StrZero(Month(dDtFim),2))+AllTrim(StrZero(Day(dDtFim),2)))
	
	//Executa FATA801 (exporta��o peri�dica) com par�metros de exporta��o inicial
	FATA801({dDtIni,dDtFim,Nil,Nil,oProcess})

//Parametros incorretos, emite mensagem de erro e grava log de inconsist�ncia
Else //Empty(cMsgErro)

	MsgStop(cMsgErro)
	oProcess:SaveLog(cLogErro)
	
EndIf

Return lRet
