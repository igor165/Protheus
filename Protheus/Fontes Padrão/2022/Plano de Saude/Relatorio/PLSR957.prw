//#Include "PLSR957.ch"
#Include "Protheus.ch"
#INCLUDE "REPORT.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSR957

@description Relatorio das RDA's que estão para voltar do periodo de suspensão 
@author  Karine Riquena Limp
@version P12
@since   18.08.16

/*/
//-------------------------------------------------------------------
Function PLSR957()
Local oReport

If IsBlind()
    //Geração automatica do relatório via Schedule
    PL957Email() 
Else
	//Geração manual via remote
	Pergunte("PLR957",.F.) 
	oReport := ReportDef()
	oReport:PrintDialog()		
Endif

//coloquei nesse ponto pois na rotina que envia email estava indo sem anexo
if(type("cDirAnexo") <> "U" .and. file(cDirAnexo))
	FErase(cDirAnexo)
endIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef

@description Montar a seção
@author  Karine Riquena Limp
@version P12
@since   18.08.16

/*/
//-------------------------------------------------------------------
Static Function ReportDef()
Local oReport                                             
Local oSection1 
Local oSection0
Local cTitulo := "Relação de RDA suspensas"

DEFINE REPORT oReport NAME "PLSR957 " TITLE (cTitulo) PARAMETER "PLR957" ACTION {|oReport| PrintReport(oReport)} DESCRIPTION cTitulo
oReport:SetLandscape()

DEFINE SECTION oSection0   OF oReport TABLES  "TRB" TITLE OemToAnsi("RDA bloqueadas por suspensao") 
DEFINE CELL NAME "cUser"   OF oSection0 ALIAS "TRB" TITLE OemToAnsi("Usuario") SIZE 30//"Usuário"

DEFINE SECTION oSection1   OF oReport TABLES  "TRB"  TITLE OemToAnsi("RDA bloqueadas por suspensao")
DEFINE CELL NAME "cRDA"    OF oSection1 ALIAS "TRB" TITLE OemToAnsi("RDA") SIZE 6//"RDA"
DEFINE CELL NAME "cMotBlq" OF oSection1 ALIAS "TRB" TITLE OemToAnsi("Motivo Bloqueio") SIZE 6 //"Motivo Bloqueio"
DEFINE CELL NAME "cDesBlq" OF oSection1 ALIAS "TRB" TITLE OemToAnsi("Bloqueio") SIZE 25//"Bloqueio"
DEFINE CELL NAME "cDtSol"  OF oSection1 ALIAS "TRB" TITLE OemToAnsi("Dt.Solicitacao") SIZE 10//"Dt.Solicitação "
DEFINE CELL NAME "cDtBlq"  OF oSection1 ALIAS "TRB" TITLE OemToAnsi("Dt.Bloqueio" ) SIZE 10//"Dt.Bloqueio"  
DEFINE CELL NAME "cDtPRet"   OF oSection1 ALIAS "TRB" TITLE OemToAnsi("Dt.Previsao Retorno") SIZE 10//"Dt.Limite concedido "
DEFINE CELL NAME "nQtdDia" OF oSection1 ALIAS "TRB" TITLE OemToAnsi("Qtde dias p/ retorno") SIZE 15

Return oReport


//-------------------------------------------------------------------
/*/{Protheus.doc} PrintReport

@description Imprimir os campos do relatorio
@author  Karine Riquena Limp
@version P12
@since   18.08.16

/*/
//-------------------------------------------------------------------
Static Function PrintReport( oReport)
Local oSection0 := oReport:Section(1)
Local oSection1 := oReport:Section(2)
Local aDados  := {}
Local nI      := 0
 
	aDados:= PL957Filtro(.F.)

	For nI:= 1 to len(aDados)		    
		If nI == 1 
			oReport:SkipLine(1)			
			oSection0:Init()
			oSection1:Init()
			oSection0:Cell("cUser"):SetValue(aDados[nI][8])//BC4_USUOPE
			oSection0:PrintLine()
		ElseIf nI > 1	.AND. (aDados[nI][8] <> aDados[nI-1][8])
			oSection0:Finish()
			oSection1:Finish()
			oReport:SkipLine(1)				
			oSection0:Init()
			oSection1:Init()				
			oSection0:Cell("cUser"):SetValue(aDados[nI][8])//BC4_USUOPE
			oSection0:PrintLine()
		EndIf
			
		oSection1:Cell("cRDA"):SetValue(aDados[nI][1])//BC4_CODRDA
		oSection1:Cell("cMotBlq"):SetValue(aDados[nI][2])//BC4_MOTBLO
		oSection1:Cell("cDesBlq"):SetValue(aDados[nI][3])//BAP_DESCRI
		oSection1:Cell("cDtSol"):SetValue(aDados[nI][4])//BC4_DTSOL
		oSection1:Cell("cDtBlq"):SetValue(aDados[nI][5])//BC4_DATA
		oSection1:Cell("cDtPRet"):SetValue(aDados[nI][6])//BC4_DTPRET
		oSection1:Cell("nQtdDia"):SetValue(aDados[nI][7]) 
		oSection1:PrintLine()			
	Next
	
	if !empty(mv_par06) .and. len(aDados) > 0 
		PL957Email(aDados)
	endIf

   If len(aDados) >  1
		oSection0:Finish()
		oSection1:Finish()
	Endif	
	
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} PL957Filtro

