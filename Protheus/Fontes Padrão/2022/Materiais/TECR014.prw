#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TECR014.CH"

Static cPerg := "TECR014"
Static aHeader := {}
Static cRetPesq := ""	

Function TECR014()
	U_TECR014()
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} PrintReport

@author  Matheus Lando Raimundo
@version P12
@since 	 29/01/2018
@return 
/*/
//-------------------------------------------------/------------------------------------
user function TECR014()
	Local oReport
	aHeader := {}
        
	If TRepInUse() 
		Pergunte(cPerg,.F.)	
		oReport := RepInit() 		
		oReport:PrintDialog()	
	EndIf	
	
return


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RepInit

@author  Matheus Lando Raimundo
@version P12
@since 	 29/01/2018
@return 
/*/
//-------------------------------------------------------------------------------------
Static Function RepInit()
	Local cTab	:=  MV_PAR01
	Local oReport := Nil		
	Local oSection1 := Nil
	Local oSection2 := Nil
	Local oBreak1 := Nil
	Local oBreak2 := Nil

	oReport := TReport():New("TECR014",STR0002,cPerg,{|oReport| PrintReport(oReport)},STR0001) //"Dados munição" //"Dados Munição"
				 		
	oSection1 := TRSection():New(oReport,STR0002,{cTab},,,,,,,.T.)		 				
	
	TRCell():New(oSection1,'T4B_CAMPO','T4B','Campo')		 				
	TRCell():New(oSection1,'T4B_VALOR','T4B','Valor')
		
	oBreak1 := TRBreak():New( oSection1,{|| TMPQUERY->T4B_RECNO} )		
	
Return oReport


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} PrintReport

@author  Matheus Lando Raimundo
@version P12
@since 	 29/01/2018
@return 
/*/
//-------------------------------------------------------------------------------------
Static Function PrintReport(oReport)		
	Local cTmpQry	:= GetNextAlias()
	Local oSection1 := oReport:Section(1)	
	Local cAliasTemp := GetNextAlias()		
	Local cQuery := "% "
	Local nI := 1
	Local cTab	:=  MV_PAR01
	Local cRecno := ""

	
	If !Empty(cTab)	
					
		oSection1:BeginQuery()
		BeginSql alias 'TMPQUERY'		 				
			SELECT T4B_CAMPO, T4B_VALOR, T4B_RECNO FROM %table:T4B% T4B
				WHERE T4B_TAB = %Exp:cTab%			
		EndSql		
		
		oSection1:EndQuery()
		oSection1:SetParentQuery(.T.)
		oSection1:Init()
				
		While TMPQUERY->(!Eof())
		
	 		
	 																				
				oSection1:PrintLine()									 	
				TMPQUERY->(dbSkip())
									
		EndDo
	EndIf								
Return





//-------------------------------------------------------------------------------------
/*/{Protheus.doc} At014Cons

