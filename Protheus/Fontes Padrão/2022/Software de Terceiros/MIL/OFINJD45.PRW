#include 'protheus.ch'
//#include 'OFINJD45.ch'

/*/{Protheus.doc} mil_ver()
    Versao do fonte modelo novo

    @author Vinicius Gati
    @since  16/10/2017
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "1"

/*/{Protheus.doc} OFINJD45 "Conversão de demanda VQ3->VB8"

	Rotina que será responsável de transferir a demanda da antiga tabela VQ3 para
	a nova tabela VB8.

	Pontos de entrada:
		N/A
	Parametros:
		N/A

	@author Vinicius Gati
	@since  16/10/2017
/*/
Function OFINJD45()
	Local aButtons
	Private oArrHlp    := DMS_ArrayHelper():New()
	Private oSqlHlp    := DMS_SqlHelper():New()
	Private nOpc       := 1
	Private lAbort     := .T.
	Private aCampos    := {}
	Private aFilis     := {}
	Private cQuery     := ""
	Private oProcNH
	Private nQtdReg
	Private lIsPrism    := VQ3->(Fieldpos('VQ3_CODIGO')) > 0

	aFilis := oSqlHlp:GetSelectArray("SELECT DISTINCT VQ3_FILIAL, 0 as COD FROM " + RetSQlName('VQ3'), 2)

	cQuery += " SELECT * FROM " + oSqlHlp:NoLock("VQ3")
	cQuery += "  WHERE VQ3_TIPREG IN ('C','N',' ') AND D_E_L_E_T_ = ' ' "

	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek("VQ3")
	While !SX3->(Eof()) .And. SX3->X3_ARQUIVO == "VQ3"
		If SX3->X3_CAMPO != "VQ3_CODIGO"
			AADD(aCampos, { SX3->X3_CAMPO, STRTRAN(SX3->X3_CAMPO, "VQ3", "VB8") })
		EndIf
		SX3->(DbSkip())
	EndDo

	oProcNH := MsNewProcess():New( { |lEnd| ONJD45Proc(lEnd) } , "Iniciar" , "" , .T. )
	nQtdReg := FM_SQL("SELECT COUNT(*) FROM " + oSqlHlp:NoLock("VQ3") + " WHERE D_E_L_E_T_ = ' ' ")

	aButtons := {;
		{ 1, .T., { || oProcNH:Activate()   }},;
		{ 2, .T., { || FechaBatch()         }} ;
	}
	FORMBATCH("Conversão de demanda" ,;
		{"Esta rotina é feita para converter a demanda da tabela VQ3 para aVB8"},;
		aButtons)
Return NIL

/*/{Protheus.doc} OFINJD45Proc
	Processa a conversão
	
	@type function
	@author Vinicius Gati
	@since 16/10/2017
