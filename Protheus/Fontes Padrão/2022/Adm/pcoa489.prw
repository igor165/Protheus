#Include "protheus.ch"
#Include "PCOA489.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA489   บAutor  ณAcacio Egas         บ Data ณ  06/25/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cadastro de Configuracoes de planejamento.                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PCOA489(cAlias , nReg , nOpcx)

Local nWidth  := GetScreenRes()[1] - 40
Local nHeight := GetScreenRes()[2] - 200

Local aColsAM1,aHeadAM1
Local aColsAMC,aHeadAMC
Local aColsAMD,aHeadAMD

Local oSayCfgPnj,oSayItePnj,oSayVarPnj

Private INCLUI	:= .F.

SX2->(DbSetOrder(1))

If !SX2->(DbSeek("AMB"))
	Aviso(STR0001,STR0002,{STR0003})//"Ate็ใo!"##"Esta funcionalidade s๓ estแ disponivel para Microsiga 10 Release 2 ou superior."##"OK"
	Return
EndIf

CriaPad001()

Private oPlanej := PCOLayer():New(0,0, nWidth, nHeight, STR0004,.T. ) //"Configura็ใo de Planejamento"
Private aCampos := {{'',''}}

DbSelectArea("AMB")
DbGoTop()

// Cria divisao de Controle
oPlanej:addSide(28, STR0005 ) //"Configura็๕es de Planejamento"

//Cria  Layouts para a Tela   
oPlanej:AddLayout("CFGPLJ",,.T.)
oPlanej:AddLayout("TPSPLJ",,.T.)
oPlanej:AddLayout("TIPOPL",,.T.)

oPlanej:AddWindow(100,"WIN1", STR0005 ,.F.,"SIDE") //"Configura็๕es de Planejamento"

oPlanej:AddTre("001","WIN1",nil,,.T.)


// Monta Estrutura do Tree
oPlanej:No_Tree( STR0004	,"AMB","AMB_CODIGO+'-'+AMB_DESC"	,"RPMCPO"	,{|| oPlanej:ShowLayout("CFGPLJ")	}	,,,,.T.,,,.F.,{|x| ValidAMB(x)} ) // "Configura็ใo de Planejamento"
oPlanej:No_Tree( STR0006	,"XXX","'" + STR0006 + "'"	,"SIMULACA"	,{|| oPlanej:ShowLayout("TPSPLJ")	}) // "Tipos de Planejamento"
oPlanej:No_Tree( STR0007	,"AM1","AM1_CODIGO+'-'+AM1_DESCR"	,"SIMULACA"	,{|| oPlanej:ShowLayout("TIPOPL")	}	,,,,.T.,'AMB->AMB_CODIGO',2) // "Tipo de Planejamento"

//Layout 01
oPlanej:AddWindow( 40 , "L1WIN2" , STR0008 , .F. , "CFGPLJ") //"Detalhes"

@ 0,0 SAY oSayCfgPnj VAR CfgPnjHTML() OF oPlanej:GetWindow( "L1WIN2" ) FONT oPlanej:GetWindow( "L1WIN2" ):oFont PIXEL HTML
oSayCfgPnj:Align := CONTROL_ALIGN_ALLCLIENT

oPlanej:AddWindow( 30 , "L1WIN3" , STR0004 , .T. , "CFGPLJ") //"Configura็ใo de Planejamento"
	RegToMemory("AMB", .F.,,, FunName())  // usa no metodo msm
	//Cria MsmGet da Configura็ใo de lan็amento "AMB"
	oPlanej:AddMsm("001",,"AMB",AMB->(Recno()),"L1WIN3","CFGPLJ") 

oPlanej:AddWindow( 30 , "L1WIN4" , STR0006 , .F. , "CFGPLJ") //"Tipos de Planejamento"
	//Cria Browse do Tipo de Planejamento "AM1"
	oPlanej:AddMBrowse("001",,"AM1",2,'xFilial("AM1")+AMB->AMB_CODIGO',,,"L1WIN4","CFGPLJ")

//Layout 02
oPlanej:AddWindow( 50 , "L2WIN2" , STR0008 , .F. , "TPSPLJ") //"Detalhes"

@ 0,0 SAY oSayItePnj VAR ItePnjHTML() OF oPlanej:GetWindow( "L2WIN2" ) FONT oPlanej:GetWindow( "L2WIN2" ):oFont PIXEL HTML
oSayItePnj:Align := CONTROL_ALIGN_ALLCLIENT