@description Filtra os dados para gerar o relatorio ou o arquivo  
@author  Karine Riquena Limp
@version P12
@since   18.08.16

/*/
//-------------------------------------------------------------------
Static Function PL957Filtro()
Local cQuery    := ""
Local cAliasTrb := ""
Local aDados    := {}
Local cInt      := PlsIntPad()
Local cDtAtual  := date()
Local nI        := 0
Local aDiasMeses:= {}
Local cData     := ""
Local nStart    := 0
Local nMesAtual := 0
Local nTotalDias:= 0
Local aUsers    := PLRETUSERS(mv_par01, mv_par02)
Local nTam 	  := len(aUsers)
Local nPos		  := 0

cQuery := " SELECT  BC4.BC4_CODCRE,BC4.BC4_MOTBLO,BC4.BC4_DTSOL,BC4.BC4_DATA,BC4.BC4_DTPRET, BAP.BAP_DESCRI, BC4.BC4_USUOPE, BC4.R_E_C_N_O_ "
cQuery += " FROM " + RetSqlName('BC4') +" BC4 ,"+RetSqlName('BAP') +" BAP "			
cQuery += " WHERE "			
cQuery += " BC4.BC4_FILIAL = '" + xFilial("BC4") + "' and"	
cQuery += " BC4.BC4_CODCRE >= '"+ mv_par03+"' And BC4.BC4_CODCRE <= '"+ mv_par04 +"' and "

if nTam > 0 
	cQuery += " BC4.BC4_USUOPE IN("
	for nI := 1 to nTam
		If nI > 1
			cQuery += " , "
		EndIf
		cQuery += "'" + aUsers[nI] + "'"
	next nI
	cQuery += " ) and "
endiF

cQuery += " BC4.BC4_DTPRET  >= '"+ dtos(dDataBase)+"' And BC4.BC4_DTPRET <= '"+ dtos(ddatabase + mv_par05) +"' and "
cQuery += " BC4.BC4_TIPO = '0' and BC4.BC4_MOTIVO = '1' " 
cQuery += " and BAP_FILIAL = BC4_FILIAL "
cQuery += " and BC4_MOTBLO = BAP_CODBLO "
cQuery += " and BC4.D_E_L_E_T_ = ' ' "
cQuery += " and BAP.D_E_L_E_T_ = ' ' "  
cQuery += " Order by BC4_USUOPE, BC4_DTPRET "

cQuery := ChangeQuery(cQuery)

//----------------------------------------------------------------
// Pega uma sequencia de alias para o temporario.               
//----------------------------------------------------------------
cAliasTrb := GetNextAlias()

dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasTrb, .F., .T.)
dbSelectArea(cAliasTrb)
dbGoTop()
 
While !(cAliasTrb)->(Eof())

	nPos := AsCan(aDados,{|x| x[1] == (cAliasTrb)->BC4_CODCRE }) //Verificar se já tem uma suspensão do mesmo prestador 
	If nPos > 0
		if( aDados[nPos][9] < (cAliasTrb)->R_E_C_N_O_ ) //Caso já tenha, a que foi inserida por último é a que irá constar, pois pra inserir uma nova tem que ter dado baixa (desbloqueado) a primeira
			aDel(aDados, nPos) //Deleta a posição antiga no array
			aSize(aDados, Len(aDados) -1) //Tira a posição NIL no final, que criamos na linha acima
			//Grava o registro do prestador no array
			AAdd( aDados, { (cAliasTrb)->BC4_CODCRE, (cAliasTrb)->BC4_MOTBLO, alltrim((cAliasTrb)->BAP_DESCRI), dtoc(stod((cAliasTrb)->BC4_DTSOL)), dtoc(stod((cAliasTrb)-> BC4_DATA)),dtoc(stod((cAliasTrb)->BC4_DTPRET)), alltrim(str(stod((cAliasTrb)->BC4_DTPRET) - DDATABASE)), alltrim((cAliasTrb)->BC4_USUOPE), (cAliasTrb)->R_E_C_N_O_ })
		EndIf
	Else
		AAdd( aDados, { (cAliasTrb)->BC4_CODCRE, (cAliasTrb)->BC4_MOTBLO, alltrim((cAliasTrb)->BAP_DESCRI), dtoc(stod((cAliasTrb)->BC4_DTSOL)), dtoc(stod((cAliasTrb)-> BC4_DATA)),dtoc(stod((cAliasTrb)->BC4_DTPRET)), alltrim(str(stod((cAliasTrb)->BC4_DTPRET) - DDATABASE)), alltrim((cAliasTrb)->BC4_USUOPE), (cAliasTrb)->R_E_C_N_O_ })  
 	EndIf
 	(cAliasTrb)->(dbSkip())
Enddo

(cAliasTrb)->(dbCloseArea())
	
Return aDados

//-------------------------------------------------------------------
/*/{Protheus.doc} Scheddef

