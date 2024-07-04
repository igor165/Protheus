#INCLUDE "FATA800.ch"
#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FATA800
Rotina de exportação inicial para integração com Neogrid S&OP

A integração possui a funcionalidade de fazer a troca de dados de venda 
e produção em tempo real onde, a partir de históricos da empresa é 
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

cDescProc := STR0001  //"Rotina para exportação inicial dos arquivos "
cDescProc += STR0002 //"necessários para a integração entre o ERP "
cDescProc += STR0003 //"Protheus e o sistema Neogrid S&OP."

oProcess := tNewProcess():New("FATA800",STR0004,bProcess,cDescProc,cPerg,/*aInfoCustom*/, .T.,5, /*"Descrição do painel Auxiliar"*/, .T. )  //"Exportação Inicial Neogrid S&OP"

Return                                       

//-------------------------------------------------------------------
/*/{Protheus.doc} FATA800X
Gravação dos Parâmetros MV_FATSOPD e MV_FATSOPP.

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

// Faz a verificação dos parâmetros (obrigatórios)
If Empty(nEntDD1)

	cMsgErro := STR0005 //"É obrigatório a informação do parâmetro de Entidade DD1."
	cLogErro := STR0006 //"Execução abortada por falta de informação do parâmetro Entidade DD1"
	
ElseIf Empty(cPathExp)

	cMsgErro := STR0007 //"É obrigatório a informação do parâmetro de path de geração dos arquivos de exportação."
	cLogErro := STR0008 //"Execução abortada por falta de informação do parâmetro Path de Geração"
	
EndIf

//Parâmetros corretos, continua processamento
If (lRet := Empty(cMsgErro))

	//Calcula data inicial de processamento com três anos de antecedência à data atual
	dDtIni := stod(AllTrim(StrZero(Year(dDtFim)-3,4))+AllTrim(StrZero(Month(dDtFim),2))+AllTrim(StrZero(Day(dDtFim),2)))
	
	//Executa FATA801 (exportação periódica) com parâmetros de exportação inicial
	FATA801({dDtIni,dDtFim,Nil,Nil,oProcess})

//Parametros incorretos, emite mensagem de erro e grava log de inconsistência
Else //Empty(cMsgErro)

	MsgStop(cMsgErro)
	oProcess:SaveLog(cLogErro)
	
EndIf

Return lRet