oPlanej:AddWindow( 50 , "L2WIN3" , STR0006 , .T. , "TPSPLJ") //"Tipos de Planejamento"
//Cria GetDados com os Tipos de Planejamento "AM1"
oPlanej:AddGetDado("001",STR0006,"AM1",2,'xFilial("AM1")+AMB->AMB_CODIGO',,, "L2WIN3", "TPSPLJ", {|x,y| ValidAM1(x,y)},,,,,"+AM1_CODIGO") //"Tipos de Planejamento"

//Layout 03
oPlanej:AddWindow( 34 , "L3WIN2" , STR0008 , .F. , "TIPOPL") //"Detalhes"

@ 0,0 SAY oSayVarPnj VAR VarPnjHTML() OF oPlanej:GetWindow( "L3WIN2" ) FONT oPlanej:GetWindow( "L3WIN2" ):oFont PIXEL HTML
oSayVarPnj:Align := CONTROL_ALIGN_ALLCLIENT

oPlanej:AddWindow( 33 , "L3WIN3" , STR0009 , .T. , "TIPOPL") //"Estrutura de Tipos de Planejamento"
oPlanej:AddGetDado("002",,"AMC",1,'xFilial("AMC")+AMB->AMB_CODIGO+AM1->AM1_CODIGO',,, "L3WIN3", "TIPOPL", {|x,y| ValidAMC(x,y)},,,,,"+AMC_NIVEL" ) //"Estrutura de Tipos de Planejamento"

oPlanej:AddWindow( 33 , "L3WIN4" , STR0010 	, .T. , "TIPOPL") //"Varia็ใo de Tipos de Planejamento"
oPlanej:AddGetDado("003",,"AMD",1,'xFilial("AMD")+AMB->AMB_CODIGO+AM1->AM1_CODIGO',,, "L3WIN4", "TIPOPL", {|x,y| ValidAMD(x,y)},,,,,"+AMD_VARCOD") //"Varia็ใo de Tipos de Planejamento"

oPlanej:ShowLayout("CFGPLJ")
// Inicializa o Tree
//AtuAgreg(.t.)
 oPlanej:Activate(,.T.)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณValidAM1  บAutor  ณAcacio Egas         บ Data ณ  07/02/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida็ใo do Tipo de Planejamento tabela AM1               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ValidAM1(oBrowse,lTOk)

Local lDel	:= .F.
Local lRet	:= .T.
Local oGetDados
Local nAt
Local nCpTpPlan

If VALTYPE(oBrowse)<>"O"
	lDel	:= .T.
	nCpTpPlan	:= aScan(aHeader,{ |x| x[2]=="AM1_CODIGO"})
	nAt		:= n
EndIf

If lDel
	DbSelectArea("AMC")
	DbSetOrder(1)
	If DbSeek(xFilial("AMC")+AMB->AMB_CODIGO+aCols[nAt,nCpTpPlan])
		Aviso(STR0001,STR0011,{STR0003})//"Aten็ใo!"##"Nใo ้ possivel exluir! Tipo Planejamento com estrutura definida."##"OK"
		lRet	:= .F.
	EndIf
	If lRet
		DbSelectArea("AMD")
		DbSetOrder(1)
		If DbSeek(xFilial("AMD")+AMB->AMB_CODIGO+aCols[nAt,nCpTpPlan])
			Aviso(STR0001,STR0012,{STR0003})//"Aten็ใo"##"Nใo ้ posivel exluir! Tipo Planejamento com varia็ใo definida."##"OK"
			lRet	:= .F.
		EndIf
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณValidAMC  บAutor  ณAcacio Egas         บ Data ณ  07/02/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida็ใo da Estrutura de Planejamento tabela AMC          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ValidAMC(oBrowse)

Local lRet	:= .T.
Local nI

If VALTYPE(oBrowse)=="O"
	oGetDados := oBrowse:oMother // Recebe o Browse como parametro e nao a GetDados.
	For nI := 1 to Len(oGetDados:aCols)
		If !oGetDados:aCols[nI,Len(oGetDados:aHeader)+1]
			lRet	:= MaCheckCols(oGetDados:aHeader,oGetDados:aCols,nI)
			If !lRet
				Exit
			EndIf
		
		EndIf
	Next