@description Recebe os parametros do schedule  
@author  Karine Riquena Limp
@version P12
@since   18.08.16

/*/
//-------------------------------------------------------------------
Static Function Scheddef()
Local aParam
Local aOrd     := {}
aParam := { "R","PLR957","BC4",aOrd,"SchedDef"} 
Return aParam

//-------------------------------------------------------------------
/*/{Protheus.doc} PL957Email

@description Envia email
@author  Karine Riquena Limp
@version P12
@since   18.08.16

/*/
//-------------------------------------------------------------------
Static Function PL957Email(aDados) 
Local nI        := 0
Local cMontaTxt := "" 
Local cDirGrava := "" //diretorio onde será armazenado a geracao do relatorio
Local cDestino  := "" //analista que recebera o email  
Local aAnexo    := {}
Local nMesAtual := val(SubStr(DtoS(date()),5,2))
Private cDirAnexo
default aDados    := {}

if len(aDados) <= 0
	aDados := PL957Filtro()
endIf

cDirGrava  := Lower(GetMV("MV_RELT"))
cDestino   := alltrim(mv_par06)

If !Empty(aDados)
	//Monta o cabecalho do excel
	cMontaTxt += "RDA" + ";"//"RDA"
	cMontaTxt += "Motivo Bloqueio" + ";"//"Motivo Bloqueio"
	cMontaTxt += "Bloqueio" + ";"//"Bloqueio"
	cMontaTxt += "Dt.Solicitação " + ";"//"Dt.Solicitação "
	cMontaTxt += "Dt.Bloqueio" + ";"//"Dt.Bloqueio"
	cMontaTxt += "Dt.Previsão Retorno" + ";"//"Dt.Previsão Retorno"
	cMontaTxt += "Qtde dias p/ Retorno" + ";"//"Qtde dias p/ Retorno"
	cMontaTxt += "Usuário que bloqueou" //"Usuário que bloqueou"
	cMontaTxt += CRLF 
	
	//carrega o excel
	For nI:= 1 to len(aDados)
	   cMontaTxt += aDados[nI][1] + ";"
	   cMontaTxt += aDados[nI][2] + ";"
	   cMontaTxt += aDados[nI][3] + ";"
	   cMontaTxt += aDados[nI][4] + ";"
	   cMontaTxt += aDados[nI][5] + ";"
	   cMontaTxt += aDados[nI][6] + ";"
	   cMontaTxt += aDados[nI][7] + ";"
	   cMontaTxt += aDados[nI][8] 
	   cMontaTxt += CRLF 
	Next
	
	cDirAnexo := alltrim(cDirGrava)+"RDA_Suspensos_"+SubStr(DtoS(date()),7,2)+"_"+SubStr(DtoS(date()),5,2)+"_"+SubStr(DtoS(date()),1,4)+".csv" //"\RDA_Suspensos_"
	
	If ExistDir( cDirGrava )
		//adicionando o arquivo como anexo
		aadd(aAnexo,cDirAnexo)
			
		//criar arquivo texto vazio a partir do root path no servidor
		nHandle := FCREATE(cDirAnexo)
			
		FWrite(nHandle,cMontaTxt)
			
		//encerra gravação no arquivo
		FClose(nHandle)

		BOJ->(DbSetOrder(3))
		BOJ->(MsSeek(xFilial("BOJ") + "PLSR957" + (Space(TamSx3("BOJ_ROTINA")[1] - 7))  + "001"))
		PLSinaliza(BOJ->BOJ_CODSIN,nil,nil, alltrim(cDestino), "Rel. RDA Suspensa",,,,cDirAnexo,, .F.,"",,,)
		
	Else
		Plslogfil("Arquivo nao encontrado"	,cDirAnexo)//"Arquivo nao encontrado"		
	EndIf
Endif

Return (Nil)