/*/
Static Function ONJD45Proc(lAbort)
	Local cAl       := GetNextAlias()
	Local nSXE      := 1
	Local nControle := 0
	Local nTamanho  := TAMSX3('VB8_CODIGO')[1]
	Local cVQ3Tbl   := RetSQlName('VQ3')
	Local aSxes     := {}
	Local nX        := 1

	oProcNH:SetRegua1(nQtdReg)

	dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery),cAl, .F., .T.)
	dbSelectArea(cAl)
	dbSelectArea('VB8')

	For nX:= 1 to Len(aFilis)
		aFilis[nX, 2] := VAL(FM_SQL('SELECT MAX(VB8_CODIGO) FROM ' + oSqlHlp:NoLock('VB8') + " WHERE VB8_FILIAL = '"+aFilis[nX,1]+"' "))
		aFilis[nX, 2] := aFilis[nX, 2] + 1
	Next

	While ! (cAl)->(EOF())
		nX := ASCAN(aFilis, {|e| ALLTRIM(e[1]) == ALLTRIM((cAl)->VQ3_FILIAL) })

		reclock('VB8', .T.)
		VB8->VB8_FILIAL  := (cAl)->VQ3_FILIAL
		VB8->VB8_CODIGO  := STRZERO(aFilis[nX][2], nTamanho, 0)
		aFilis[nX][2]    := aFilis[nX][2] + 1
		VB8->VB8_PRODUT  := (cAl)->VQ3_PRODUT
		VB8->VB8_ANO     := (cAl)->VQ3_ANO
		VB8->VB8_MES     := (cAl)->VQ3_MES
		VB8->VB8_DIA     := (cAl)->VQ3_DIA
		VB8->VB8_HITSB   := (cAl)->VQ3_HITSB
		VB8->VB8_IMEDB   := (cAl)->VQ3_IMEDB
		VB8->VB8_8HRDB   := (cAl)->VQ3_8HRDB
		VB8->VB8_8HROB   := (cAl)->VQ3_8HROB
		VB8->VB8_24HRB   := (cAl)->VQ3_24HRB
		VB8->VB8_VDPERB  := (cAl)->VQ3_VDPERB
		VB8->VB8_HITSO   := (cAl)->VQ3_HITSO
		VB8->VB8_IMEDO   := (cAl)->VQ3_IMEDO
		VB8->VB8_8HRDO   := (cAl)->VQ3_8HRDO
		VB8->VB8_8HROO   := (cAl)->VQ3_8HROO
		VB8->VB8_24HRO   := (cAl)->VQ3_24HRO
		VB8->VB8_VDPERO  := (cAl)->VQ3_VDPERO
		VB8->VB8_HITSI   := (cAl)->VQ3_HITSI
		VB8->VB8_IMEDI   := (cAl)->VQ3_IMEDI
		VB8->VB8_8HRDI   := (cAl)->VQ3_8HRDI
		VB8->VB8_8HROI   := (cAl)->VQ3_8HROI
		VB8->VB8_24HRI   := (cAl)->VQ3_24HRI
		VB8->VB8_VDPERI  := (cAl)->VQ3_VDPERI
		VB8->VB8_DEVBAL  := (cAl)->VQ3_DEVBAL
		VB8->VB8_DEVOFI  := (cAl)->VQ3_DEVOFI
		VB8->VB8_DEVINT  := (cAl)->VQ3_DEVINT
		VB8->VB8_VALINV  := (cAl)->VQ3_VALINV
		VB8->VB8_CUSBAL  := (cAl)->VQ3_CUSBAL
		VB8->VB8_CUSOFI  := (cAl)->VQ3_CUSOFI
		VB8->VB8_CUSFAB  := (cAl)->VQ3_CUSFAB
		VB8->VB8_CUSDEV  := (cAl)->VQ3_CUSDEV
		VB8->VB8_TOTBAL  := (cAl)->VQ3_TOTBAL
		VB8->VB8_TOTOFI  := (cAl)->VQ3_TOTOFI
		VB8->VB8_TOTINT  := (cAl)->VQ3_TOTINT
		VB8->VB8_TOTFAB  := (cAl)->VQ3_TOTFAB
		VB8->VB8_LOCAL   := (cAl)->VQ3_LOCAL
		VB8->VB8_TIPLOC  := (cAl)->VQ3_TIPLOC
		VB8->VB8_STOCK   := (cAl)->VQ3_STOCK
		VB8->VB8_VDAB    := (cAl)->VQ3_VDAB
		VB8->VB8_VDAO    := (cAl)->VQ3_VDAO
		VB8->VB8_CRICOD  := (cAl)->VQ3_CRICOD
		VB8->VB8_HIPERB  := (cAl)->VQ3_HIPERB
		VB8->VB8_HIPERO  := (cAl)->VQ3_HIPERO
		VB8->VB8_HIPERI  := (cAl)->VQ3_HIPERI
		VB8->VB8_VDAI    := (cAl)->VQ3_VDAI
		VB8->VB8_TOTBAN  := (cAl)->VQ3_TOTBAN
		VB8->VB8_CUSBAN  := (cAl)->VQ3_CUSBAN
		VB8->VB8_VDABN   := (cAl)->VQ3_VDABN
		VB8->VB8_TOTOFN  := (cAl)->VQ3_TOTOFN
		VB8->VB8_CUSOFN  := (cAl)->VQ3_CUSOFN
		VB8->VB8_VDAON   := (cAl)->VQ3_VDAON
		VB8->VB8_HITSBN  := (cAl)->VQ3_HITSBN
		VB8->VB8_HITSON  := (cAl)->VQ3_HITSON
		VB8->VB8_IMEDBN  := (cAl)->VQ3_IMEDBN
		VB8->VB8_IMEDON  := (cAl)->VQ3_IMEDON
		VB8->VB8_PROCES  := (cAl)->VQ3_PROCES
		If lIsPrism
			VB8->VB8_CODCLI  := (cAl)->VQ3_CODCLI
			VB8->VB8_LOJCLI  := (cAl)->VQ3_LOJCLI
			VB8->VB8_FLGENV  := (cAl)->VQ3_FLGENV
		else
			VB8->VB8_FLGENV  := '*'
		EndIf
		VB8->VB8_TIPREG    := (cAl)->VQ3_TIPREG
		VB8->(MsUnlock())
		nControle += 1
		If nControle >= 5000
			nControle := 0
			oProcNH:IncRegua1(" Convertidos: " + cValToChar(nSXE) + " De: " + cValToChar(nQtdReg) + " Hora: " + TIME())
		EndIf

		tcSqlExec(' UPDATE ' + cVQ3Tbl + " SET VQ3_TIPREG = 'T' WHERE R_E_C_N_O_ = " + cValToChar((cAl)->R_E_C_N_O_) )

		(cAl)->(DbSkip())
	End
	(cAl)->(dbCloseArea())
	MSGINFO("Processo finalizado com sucesso.", "Atenção")
Return .T.