Else
	DbSelectArea("ALV")
	DbSetOrder(1)
	Do While ALV->(!Eof()) .and. xFilial("ALV")==ALV->ALV_FILIAL
		If ALV->ALV_CFGPLN==AMB->AMB_CODIGO
			DbSelectArea("AM2")
			DbSetOrder(2)
			If DbSeek(xFilial("AM2")+ALV->ALV_CODIGO+ALV->ALV_VERSAO+AM1->AM1_CODIGO)
				Aviso(STR0001, STR0013 + ALV->ALV_CODIGO + ".",{STR0003})//"Aten็ใo"##"Nใo ้ posivel exluir! Estrutura do tipo de planejamento em uso pela Planilha: "##"OK"
				lRet	:= .F.
				Exit
			EndIf
		EndIf
		ALV->(DbSkip())
	EndDo
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณValidAMD  บAutor  ณAcacio Egas         บ Data ณ  07/02/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida็ใo da Variacao do Planejamento tabela AMC           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ValidAMD(oBrowse)

Local lRet	:= .T.
Local nI

If VALTYPE(oBrowse)=="O"
	oGetDados := oBrowse:oMother // Recebe o Browse como parametro e nao a GetDados.
	For nI := 1 to Len(oGetDados:aCols)
		If !oGetDados:aCols[nI,Len(oGetDados:aHeader)+1]
			lRet	:= MaCheckCols(oGetDados:aHeader,oGetDados:aCols,nI)
			If !lRet
				Exit
			EndIf
		
		EndIf
	Next

Else
	DbSelectArea("ALV")
	DbSetOrder(1)
	Do While ALV->(!Eof()) .and. xFilial("ALV")==ALV->ALV_FILIAL
		If ALV->ALV_CFGPLN==AMB->AMB_CODIGO
			DbSelectArea("ALX")
			DbSetOrder(2)
			If DbSeek(xFilial("ALX")+ALV->ALV_CODIGO+ALV->ALV_VERSAO)
				Aviso(STR0001, STR0014 + ALV->ALV_CODIGO + ".",{STR0003})//"Aten็ใo"##"Nใo ้ posivel exluir! Varia็ใo do tipo de planejamento em uso pela Planilha: "##"OK"
				lRet	:= .F.
				Exit
			EndIf
		EndIf
		ALV->(DbSkip())
	EndDo
EndIf	

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณValidAMB  บAutor  ณAcacio Egas         บ Data ณ  07/02/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida็ใo da COnfiguracao de Planejamento.                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ValidAMB(nOpc)

Local lRet	:= .T.
Local aAreaAM1	:= AM1->(GetArea())
If nOpc==3
	DbSelectArea("AM1")
	DbSetOrder(2)
	If DbSeek(xFilial("AM1")+AMB->AMB_CODIGO)
		Aviso(STR0001,STR0015,{STR0003})//"Aten็ใo"##"Nใo ้ posivel exluir! Configura็ใo de planejamento com tipo de planejamento definido."##"OK"
		lRet	:= .F.
	EndIf
	
	RestArea(aAreaAM1)
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCfgPnjHTMLบAutor  ณAcacio Egas         บ Data ณ  07/02/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta HTML com texto da Configura็ใo de Planejamento.      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CfgPnjHTML()
Local cSayHTML
cSayHTML :=	"<H1>"
cSayHTML +=	STR0016 //"Configura็ใo de Planejamento"
cSayHTML +=	"</H1>"
cSayHTML +=	"<FONT size=+1>"
cSayHTML +=	STR0017 //" A configura็ใo de planejamento ้ uma ferramenta disponibilizada pelo sistema para facilitar"
cSayHTML +=	STR0018//" o planejamento or็amentแrio, possibilitando a cria็ใo de qualquer estrutura de planejamento."
cSayHTML +=	STR0019//" O Controler do or็amento fica responsแvel em desenhar a forma mais simples de prever a rela็ใo das movimenta็๕es financeiras"
cSayHTML +=	STR0020//" de sua empresa. "
cSayHTML +=	"<br><br>" +  STR0021 //" A Configura็ใo '001' ้ padrใo e nใo pode ser apagada."
cSayHTML +=	"</FONT> "