@author  Matheus Lando Raimundo
@version P12
@since 	 29/01/2018
@return 
/*/
//-------------------------------------------------------------------------------------
Function At014Cons()

Local lRet           := .F.
Local oBrowse        := Nil
Local cAls              := GetNextAlias()
Local nSuperior      := 0
Local nEsquerda      := 0
Local nInferior      := 0
Local nDireita       := 0
Local oDlgTela := Nil
Local cQry   := ""
//Definição do índice da Consulta Padrão
Local aIndex := {"T4B_TAB"}
//Definição da Descrição da Chave de Pesquisa da Consulta Padrão
Local aSeek := {{ STR0003, {{STR0003,"C",TamSx3('T4B_TAB')[1],0,"",,}} }} //"Tabela"
Local cRet := ""

cQry := " SELECT DISTINCT T4B_TAB, " 
cQry += " CASE "
cQry += " 	WHEN T4B_TAB = 'TE2' THEN '" + STR0004 + "'" //'Cadastro de Munições'
cQry += " 	WHEN T4B_TAB = 'TFP' THEN '" + STR0005 + "'"//'Histórico Movimentação munição'
cQry += " 	WHEN T4B_TAB = 'TE4' THEN '" + STR0006 + "'"//'Cadastro de corrência'
cQry += " 	WHEN T4B_TAB = 'TET' THEN '" + STR0007 + "'"//'Item Ocorrência (Munição)'
cQry += " 	WHEN T4B_TAB = 'TE5' THEN '" + STR0008 + "'"//'Ocorrência - Funcionário'
cQry += " 	WHEN T4B_TAB = 'TFQ' THEN '" + STR0009 + "'"//'Movimentação'
cQry += " 	WHEN T4B_TAB = 'TFO' THEN '" + STR0010 + "'"//'Item movimentação (Munição)'
cQry += " 	WHEN T4B_TAB = 'TFR' THEN '" + STR0011 + "'"//'Responsaveis movimentação'
cQry += " END DESCRI"
cQry += " FROM " + RetSqlName("T4B")
cQry += " GROUP BY T4B_TAB " 

nSuperior := 0
nEsquerda := 0
nInferior := 460
nDireita  := 800

DEFINE MSDIALOG oDlgTela TITLE STR0012 FROM nSuperior,nEsquerda TO nInferior,nDireita PIXEL  //"Tabelas"
 
oBrowse := FWFormBrowse():New()
oBrowse:SetDescription(STR0013)  //"Tabelas backup Munição"
oBrowse:SetAlias(cAls)
oBrowse:SetDataQuery()
oBrowse:SetQuery(cQry)
oBrowse:SetOwner(oDlgTela)
oBrowse:SetDoubleClick({ || cRet := (oBrowse:Alias())->T4B_TAB,  , lRet := .T., oDlgTela:End()})
oBrowse:AddButton( OemTOAnsi(STR0014), {|| cRet := (oBrowse:Alias())->T4B_TAB,  lRet := .T., oDlgTela:End()},, 2 ) //"Confirmar"
oBrowse:AddButton( OemTOAnsi(STR0015),  {|| cRet := "", oDlgTela:End()} ,, 2 ) //"Cancelar"
oBrowse:DisableDetails()
oBrowse:SetQueryIndex(aIndex)
oBrowse:SetSeek(,aSeek)

ADD COLUMN oColumn DATA { ||  T4B_TAB } TITLE STR0016 SIZE TamSx3('ABS_FILIAL')[1] OF oBrowse //"Tabela "
ADD COLUMN oColumn DATA { ||  DESCRI } TITLE STR0017 SIZE 40 OF oBrowse //"Descrição "

            
oBrowse:Activate()

ACTIVATE MSDIALOG oDlgTela CENTERED
 
If lRet
	cRetPesq := cRet 
EndIf
     
Return lRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} At014Ret

@author  Matheus Lando Raimundo
@version P12
@since 	 29/01/2018
@return 
/*/
//-------------------------------------------------------------------------------------
Function At014Ret()

Return cRetPesq 

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} At014VldTb

@author  Matheus Lando Raimundo
@version P12
@since 	 29/01/2018
@return 
/*/
//-------------------------------------------------------------------------------------
Function At014VldTb()
Local lRet 		:= .F.
Local cTab		:=  MV_PAR01
Local cTmpQry	:= GetNextAlias()
Local aArea		:= GetArea()

T4B->(dbSetOrder(1))

lRet := T4B->(DBSeek(xFilial('T4B') + cTab))

If !lRet
	Help(,,'AT014NTAB',,STR0018,1,0) //'Tabela não contida nas tabelas de backup (munição)'
EndIf

RestArea(aArea)

Return lRet 


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetMemo

@author  Matheus Lando Raimundo
@version P12
@since 	 29/01/2018
@return 
/*/
//-------------------------------------------------------------------------------------
Function GetMemo(cTab,nRecno,cCampo)
Local cMemo := ""
Local nX	:= 0
Local nLinhas := 0
Local aArea := GetArea()

T4B->(dbSetOrder(1))
If T4B->(DBSeek(xFilial('T4B') + cTab + Padr(cValToChar(nRecno),TamSX3('T4B_RECNO')[1]) + cCampo))

	nLinhas := MLCount(T4B->T4B_MEMO ,70)
	
	For nX:= 1 To nLinhas
		cTxtLinha := MemoLine(T4B->T4B_MEMO,70,nX)
	    If !Empty(cTxtLinha)
			cMemo += cTxtLinha              
	    EndIf
	Next nX
EndIf	

RestArea(aArea)
Return cMemo

