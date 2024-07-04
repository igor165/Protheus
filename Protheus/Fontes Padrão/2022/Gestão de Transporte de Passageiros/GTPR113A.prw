#Include "GTPR113A.ch"
#Include 'Protheus.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "DBTREE.CH"
#INCLUDE "MSOLE.CH"

/*/{Protheus.doc} GTPR113A

@type function
@author henrique.toyada 
@since 13/02/2020
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function GTPR113A()

Processa( {|| GerDocAutor() },, OemToAnsi(STR0001) ) //"Gerando autorização de despesa..."

Return 

/*/{Protheus.doc} GerDocAutor

@type function
@author henrique.toyada 
@since 13/02/2020
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function GerDocAutor()

Local cPath		:= Alltrim(SuperGetMv( "MV_DIRDOC", .F., "\WORD\" ) )
Local cArqDot	:= GTPGetRules("ARQDOTAUTR",,,"autorizacao.dot" )  
Local cDirArq	:= GTPGetRules("DIRDOTAUTR",,,"c:\temp\" )  
Local cFileDot	:= ""
Local nRet      := 0
Local nHandWord	:= 0
Local aArea	    := GetArea()
Local aAreaG96  := G96->(GetArea())
Local aAreaGQP  := GQP->(GetArea())

If SubStr(cPath,-1) <> "\"
	cPath += "\" 
Endif

cFileDot := AllTrim(cPath + cArqDot) 

If !(ExistDir( cPath ))
	nRet := MakeDir( cPath )
EndIf

// Verifica a existencia do DOT no ROOTPATH Protheus / Servidor
If !File(cFileDot)
	MsgStop(STR0002,"GTPR113A") //"O modelo (.Dot) do contrato não foi encontrado, verifique os parametros MV_DIRDOC e o parametro do modulo ARQDOTAUTR."
	Return
Endif

If !(ExistDir(cDirArq))
	MontaDir(cDirArq)
EndIf

// Valida se a instância, com a aplicação Microsoft Word, encontra-se válida.

GQP->(DbSetOrder(1))
If GQP->(DbSeek(xfilial("GQP") + G96->G96_NUMVAL))

	//Cria um ponteiro e já chama o arquivo
	nHandWord := OLE_CreateLink()
	If nHandWord == "-1" 
		OLE_CloseFile( nHandWord )
		OLE_CloseLink( nHandWord )
		MsgStop(STR0003, "GTPR113A") // STR0003 //"Impossível estabelecer comunicação com o Microsoft Word."
		Return
	Else
			
		ProcRegua( 3 )

		CpyS2T( cFileDot, cDirArq, .T. )

		OLE_NewFile(nHandWord, cDirArq + cArqDot) //cArquivo deve conter o endereço que o dot está na máquina, por exemplo, C:\arquivos_dot\teste.dotx
		
		//Setando o conteúdo das DocVariables
		OLE_SetDocumentVar(nHandWord, "cAutoriza"		, G96->G96_CODIGO)
		OLE_SetDocumentVar(nHandWord, "cNumVale"		, G96->G96_NUMVAL)
		OLE_SetDocumentVar(nHandWord, "cFinalidade"		, " " + GQP->GQP_DESFIN)
		OLE_SetDocumentVar(nHandWord, "cTpVale"			, GQP->GQP_CODIGO + " - " + FDESC("G9A",GQP->GQP_CODIGO,"G9A_DESCRI"))
		OLE_SetDocumentVar(nHandWord, "cAgencia"		, GQP->GQP_CODAGE + " - " + FDESC("GI6",GQP->GQP_CODAGE,"GI6_DESCRI"))
		OLE_SetDocumentVar(nHandWord, "cDepartamento"	, GQP->GQP_DEPART + " - " + FDESC("SQB",GQP->GQP_DEPART,"QB_DESCRIC"))
		OLE_SetDocumentVar(nHandWord, "cStatus"			, IIF(GQP->GQP_STATUS == '1',"Pendente","Baixado"))//1=Pendente;2=Baixado
		OLE_SetDocumentVar(nHandWord, "dDataEmissao"	, GQP->GQP_EMISSA)
		OLE_SetDocumentVar(nHandWord, "dDataVigencia"	, GQP->GQP_VIGENC)
		OLE_SetDocumentVar(nHandWord, "cMatricula"		, G96->G96_CODFUN)
		OLE_SetDocumentVar(nHandWord, "cNome"			, FDESC("SRA",G96->G96_CODFUN,"RA_NOME"))
		OLE_SetDocumentVar(nHandWord, "cValor"			, cvaltochar(GQP->GQP_VALOR) + "(" + Extenso(GQP->GQP_VALOR) + ")")
		OLE_SetDocumentVar(nHandWord, "cParcelas"		, G96->G96_PARCEL)
		OLE_SetDocumentVar(nHandWord, "cDataAutorizacao", G96->G96_DTAUTO)
		
		//Atualizando campos
		OLE_UpdateFields(nHandWord)

		OLE_PrintFile( nHandWord, "ALL",,, 1 )

		Sleep(2000)

		OLE_SaveAsFile( nHandWord, AllTrim( cDirArq + FWTimeStamp() + STRTRAN(cArqDot,".dot",".doc") ) ) 
		
		//Fechando o arquivo e o link
		OLE_CloseFile(nHandWord)
		OLE_CloseLink(nHandWord)

		//Monstrando um alerta
		MsgAlert(STR0004,STR0005) //'O arquivo gerado foi <b>Salvo</b>?<br>Ao clicar em OK o Microsoft Word será <b>fechado</b>!' //'Atenção'
	EndIf
Else
	MsgAlert(STR0006,STR0005) //'Não foi encontrado o vale referente!' //'Atenção'
EndIf


RestArea(aAreaGQP)
RestArea(aAreaG96)
RestArea(aArea)

Return 