Return(cSayHTML)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณItePnjHTMLบAutor  ณAcacio Egas         บ Data ณ  07/02/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta HTML com texto da Configura็ใo de Planejamento.      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ItePnjHTML()
Local cSayHTML
cSayHTML :=	"<H1>"
cSayHTML +=	STR0006 //"Tipos de Planejamento"
cSayHTML +=	"</H1>"
cSayHTML +=	"<FONT size=+1>"
cSayHTML +=	STR0022//" O tipo de planejamento deve ser utilizado para separar as diferentes opera็๕es financeiras da empresa."
cSayHTML +=	STR0023+ "<br>" //" Exemplo:"
cSayHTML +=	STR0024 + "<br>"//"  -Receitas de Vendas"
cSayHTML +=	STR0025 + "<br>"//"  -Receitas de Servi็o"
cSayHTML +=	STR0026 + "<br>"//"  -Despesas"
cSayHTML +=	STR0027 + "<br>"//"  -Movimentos nใo Operacionais"
cSayHTML +=	STR0028 + "<br>"//"  -Folha de Pagamento"
cSayHTML +=	"</FONT> "

Return(cSayHTML)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVarPnjHTMLบAutor  ณAcacio Egas         บ Data ณ  07/02/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta HTML com texto da Configura็ใo de Planejamento.      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function VarPnjHTML()
Local cSayHTML
cSayHTML :=	"<H1>"
cSayHTML +=	STR0029//"Estrutura e Varia็๕es do tipo de Planejamento"
cSayHTML +=	"</H1>"
cSayHTML +=	"<FONT size=+1>"
cSayHTML +=	STR0030//" Estrutura de Planejamento: Defini as entidades (tabelas do sistema) do ERP responsแveis em detalhar"
cSayHTML +=	STR0031 + "<br>"//" os movimentos financeiros para uma determinada opera็ใo (tipo de planejamento)."
cSayHTML +=	STR0032//" Varia็๕es de Planejamento: Defini as varia็๕es dos movimentos que podem ocorrer dentro de uma"
cSayHTML +=	STR0033//" mesmo opera็ใo (tipo de planejamento). Estas varia็๕es podem ter rela็๕es entre si, dentro e um mesmo tipo de planejamento."
cSayHTML +=	"</FONT> "

Return(cSayHTML)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCriaPad001บAutor  ณAcacio Egas         บ Data ณ  09/09/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cria o cadastro padrใo 001.                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CriaPad001()

Local aTpPlanej	:= {}
Local nX,nY

DbSelectArea("AMB")
DbSetOrder(1)
If !DbSeek(xFilial("AMB")+"001")
	RecLock("AMB",.T.)
	AMB_FILIAL	:= xFilial("AMB")
	AMB_CODIGO	:= "001"
	AMB_DESC	:= STR0034//"CONFIGURACAO PADRAO"
	MsUnLock()
EndIf

//Planejamento de Receitas
aAdd(aTpPlanej,{"001",STR0035,"2",{},{}})//"RECEITAS"
	
	aAdd(aTpPlanej[1,4],{"01","SB1",STR0036,,"SB1->B1_COD","SB1->B1_COD","SB1","ALLTRIM(SB1->B1_COD)+'-'+SB1->B1_DESC","POSICIONE('SB1',1,XFILIAL('SB1')+AM2->AM2_AGREG,'B1_COD')"})//"PRODUTO"

	aAdd(aTpPlanej[1,5],{"01",STR0037,"1","1","U_PCOPRDVEND(CITEM)"	,"1",,"2"		,""})//"RECEITA DIRETA"
	aAdd(aTpPlanej[1,5],{"02",STR0038,"2","1","U_PCOPRDVEND(CITEM)"	,"1",,"2"		,""})//"RECEITA RELACIONADA"
	aAdd(aTpPlanej[1,5],{"03",STR0039,"3","2",""					,"1","ALQ","2"	,""})//"MOV. RELACIONADO"
	aAdd(aTpPlanej[1,5],{"04",STR0040,"4","1","U_PCOPRDCOMP(CITEM)"	,"1",,"2"		,""})//"CUSTO DIRETO"
	
//Planejamento de Despesas
aAdd(aTpPlanej,{"002",STR0041,"2",{},{}})//"DESPESAS"
	
	aAdd(aTpPlanej[2,4],{"01","ALT",STR0042,,"ALT->ALT_CODIGO","ALT->ALT_CODIGO","ALT_01","ALT->(ALT_CODIGO+'-'+ALT_DESCR)","POSICIONE('ALT',1,XFILIAL('ALT')+AM2->AM2_AGREG,'ALT_DESCR')"})//"TIPOS DE DESPESA"

	aAdd(aTpPlanej[2,5],{"01",STR0043,"1","2","","1",,"2",""})//"DESPESAS DIRETAS"
	
//Planejamento de Mov. N Oper.
aAdd(aTpPlanej,{"003",STR0044,"2",{},{}})//"MOV. NAO OPER."
	
	aAdd(aTpPlanej[3,4],{"01","AM4",STR0044,,"AM4->AM4_CODIGO","AM4->AM4_CODIGO","AM4","AM4->(AM4_CODIGO+'-'+AM4_DESCRI)","POSICIONE('AM4',1,XFILIAL('AM4')+AM2->AM2_AGREG,'AM4_DESCRI')"})//"MOV.NAO OPER."

	aAdd(aTpPlanej[3,5],{"01",STR0045,"1","2","","1",,"2",""})//"MOV. N OPERACIONAL"

//Planejamento de Folha de Pagamento
aAdd(aTpPlanej,{"004",STR0046,"2",{},{}})//"FOLHA DE PAGAMENTO"
	
	aAdd(aTpPlanej[4,4],{"01","CTT",STR0047,"ALX_CC","CTT->CTT_CUSTO","CTT->CTT_CUSTO","CTT","CTT->(CTT_CUSTO+'-'+CTT_DESC01)","POSICIONE('CTT',1,XFILIAL('CTT')+AM2->AM2_AGREG,'CTT_DESC01')"})//"CENTRO DE CUSTO"
	aAdd(aTpPlanej[4,4],{"02","SRJ",STR0048,,"SRJ->RJ_FUNCAO","SRJ->RJ_FUNCAO","SRJ","SRJ->(RJ_FUNCAO+'-'+RJ_DESC)","POSICIONE('SRJ',1,XFILIAL('SRJ')+AM2->AM2_AGREG,'RJ_DESC')"})//"FUNCOES"

	aAdd(aTpPlanej[4,5],{"01",STR0049,"1","2","","1",		,"2","0001"})//"VERBA SALARIO" //Quando varia็ใo inicial funciomar Elemnto 3 do array depois sera "6" e Elemento 4 sera "1"
	aAdd(aTpPlanej[4,5],{"02",STR0050,"5","2","","1","AM3"	,"2",""})//"OUTRAS VERBAS"

For nX	:=1 to Len(aTpPlanej)
	DbSelectArea("AM1")
	DbSetOrder(2)
	If !DbSeek(xFilial("AM1")+AMB->AMB_CODIGO+aTpPlanej[nX,1])
		RecLock("AM1",.T.)
	  		AM1_FILIAL	:= xFilial("AM1")
	  		AM1_CFGPLN	:= AMB->AMB_CODIGO
	  		AM1_CODIGO	:= aTpPlanej[nX,1]
	  		AM1_DESCR	:= aTpPlanej[nX,2]
	  		//AM1_COND	:= 
	  		AM1_TIPO	:= aTpPlanej[ nX,3]
		MsUnlock()
	EndIf
	For nY	:=1 to Len(aTpPlanej[nX,4])
		DbSelectArea("AMC")
		DbSetOrder(1)
		If !DbSeek(xFilial("AMC")+AMB->AMB_CODIGO+aTpPlanej[nX,1]+aTpPlanej[nX,4,nY,1])
			RecLock("AMC",.T.)
			AMC_FILIAL	:= xFilial("AMC")
			AMC_CFGPLN	:= AMB->AMB_CODIGO
			AMC_TPCOD	:= aTpPlanej[nX,1]
			AMC_NIVEL	:= aTpPlanej[nX,4,nY,1]
			AMC_TABELA	:= aTpPlanej[nX,4,nY,2]
			AMC_DESCTB	:= aTpPlanej[nX,4,nY,3]
			AMC_ENTORC	:= aTpPlanej[nX,4,nY,4]
			AMC_CHAVE	:= aTpPlanej[nX,4,nY,5]
			AMC_CHVNIV	:= aTpPlanej[nX,4,nY,6]
			AMC_SXB		:= aTpPlanej[nX,4,nY,7]
			AMC_DESCIT	:= aTpPlanej[nX,4,nY,8]
			AMC_POSIC	:= aTpPlanej[nX,4,nY,9]
			MsUnlock()
		EndIf
	Next

	For nY	:=1 to Len(aTpPlanej[nX,5])
		DbSelectArea("AMD")
		DbSetOrder(1)
		If !DbSeek(xFilial("AMD")+AMB->AMB_CODIGO+aTpPlanej[nX,1]+aTpPlanej[nX,5,nY,1])
			RecLock("AMD",.T.)		
				AMD_FILIAL	:= xFilial("AMD")
				AMD_CFGPLN	:= AMB->AMB_CODIGO
				AMD_TPCOD	:= aTpPlanej[nX,1]
				AMD_VARCOD	:= aTpPlanej[nX,5,nY,1]
				AMD_DESVAR	:= aTpPlanej[nX,5,nY,2]
				AMD_TPVAR	:= aTpPlanej[nX,5,nY,3]
				AMD_TIPO	:= aTpPlanej[nX,5,nY,4]
				AMD_VRUNIT	:= aTpPlanej[nX,5,nY,5]
				AMD_NATVAR	:= aTpPlanej[nX,5,nY,6]
				AMD_ALIAS	:= aTpPlanej[nX,5,nY,7]
				AMD_ESTRUT	:= aTpPlanej[nX,5,nY,8]
				AMD_CODIGO	:= aTpPlanej[nX,5,nY,9]
			MsUnlock()
		EndIf
	Next
	
Next

Return

Function PcoFilConf(cAlias,lConf,lPlano,lVar,lRestPar)

Local aParam	:= {}
Local aRet		:= Array(3)
Local cFiltro  := ""
Local aMvs		:= {}

Default lConf	:= .T.
Default lPlano	:= .F.
Default lVar	:= .F.
Default lRestPar:= .F.


If lRestPar
	aAdd( aMvs , MV_PAR01)
	aAdd( aMvs , MV_PAR02)
	aAdd( aMvs , MV_PAR03)
EndIf

	aAdd(aParam,{ 1, STR0051 , Space(tamSx3("AMB_CODIGO")[1])	,"@!","Vazio() .or. ExistCpo('AMB')"	, "AMB", ".T."	,6	,lConf}) //"Conf.Planej."
	aAdd(aParam,{ 1, STR0052 , Space(tamSx3("AM1_CODIGO")[1])	,"@!","Vazio() .or. ExistCpo('AM1',MV_PAR01+MV_PAR02,2)"	, "AM1_01", ".T."	,6	,lPlano}) //"Tipo Planej."
	aAdd(aParam,{ 1, STR0053 , Space(tamSx3("AMD_VARCOD")[1])	,"@!","Vazio() .or. ExistCpo('AMD',MV_PAR01+MV_PAR02+&(ReadVar()),1)"	, "AMD", ".T."	,6	,lVar}) //"Tipo Planej."
	
	If ParamBox(aParam,"",@aRet)
	
		If !Empty(aRet[1])
			DbSelectArea("AMB")
			Dbsetorder(1)
			DbSeek(xFilial("AMB")+aRet[1])
			MV_PAR01 := aRet[1]
			cFiltro	:= cAlias + "_CFGPLN='" + aRet[1] + "'"
			If !Empty(aRet[2])
				DbSelectArea("AM1")
				DbSetOrder(2)
				DbSeek(xFilial("AM1")+AMB->AMB_CODIGO+aRet[2])
				MV_PAR02 := aRet[2]
	 			cFiltro	+= If(Empty(cFiltro),""," AND ") + cAlias + "_TPCOD='" + aRet[2] + "'"
				If !Empty(aRet[3])
					DbSelectArea("AMD")
					DbSetOrder(1)
					DbSeek(xFilial("AMD")+AMB->AMB_CODIGO+aRet[2]+aRet[3])
					MV_PAR03 := aRet[3]
		 			cFiltro	+= If(Empty(cFiltro),""," AND ") + cAlias + "_VARCOD='" + aRet[3] + "'"
				EndIf	
			EndIf	
		EndIf
	ElseIf lRestPar
		MV_PAR01 := aMvs[1]
		MV_PAR02 := aMvs[2]
		MV_PAR03 := aMvs[3]
	EndIf
	
Return cFiltro
