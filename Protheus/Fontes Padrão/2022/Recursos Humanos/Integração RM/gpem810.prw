#INCLUDE "Protheus.ch"
#INCLUDE "GPEM810.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ GPEM810  ณ Autor ณAlberto Deviciente		ณ Data ณ29/Dez/08 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Rotina para geracao das tabelas SRC (Movimento do Periodo) ณฑฑ
ฑฑณ          ณ e SRO (Movimento de Tarefas) referente a integracao entre  ณฑฑ
ฑฑณ          ณ os sistemas Protheus e RM Classis Net (RM Sistemas).       ณฑฑ
ฑฑณ          ณ 															  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ                                                       	  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Integracao Protheus x RM Classis Net (RM) - Folha de Pagto.ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณProgramador ณ Data   ณChamadoณ  Motivo da Alteracao                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณClaudinei S.ณ11/09/13ณ THTRQ4ณAjuste na _IntVldAti para nao gerar errorณฑฑ
ฑฑณ            ณ        ณ       ณquando o MV_RMCLASS == .T. e nao existir ณฑฑ
ฑฑณ            ณ        ณ       ณa tabela de integracao INT_ATIVIDADE.    ณฑฑ
ฑฑณClaudinei S.ณ23/09/13ณ THVDUVณAjuste na GPM810Cmpo para nao gerar errorณฑฑ
ฑฑณ            ณ        ณ       ณlog quando o Banco de dados for DB2.     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/   
Function GPEM810()
Local dDt1Mat       := cTod( Space(8) )
Local dDt2Mat       := cTod( Space(8) )
Local cQuery		:= ""
Local aCodSimula 	:= {}
Local oChk 			
Local cMsgAlert		:= ""

Private oWizard		
Private oDt1Mat		
Private oDt2Mat   	
Private oSay1
Private oCodSimula	
Private oGetMatriI,oGetMatriF,oGetCCusto,oGetCCustF,oBrowse4,oGetSitFun,oGetProcDe,oGetProcAt
Private cGetMatriI  := Space(TamSX3("RA_MAT")[1]) 
Private cGetMatriF  := Replicate("Z",TamSX3("RA_MAT")[1])
Private cGetCCustI  := Space(TamSX3("CTT_CUSTO")[1])
Private cGetCCustF  := Space(TamSX3("CTT_CUSTO")[1])
Private cGetSitFun  := Space(10)
Private cSitFunAnt  := ""
Private lChk        := .T. //Guarda o valor do objeto - marca todos os professores
Private oNoMarked  	:= LoadBitmap( GetResources(),'LBNO')
Private oMarked	  	:= LoadBitmap( GetResources(),'LBOK')
Private nOper       := 1
Private nCurrent    := 0 
Private aBrowse 	:= {}
Private oBrowse     := Nil
Private aBrowse4 	:= {}
Private lMSSQL	   	:= "MSSQL"$Upper(TCGetDB())
Private	lOracle		:= "ORACLE"$Upper(TCGetDB())
Private	lDB2		:= "DB2"$Upper(TCGetDB())
Private	lMySQL		:= "MYSQL"$Upper(TCGetDB())
Private cCodSimula  := ""
Private cCodSimAnt  := ""
Private aInconsSR5	:= {}

Static lUsaContex  := .F. //Variavel que controla a existencia do Campo "Tipo Curso" (Contexto) na tabela SIGAGPE (X59)
Static lTarTIPOATV := .F.

lTarTIPOATV := GPM810Cmpo("INT_TAREFA", "TAR_TIPOATV") //Verifica se existe o campo TAR_TIPOATV na base de dados

dbSelectArea("SRC")
dbSelectArea("SRO")

//Verifica se existe o Campo Tipo Curso (Contexto) na tabela SIGAGPE (X59)
dbSelectArea("SR5")
dbSetOrder(1)
lUsaContex := SR5->( dbSeek("  "+"X59"+"0214") ) .and. GPM810Cmpo("INT_TAREFA", "TAR_CONTEXTO") //Verifica se existe o campo CONTEXTO na base de dados

Private cProcDe		:= Space(TamSx3('RCH_PROCESS')[1])
Private cProcAt		:= Space(TamSx3('RCH_PROCESS')[1])
Private cProcDeAnt	:= Space(TamSx3('RCH_PROCESS')[1])
Private cProcAtAnt	:= Space(TamSx3('RCH_PROCESS')[1])

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAntes de iniciar a rotina faz algumas verificacoes necessarias.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If!GetNewPar("MV_CLASSIS", .F.) 			//Verifica se Integracao Protheus X RM Classis Net (RM Sistemas) estah ativa
	cMsgAlert := STR0001 + CHR(10)+CHR(10) //"Esta rotina somente pode ser utilizada se a integra็ใo entre os sistemas Protheus x RM Classis Net estiver ativa."
	cMsgAlert += STR0002 					//"Esta integra็ใo nใo estแ ativa."
ElseIf !TCCanOpen("INT_ATIVIDADE") 			//Verifica se a tabela INT_ATIVIDADE existe.
	cMsgAlert := STR0003 + CHR(10)+CHR(10) //"A tabela INT_ATIVIDADE nใo foi encontrada na base de dados." 
	cMsgAlert += STR0004					//"A instala็ใo da Integra็ใo entre os sistemas Protheus x RM Classis Net nใo foi feita corretamente."
ElseIf !TCCanOpen("INT_TAREFA") 			//Verifica se a tabela INT_TAREFA existe
	cMsgAlert := STR0005 + CHR(10)+CHR(10)	//"A tabela INT_TAREFA nใo foi encontrada na base de dados."
	cMsgAlert += STR0006					//"A instala็ใo da Integra็ใo entre os sistemas Protheus x RM Classis Net nใo foi feita corretamente."
EndIf

If!empty(cMsgAlert)
	MsgStop(cMsgAlert)
	Return
EndIf

// Montagem de Wizard de Integracao de Folha de pagamento
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPrimeiro painelณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oWizard := APWizard():New(STR0012 /*<chTitle>*/, ""/*<chMsg>*/, STR0013,/*<cTitle>*/ STR0014+STR0015/*<cText>*/, {|| .T. }/*<bNext>*/, {|| .T.}/*<bFinish>*/, ,,, )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSegundo painel ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oWizard:NewPanel( STR0016/*<chTitle>*/, STR0017 /*<chMsg>*/,{ ||.T.}/*<bBack>*/, {|| GPM810VPn2(@dDt1Mat,@dDt2Mat) .and. GPM810Fil(@oChk) }/*<bNext>*/, {|| .T.}/*<bFinish>*/,/*<.lPanel.>*/, {|| .T.}/*<bExecute>*/ )

TSay():New( 005, 007, {|| STR0018 }		, oWizard:oMPanel[2], , , , , , .T., , , 200, 08, , , , , , ) 			//"C๓digo da Simula็ใo:" 	
TSay():New( 020, 007, {|| STR0019 }		, oWizard:oMPanel[2], , , , , , .T., , , 200, 08, , , , , , ) 			//"Dt. Inicial"	
TSay():New( 020, 130, {|| STR0020 } 		, oWizard:oMPanel[2], , , , , , .T., , , 200, 08, , , , , , ) 			//"Dt. Final"
TSay():New( 035, 007, {|| STR0021 }		, oWizard:oMPanel[2], , , , , , .T., , , 200, 08, , , , , , ) 			//"Matrํcula Inicial"
TSay():New( 035, 130, {|| STR0022 } 		, oWizard:oMPanel[2], , , , , , .T., , , 200, 08, , , , , , ) 			//"Matrํcula Final"	
TSay():New( 050, 007, {|| STR0023 }     	, oWizard:oMPanel[2], , , , , , .T., , , 200, 08, , , , , , ) 			//"Centro de Custo Inicial"	
TSay():New( 050, 130, {|| STR0024 } 		, oWizard:oMPanel[2], , , , , , .T., , , 200, 08, , , , , , ) 			//"Centro de Custo Final"	
TSay():New( 065, 007, {|| STR0066 } 		, oWizard:oMPanel[2], , , , , , .T., CLR_HBLUE, , 200, 08, , , , , , )	//"Situa็๕es a Considerar"
TSay():New( 080, 007, {|| STR0076 } 		, oWizard:oMPanel[2], , , , , , .T.,CLR_HBLUE, , 200, 08, , , , , , )		//"C๓d. Processo De:"
TSay():New( 080, 130, {|| STR0077 } 		, oWizard:oMPanel[2], , , , , , .T.,CLR_HBLUE, , 200, 08, , , , , , )		//"C๓d Processo Ate:"

//Busca a lista de Simulacoes relativas a gera็ใo da Folha de Pagamento na tabela INT_TAREFA
GPM810Simu(@aCodSimula)


//Combo - Lista das Simulacoes existentes na tabela INT_TAREFA
oCodSimula := TCOMBOBOX():Create(oWizard:oMPanel[2])
oCodSimula:cName := "oCodSimula"
oCodSimula:nLeft := 135
oCodSimula:nTop := 11
oCodSimula:nWidth := 180
oCodSimula:nHeight := 19
oCodSimula:lShowHint := .F.
oCodSimula:lReadOnly := .F.
oCodSimula:Align := 0 
oCodSimula:cVariable := "cCodSimula"
oCodSimula:bSetGet := {|u| If(PCount()>0,cCodSimula:=u,cCodSimula) }
oCodSimula:lVisibleControl := .T.
oCodSimula:nAt := nOper      
oCodSimula:aItems := aCodSimula
oCodSimula:bValid := {|| .T. }
oCodSimula:bWhen  := {|| AllwaysTrue() }
oCodSimula:bChange := {|| GPM810CPn1(@dDt1Mat, @dDt2Mat) } 

@019,067 MsGet oDt1Mat Var dDt1Mat Size 040,008 pixel OF oWizard:oMPanel[2] when .F.
@019,185 MsGet oDt2Mat Var dDt2Mat Size 040,008 pixel OF oWizard:oMPanel[2] when .F.

oGetMatriI := TGET():Create(oWizard:oMPanel[2])
oGetMatriI:cName := "oGetMatriI"
oGetMatriI:nLeft := 135
oGetMatriI:nTop := 67
oGetMatriI:nWidth := 70
oGetMatriI:nHeight := 19
oGetMatriI:lShowHint := .F.
oGetMatriI:lReadOnly := .F.
oGetMatriI:Align := 0   
oGetMatriI:cF3   := "SRA"
oGetMatriI:cVariable := "cGetMatriI"
oGetMatriI:bSetGet := {|u| If(PCount()>0,cGetMatriI:=u,cGetMatriI) }
oGetMatriI:lVisibleControl := .T.
oGetMatriI:lPassword := .F.
oGetMatriI:lHasButton := .F.
oGetMatriI:bWhen  := {|| .F. }

oGetMatriF := TGET():Create(oWizard:oMPanel[2])
oGetMatriF:cName := "oGetMatriF"
oGetMatriF:nLeft := 370
oGetMatriF:nTop := 67
oGetMatriF:nWidth := 70
oGetMatriF:nHeight := 19
oGetMatriF:lShowHint := .F.
oGetMatriF:lReadOnly := .F.
oGetMatriF:Align := 0   
oGetMatriF:cF3   := "SRA"
oGetMatriF:cVariable := "cGetMatriF"
oGetMatriF:bSetGet := {|u| If(PCount()>0,cGetMatriF:=u,cGetMatriF) }
oGetMatriF:lVisibleControl := .T.
oGetMatriF:lPassword := .F.
oGetMatriF:lHasButton := .F.
oGetMatriF:bWhen  := {|| .F. }

oGetCCusto := TGET():Create(oWizard:oMPanel[2])
oGetCCusto:cName := "oGetCCusto"
oGetCCusto:nLeft := 135
oGetCCusto:nTop := 100
oGetCCusto:nWidth := 90
oGetCCusto:nHeight := 19
oGetCCusto:lShowHint := .F.
oGetCCusto:lReadOnly := .F.
oGetCCusto:Align := 0   
oGetCCusto:cF3   := "CTT"
oGetCCusto:cVariable := "cGetCCustI"
oGetCCusto:bSetGet := {|u| If(PCount()>0,cGetCCustI:=u,cGetCCustI) }
oGetCCusto:lVisibleControl := .T.
oGetCCusto:lPassword := .F.
oGetCCusto:lHasButton := .F.
oGetCCusto:bWhen  := {|| .F. }

oGetCCustF := TGET():Create(oWizard:oMPanel[2])
oGetCCustF:cName := "oGetCCustF"
oGetCCustF:nLeft := 370
oGetCCustF:nTop := 100
oGetCCustF:nWidth := 90
oGetCCustF:nHeight := 19
oGetCCustF:lShowHint := .F.
oGetCCustF:lReadOnly := .F.
oGetCCustF:Align := 0   
oGetCCustF:cF3   := "CTT"
oGetCCustF:cVariable := "cGetCCustF"
oGetCCustF:bSetGet := {|u| If(PCount()>0,cGetCCustF:=u,cGetCCustF) }
oGetCCustF:lVisibleControl := .T.
oGetCCustF:lPassword := .F.
oGetCCustF:lHasButton := .F.
oGetCCustF:bWhen  := {|| .F. }

oGetSitFun := TGET():Create(oWizard:oMPanel[2])
oGetSitFun:cName := "oGetSitFun"
oGetSitFun:nLeft := 135
oGetSitFun:nTop := 130
oGetSitFun:nWidth := 90
oGetSitFun:nHeight := 19
oGetSitFun:lShowHint := .F.
oGetSitFun:lReadOnly := .F.
oGetSitFun:Align := 0   
oGetSitFun:cVariable := "cGetSitFun"
oGetSitFun:bSetGet := {|u| If(PCount()>0,cGetSitFun:=u,cGetSitFun) }
oGetSitFun:lVisibleControl := .T.
oGetSitFun:lPassword := .F.
oGetSitFun:lHasButton := .F.
oGetSitFun:bValid := {|| GPM810SitF(.T.) }
oGetSitFun:BGOTFOCUS:= {|| GPM810SitF(.F.) }

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCria os combos Cod processo De e Ateณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oGetProcDe := TGET():Create(oWizard:oMPanel[2])
oGetProcDe:cName 			:= "oGetProcDe"
oGetProcDe:nLeft 			:= 135
oGetProcDe:nTop 			:= 160
oGetProcDe:nWidth 			:= 90
oGetProcDe:nHeight 			:= 19
oGetProcDe:lShowHint 		:= .F.
oGetProcDe:lReadOnly 		:= .F.
oGetProcDe:Align 			:= 0   
oGetProcDe:cVariable 		:= "cProcDe"
oGetProcDe:cF3				:= "RCJ"
oGetProcDe:bSetGet 			:= {|u| If(PCount()>0,cProcDe:=u,cProcDe) }
oGetProcDe:lVisibleControl 	:= .T.
oGetProcDe:lPassword 		:= .F.
oGetProcDe:lHasButton 		:= .F.
oGetProcDe:bValid 	  		:= {||.T. }
//oGetProcDe:bGoTFocus	 	:= {|| .T. }

oGetProcAt := TGET():Create(oWizard:oMPanel[2])
oGetProcAt:cName 			:= "oGetProcAt"
oGetProcAt:nLeft 			:= 370
oGetProcAt:nTop 			:= 160
oGetProcAt:nWidth 			:= 90
oGetProcAt:nHeight 			:= 19
oGetProcAt:lShowHint 		:= .F.
oGetProcAt:lReadOnly 		:= .F.
oGetProcAt:Align 			:= 0   
oGetProcAt:cVariable 		:= "cProcAt"
oGetProcAt:cF3				:= "RCJ"
oGetProcAt:bSetGet 			:= {|u| If(PCount()>0,cProcAt:=u,cProcAt) }
oGetProcAt:lVisibleControl 	:= .T.
oGetProcAt:lPassword 		:= .F.
oGetProcAt:lHasButton 		:= .F.
oGetProcAt:bValid 	  		:= {||.T. }	
//oGetProcAt:bGoTFocus	 	:= {|| .T. }

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณTerceiro painelณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oWizard:NewPanel( STR0025 /*<chTitle>*/, STR0026 + STR0027 /*<chMsg>*/,{ || GPM810BkPn3() }/*<bBack>*/, {|| GPM810VPn3() .and. GPM810Proc() .and. GPM810Brow() }/*<bNext>*/, {|| .T.}/*<bFinish>*/, /*<.lPanel.>*/, {|| .T.}/*<bExecute>*/ )

oChk := TCHECKBOX():Create(oWizard:oMPanel[3])
oChk:cName := "oChk"
oChk:cCaption := STR0028 //"Selecionar todos registros"
oChk:nLeft := 005
oChk:nTop := 002
oChk:nWidth := 190
oChk:nHeight := 17
oChk:lShowHint := .F.
oChk:lReadOnly := .F.
oChk:Align := 0
oChk:cVariable := "lChk"
oChk:bSetGet := {|u| If(PCount()>0,lChk:=u,lChk) }
oChk:lVisibleControl := .T.
oChk:bChange := {|| GPM810CkAll() }

if len(aBrowse) == 0
	AAdd(aBrowse ,{.F.,Space(5),Space(5),Space(5),Space(3),Space(3),Space(3)} ) 
EndIf

oBrowse := VCBrowse():New( 013 , 002, 250, 108,,{'',STR0029,STR0030,STR0031,STR0032,STR0033,STR0034},{20,30,30}, oWizard:oMPanel[3], ,,,,{|| .T.},,,,,,,.F.,,.T.,,.F.,,, )
oBrowse:SetArray(aBrowse)
oBrowse:bLine := {||{ If(aBrowse[oBrowse:nAt,01],oMarked,oNoMarked),;
											aBrowse[oBrowse:nAt,02],;
											aBrowse[oBrowse:nAt,03],;
											aBrowse[oBrowse:nAt,04],;
											aBrowse[oBrowse:nAt,05],;
											aBrowse[oBrowse:nAt,06],;
											aBrowse[oBrowse:nAt,07] } }
oBrowse:BLDBLCLICK:= {|| GPM810CkPr(@oChk) }


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณQuarto painel  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู                                                                                                                                                        
oWizard:NewPanel( STR0035 /*<chTitle>*/, ""/*<chMsg>*/, /*<bBack>*/, /*<bNext>*/, /*<bFinish>*/, /*<.lPanel.>*/, {|| oWizard:OCANCEL:LVISIBLECONTROL:=.F.}/*<bExecute>*/ )

TSay():New( 25, 002, {|| STR0036 }, oWizard:oMPanel[4],,,,,, .T.,,, 200, 08,,,,,, )	  //"Gera็ใo da Folha de Pagamento concluํda. Clique em <Finalizar>."

oSay1 := TSay():New( 002, 002, {|| STR0037 }, oWizard:oMPanel[4],,,,,, .T.,,, 350, 08,,,,,, ) //"Lista de Inconsist๊ncias:"	 

if len(aBrowse4) == 0
	AAdd(aBrowse4 ,{Space(200)} ) 
EndIf

aBrowse4 := aClone(aBrowse4) 
oBrowse4:= VCBrowse():New( 013 , 002, 250, 108,,{STR0038},{200}, oWizard:oMPanel[4], ,,,,{|| .T.},,,,,,,.F.,,.T.,,.F.,,, )
oBrowse4:SetArray(aBrowse4)
oBrowse4:bLine := {||{ aBrowse4[oBrowse4:nAt,01] } }

oWizard:Activate(.T.,,,)

Return  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |GPM810Fil บAutor  ณAlberto Deviciente  บ Data ณ 29/Dez/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEfetua filtro Buscando os registros na tabela INT_TAREFA.   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ Integracao Protheus x RM Classis Net (RM) - Folha de Pagto.ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GPM810Fil(oChk)

if AllTrim(cCodSimAnt) <> AllTrim(cCodSimula) .or. AllTrim(cSitFunAnt) <> AllTrim(cGetSitFun) .or. ;
	AllTrim(cProcDeAnt) <> AllTrim(cProcDe) .or. AllTrim(cProcAtAnt) <> AllTrim(cProcAt)
	MsgRun(STR0039,STR0040,{|| GPM810ExFi(@oChk) })
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGPM810ExFiบAutor  ณAlberto Deviciente  บ Data ณ 29/Dez/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExecuta filtro Buscando os registros na tabela INT_TAREFA.  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ Integracao Protheus x RM Classis Net (RM) - Folha de Pagto.ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GPM810ExFi(oChk)
Local cQuery     := ""
Local cArqTrb 	 := GetNextAlias()
Local cNumRows
Local cSitsFunc  := rtrim(cGetSitFun)
Local cSitFunIN  := ""
Local nInd		 := 0
Local cArqTRP	 := GetNextAlias() 

for nInd:=1 to len(cSitsFunc)
	cSitFunIN += "'"+SubStr(cSitsFunc,nInd,1)+"',"
next nInd
//Tira a ultima virgula
cSitFunIN := SubStr(cSitFunIN,1,len(cSitFunIN)-1)

aBrowse := {}

cQuery := " select TAR_COLIGADA, TAR_FILIAL, TAR_CODPROF, TAR_TITULACAO, TAR_CCUSTO, " 
if lMSSQL
	cQuery += " convert(varchar(8),TAR_DATAINI,112) TAR_DATAINI, "
	cQuery += " convert(varchar(8),TAR_DATAFIM,112) TAR_DATAFIM "
Else                                                                          
	cQuery += " to_char(TAR_DATAINI,'YYYYMMDD') TAR_DATAINI, "
	cQuery += " to_char(TAR_DATAFIM,'YYYYMMDD') TAR_DATAFIM "
EndIf
cQuery += "  from INT_TAREFA, "+RetSQLName("SRA")
cQuery += " where TAR_COLIGADA = "+AllTrim(str(val(SM0->M0_CODIGO)))
cQuery += "   and TAR_FILIAL = '"+SM0->M0_CODFIL+"'"
cQuery += "   and RA_FILIAL = '"+xFilial("SRA")+"'"
cQuery += "   and TAR_CODSIMULAC = '"+Rtrim(cCodSimula)+"'"
cQuery += "   and TAR_STATUSIMPORT IN ('1','3') " //Somente registros que ainda nao foram processados
cQuery += "   and TAR_CODPROF = RA_MAT"
cQuery += "   and RA_SITFOLH in ("+cSitFunIN+")" //Filtra apenas os Funcionarios cuja Situacao esta dentro das Situacoes informadas na tela
cQuery += "   and D_E_L_E_T_ = ' ' "
cQuery += " and RA_PROCES BETWEEN '" + cProcDe + "' AND '" + cProcAt + "'" 
cQuery += " group by TAR_COLIGADA, TAR_FILIAL, TAR_CODPROF, TAR_TITULACAO, TAR_CCUSTO, TAR_DATAINI, TAR_DATAFIM"
cQuery := ChangeQuery( cQuery )
dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), cArqTrb, .F., .F. )

(cArqTrb)->( dbgotop() )
while (cArqTrb)->( !eof() )
	
	If(aScan(aBrowse,{|x| x[2] == (cArqTrb)->TAR_CODPROF})) == 0
	
		//Verifica se o professor em questao possui Hora Aula
		cQuery := " select count(*) QTDH from INT_TAREFA "
		cQuery += "  where TAR_COLIGADA = "+AllTrim(str(val(SM0->M0_CODIGO)))
		cQuery += "    and TAR_FILIAL = '"+SM0->M0_CODFIL+"'"
		cQuery += "    and TAR_CODSIMULAC = '"+Rtrim(cCodSimula)+"'"
		cQuery += "    and TAR_TIPOTAREFA = 'H' "
		cQuery += "    and TAR_CODPROF = ('"+(cArqTrb)->TAR_CODPROF+"') "
		cQuery := ChangeQuery( cQuery )
		dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), "TRH", .F., .F. )
		
		//Verifica se o professor em questao possui Atividades/Projetos
		cQuery := " select count(*) QTDP from INT_TAREFA "
		cQuery += "  where TAR_COLIGADA = "+AllTrim(str(val(SM0->M0_CODIGO)))
		cQuery += "    and TAR_FILIAL = '"+SM0->M0_CODFIL+"'"
		cQuery += "    and TAR_CODSIMULAC = '"+Rtrim(cCodSimula)+"'"
		cQuery += "    and TAR_TIPOTAREFA = 'P' "
		cQuery += "    and TAR_CODPROF = ('"+(cArqTrb)->TAR_CODPROF+"') "
		cQuery := ChangeQuery( cQuery )
		dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), cArqTRP, .F., .F. )
		
		//Verifica se o professor em questao possui Faltas
		cQuery := " select count(*) QTDF from INT_TAREFA "
		cQuery += "  where TAR_COLIGADA = "+AllTrim(str(val(SM0->M0_CODIGO)))
		cQuery += "    and TAR_FILIAL = '"+SM0->M0_CODFIL+"'"
		cQuery += "    and TAR_CODSIMULAC = '"+Rtrim(cCodSimula)+"'"	
		cQuery += "    and TAR_TIPOTAREFA = 'F' "
		cQuery += "    and TAR_CODPROF = ('"+(cArqTrb)->TAR_CODPROF+"') "
		cQuery := ChangeQuery( cQuery )
		dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), "TRF", .F., .F. )
		
		aAdd(aBrowse ,{ .T., (cArqTrb)->TAR_CODPROF,;
						Left(Posicione("SRA",1,xFilial("SRA")+(cArqTrb)->TAR_CODPROF,"RA_NOME"),50),;
						AllTrim(Tabela("FF",StrZero(val((cArqTrb)->TAR_TITULACAO),2),.F.)),;
						iif(TRH->QTDH>0,STR0041,STR0042),;
						iif((cArqTRP)->QTDP>0,STR0041,STR0042),;
						iif(TRF->QTDF>0,STR0041,STR0042) } )
		
		TRH->( dbclosearea() )
		(cArqTRP)->( dbclosearea() )
		TRF->( dbclosearea() )
		
	EndIf
	
	(cArqTrb)->( dbskip() )
end
(cArqTrb)->( dbclosearea() )

if len(aBrowse) == 0
	AAdd(aBrowse ,{.F.,Space(5),Space(5),Space(5),Space(3),Space(3),Space(3)} )
EndIf

oBrowse:SetArray(aBrowse)
oBrowse:bLine := {||{ If(aBrowse[oBrowse:nAt,01],oMarked,oNoMarked),;
											aBrowse[oBrowse:nAt,02],;
											aBrowse[oBrowse:nAt,03],;
											aBrowse[oBrowse:nAt,04],;
											aBrowse[oBrowse:nAt,05],;
											aBrowse[oBrowse:nAt,06],;
											aBrowse[oBrowse:nAt,07] } }
oBrowse:Refresh()

if len(aBrowse) > 0 .and. !empty(aBrowse[1,1])
	cNumRows := len(aBrowse)
EndIf
oNumRows := TGET():Create(oWizard:oMPanel[3])
oNumRows:cName := "oNumRows"
oNumRows:nLeft := 005
oNumRows:nTop := oBrowse:nHeight+30
oNumRows:nWidth := 30
oNumRows:nHeight := 19
oNumRows:lShowHint := .F.
oNumRows:lReadOnly := .F.
oNumRows:Align := 0
oNumRows:cVariable := "cNumRows"
oNumRows:bSetGet := {|u| If(PCount()>0,cNumRows:=u,cNumRows) }
oNumRows:lVisibleControl := .T.
oNumRows:lPassword := .F.
oNumRows:lHasButton := .F.
oNumRows:bValid := {|| .T. }
oNumRows:bWhen  := {|| .F. }

TSay():New( 123, oNumRows:nWidth-10, {|| STR0043 }, oWizard:oMPanel[3],,,,,, .T.,,, 200, 08,,,,,, ) //"Total de registros"

lChk := .T.
oChk:Refresh()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGPM810SimuบAutor  ณAlberto Deviciente  บ Data ณ 29/Dez/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณListando as Simulacoes relativas a gera็ใo da Folha de      บฑฑ
ฑฑบ          ณde Pagamento na tabela INT_TAREFA.                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ Integracao Protheus x RM Classis Net (RM) - Folha de Pagto.ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GPM810Simu(aCodSimula)                                                     
Local cAlias 	:= GetNextAlias()
Local cQuery 	:= ""  

aCodSimula := {}
Aadd(aCodSimula,STR0044) //"Selecione a Simula็ใo..."

cQuery := "select TAR_CODSIMULAC "
cQuery += "  from INT_TAREFA "
cQuery += " where TAR_COLIGADA = "+AllTrim(str(val(SM0->M0_CODIGO)))
cQuery += "   and TAR_FILIAL = '"+SM0->M0_CODFIL+"'"
cQuery += "   and TAR_STATUSIMPORT IN ('1','3')" //Somente registros que ainda nao foram processados (1=Nao Processado; 3=Inconsistente)
cQuery += " group by TAR_CODSIMULAC, TAR_DATAINI "
cQuery += " order by TAR_DATAINI DESC"
cQuery := ChangeQuery( cQuery )
dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), cAlias, .F., .F. )

while (cAlias)->( !EoF() )
	Aadd( aCodSimula, (cAlias)->TAR_CODSIMULAC )
	(cAlias)->( dbskip() )
end
(cAlias)->( dbCloseArea() )

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGPM810CPn1บAutor  ณAlberto Deviciente  บ Data ณ 29/Dez/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCarga Inicial dos dados relativos ao primeiro painel.       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ Integracao Protheus x RM Classis Net (RM) - Folha de Pagto.ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GPM810CPn1(dDt1Mat, dDt2Mat)
Local cSQL 		:= ""
Local cAlias 	:= GetNextAlias()

dDt1Mat    	:= Ctod("  /  /  ")
dDt2Mat  	:= Ctod("  /  /  ")
cGetMatriI 	:= Space(6)
cGetMatriF 	:= Space(6)
cGetCCustI 	:= Space(9)
cGetCCustF 	:= Space(9)

//Efetuando filtros relativos a simula็ใo selecionada
cSQL := "select "
if lMSSQL
	cSQL += " MAX(convert(varchar(8),TAR_DATAINI,112)) DTI "
Else
	cSQL += " MAX(to_char(TAR_DATAINI,'YYYYMMDD')) DTI "
EndIf
cSQL += "  from INT_TAREFA "
cSQL += " where TAR_COLIGADA = "+AllTrim(str(val(SM0->M0_CODIGO)))
cSQL += "   and TAR_FILIAL = '"+SM0->M0_CODFIL+"'"
cSQL += "   and TAR_CODSIMULAC = '"+Rtrim(cCodSimula)+"'"

cSQL := ChangeQuery( cSQL )
dbUseArea( .T., "TopConn", TCGenQry(,,cSQL), cAlias, .F., .F. )
If(cAlias)->( !eof() )
	dDt1Mat := StoD((cAlias)->DTI) 
EndIf
(cAlias)->( dbCloseArea() )

cSQL := "select "
if lMSSQL
	cSQL += " MAX(convert(varchar(8),TAR_DATAFIM,112)) DTF "
Else
	cSQL += " MAX(to_char(TAR_DATAFIM,'YYYYMMDD')) DTF "
EndIf
cSQL += "  from INT_TAREFA "
cSQL += " where TAR_COLIGADA = "+AllTrim(str(val(SM0->M0_CODIGO)))
cSQL += "   and TAR_FILIAL = '"+SM0->M0_CODFIL+"'"
cSQL += "   and TAR_CODSIMULAC = '"+Rtrim(cCodSimula)+"'"
cSQL := ChangeQuery( cSQL )
dbUseArea( .T., "TopConn", TCGenQry(,,cSQL), cAlias, .F., .F. )
If(cAlias)->( !eof() ) 
	dDt2Mat := StoD((cAlias)->DTF) 
EndIf
(cAlias)->( dbCloseArea() )

cSQL := "select MIN(TAR_CODPROF) MATI from INT_TAREFA "
cSQL += " where TAR_COLIGADA = "+AllTrim(str(val(SM0->M0_CODIGO)))
cSQL += "   and TAR_FILIAL = '"+SM0->M0_CODFIL+"'"
cSQL += "   and TAR_CODSIMULAC = '"+Rtrim(cCodSimula)+"'"
cSQL := ChangeQuery( cSQL )
dbUseArea( .T., "TopConn", TCGenQry(,,cSQL), cAlias, .F., .F. )                       
If(cAlias)->( !eof() )
	cGetMatriI := (cAlias)->MATI 
EndIf
(cAlias)->( dbCloseArea() )

cSQL := "select MAX(TAR_CODPROF) MATF from INT_TAREFA "
cSQL += " where TAR_COLIGADA = "+AllTrim(str(val(SM0->M0_CODIGO)))
cSQL += "   and TAR_FILIAL = '"+SM0->M0_CODFIL+"'"
cSQL += "   and TAR_CODSIMULAC = '"+Rtrim(cCodSimula)+"'"
cSQL := ChangeQuery( cSQL )
dbUseArea( .T., "TopConn", TCGenQry(,,cSQL), cAlias, .F., .F. )
If(cAlias)->( !eof() )
	cGetMatriF := (cAlias)->MATF
EndIf
(cAlias)->( dbCloseArea() )

cSQL := "select MIN(TAR_CCUSTO) CCUSI from INT_TAREFA "
cSQL += " where TAR_COLIGADA = "+AllTrim(str(val(SM0->M0_CODIGO)))
cSQL += "   and TAR_FILIAL = '"+SM0->M0_CODFIL+"'"
cSQL += "   and TAR_CODSIMULAC = '"+Rtrim(cCodSimula)+"'"
cSQL := ChangeQuery( cSQL )
dbUseArea( .T., "TopConn", TCGenQry(,,cSQL), cAlias, .F., .F. )
If(cAlias)->( !eof() )
	cGetCCustI := (cAlias)->CCUSI
EndIf
(cAlias)->( dbCloseArea() )

cSQL := "select MAX(TAR_CCUSTO) CCUSF from INT_TAREFA "
cSQL += " where TAR_COLIGADA = "+AllTrim(str(val(SM0->M0_CODIGO)))
cSQL += "   and TAR_FILIAL = '"+SM0->M0_CODFIL+"'"
cSQL += "   and TAR_CODSIMULAC = '"+Rtrim(cCodSimula)+"'"
cSQL := ChangeQuery( cSQL )
dbUseArea( .T., "TopConn", TCGenQry(,,cSQL), cAlias, .F., .F. )
If(cAlias)->( !eof() ) 
	cGetCCustF := (cAlias)->CCUSF
EndIf
(cAlias)->( dbCloseArea() )

oDt1Mat:Refresh()
oDt2Mat:Refresh()
oGetMatriI:Refresh()
oGetMatriF:Refresh()
oGetCCusto:Refresh()
oGetCCustF:Refresh() 
oCodSimula:SetFocus()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGPM810CkPrบAutor  ณAlberto Deviciente  บ Data ณ 29/Dez/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMarca o Professor.                                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ Integracao Protheus x RM Classis Net (RM) - Folha de Pagto.ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GPM810CkPr(oChk)
Local nCount := 0

If!empty(oBrowse:AARRAY[oBrowse:nAt,2])
	oBrowse:AARRAY[oBrowse:nAt,1] := !oBrowse:AARRAY[oBrowse:nAt,1]
	aBrowse := aClone(oBrowse:AARRAY)
	oBrowse:Refresh()
Else
	lChk := .F.
EndIf

aEval( aBrowse, { |x| nCount += iif( x[1], 1, 0 ) } )

if len(aBrowse) == nCount
	lChk := .T.
Else
	lChk := .F.
EndIf

oChk:Refresh()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma ณGPM810CkAllบAutor  ณAlberto Deviciente  บ Data ณ 29/Dez/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMarca todos os registros.                                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ Integracao Protheus x RM Classis Net (RM) - Folha de Pagto.ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GPM810CkAll()

if len(oBrowse:AARRAY) == 1 .and. empty(oBrowse:AARRAY[1][2])
	Return
EndIf

aEval( oBrowse:AARRAY, { |x| x[1] := lChk } )

aBrowse := aClone(oBrowse:AARRAY)
oBrowse:Refresh()

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGPM810VPn2บAutor  ณAlberto Deviciente  บ Data ณ 29/Dez/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida dados digitados no painel 2                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ Integracao Protheus x RM Classis Net (RM) - Folha de Pagto.ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GPM810VPn2(dDtIni,dDtFim)
Local lRet 		:= .T.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica se foi selecionada a simulacaoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If AllTrim(cCodSimula) == "Selecione a Simula็ใo..."
	MsgStop(STR0045) //"Selecione a simula็ใo."
	lRet := .F.
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica se foi selecionada Situacoes de Funcionarios   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lRet .and. Empty(cGetSitFun)
	MsgStop(STR0067) //"As Situa็๕es de Funcionแrios a considerar no processamento devem ser informadas."
	lRet := .F.
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGPM810VPn3บAutor  ณAlberto Deviciente  บ Data ณ 29/Dez/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida dados informados no painel 3                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ Integracao Protheus x RM Classis Net (RM) - Folha de Pagto.ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GPM810VPn3()
Local lRet := .F.
Local nInd := 0

for nInd := 1 to len(oBrowse:AARRAY)
	if oBrowse:AARRAY[nInd,1]
		lRet := .T.
		Exit
	EndIf
next nInd

If!lRet
	MsgStop(STR0046) //"Ao menos um professor deve ser selecionado."
EndIf

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGPM810ProcบAutor  ณAlberto Deviciente  บ Data ณ 29/Dez/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณChama a execucao do processamento.                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ Integracao Protheus x RM Classis Net (RM) - Folha de Pagto.ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GPM810Proc()

Processa( { |lEnd| GPM810Exec() }, STR0047 ) //"Processando..."

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGPM810SRO บAutor  ณAlberto Deviciente  บ Data ณ 30/Dez/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInclui ou altera registro na tabela SRO                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ Integracao Protheus x RM Classis Net (RM) - Folha de Pagto.ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GPM810SRO(cMatPrf,cTarefa,cCCusto,cItemCTB,cClassVL,cDtIni,cDtFim,cTipoTar,nQtdSemanas,nQtdHoras,nVlrTarefa,nVlrTot,cVerba,nAulaSem)
Local cQuery 	:= ""
Local cTipo	 	:= "2" //1=Fixa; 2=Variavel

dbSelectArea("SRO")

//Verifica se ja existe o registro incluso na tabela SRO
cQuery := "select R_E_C_N_O_ RECSRO "
cQuery += "  from "+RetSQLName("SRO")
cQuery += " where RO_FILIAL	 = '"+xFilial("SRO")+"'"
cQuery += "   and RO_MAT	 = '"+cMatPrf+"'"
cQuery += "   and RO_DATA between '"+cDtIni+"' and '"+cDtIni+"'"
cQuery += "   and RO_CODTAR	 = '"+cTarefa+"'"
cQuery += "   and RO_CC	 = '"+cCCusto+"'"
cQuery += "   and D_E_L_E_T_ = ' '"
cQuery := ChangeQuery( cQuery )
dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), "QRYSR", .F., .F. )

if QRYSR->( EoF() ) //Nao encontrou, entao inclui
	RecLock("SRO", .T.)
	SRO->RO_FILIAL	:= xFilial("SRO")
	SRO->RO_MAT		:= cMatPrf
	SRO->RO_TIPO	:= cTipo
	SRO->RO_DATA	:= sToD(cDtIni)
	SRO->RO_DATAATE	:= sToD(cDtFim)
	SRO->RO_CODTAR	:= cTarefa
	SRO->RO_QTDSEM	:= nQtdSemanas
	SRO->RO_QUANT	:= nQtdHoras
	SRO->RO_VALOR	:= nVlrTarefa
	SRO->RO_VALTOT	:= nVlrTot
	SRO->RO_CC		:= cCCusto
	SRO->RO_VERBA	:= cVerba
	SRO->RO_ITEMCTB	:= cItemCTB
	SRO->RO_CLASSVL := cClassVL

	//Grava a quantidade de aulas por semana.
	//Por enquanto esta coletando o valor atraves da Gp810GetAu pois RM nao esta gravando em TAR_AULASEMANA 
	If AllTrim(cTipoTar) == "H"
		If nAulaSem <= 0
			//Se na INT_TAREFA valor eh zero, entao busca na base da RM ### TEMPORARIAMENTE_SIGA3286
			nAulaSem := ClsGetAula(cMatPrf,cDtIni,cDtFim)
		EndIf
		SRO->RO_QTDSEM := nAulaSem
	EndIf
	
	SRO->( MsUnlock() )
Else //Atualiza registro existente
	SRO->( dbGoTo(QRYSR->RECSRO) )
	RecLock("SRO", .F.)
	SRO->RO_TIPO	:= cTipo
	SRO->RO_DATA	:= sToD(cDtIni)
	SRO->RO_DATAATE	:= sToD(cDtFim)
	SRO->RO_QTDSEM	:= nQtdSemanas
	SRO->RO_QUANT	:= nQtdHoras
	SRO->RO_VALOR	:= nVlrTarefa
	SRO->RO_VALTOT	:= nVlrTot
	SRO->RO_CC		:= cCCusto
	SRO->RO_VERBA	:= cVerba
	SRO->RO_ITEMCTB	:= cItemCTB
	SRO->RO_CLASSVL := cClassVL
	
	//Grava a quantidade de aulas por semana.
	//Por enquanto esta coletando o valor atraves da Gp810GetAu pois RM nao esta gravando em TAR_AULASEMANA 
	If AllTrim(cTipoTar) == "H"
		If nAulaSem <= 0
			//Se na INT_TAREFA valor eh zero, entao busca na base da RM ### TEMPORARIAMENTE_SIGA3286
			nAulaSem := ClsGetAula(cMatPrf,cDtIni,cDtFim)
		EndIf
		SRO->RO_QTDSEM := nAulaSem
	EndIf
	
	SRO->( MsUnlock() )
EndIf

QRYSR->( dbCloseArea() )

dbSelectArea("SRO")

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma ณGPM810AtINTบAutor  ณAlberto Deviciente  บ Data ณ 30/Dez/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtualiza tabela INT_TAREFA para Status "2=Processado"       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ Integracao Protheus x RM Classis Net (RM) - Folha de Pagto.ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GPM810AtINT(cTAR_ID)
Local cQuery 	:= ""

cQuery := "UPDATE INT_TAREFA SET TAR_STATUSIMPORT = '2', TAR_OBSIMPORT = ' '"
cQuery += " WHERE TAR_ID = "+cTAR_ID
if TCSQLExec( cQuery ) < 0
	MsgStop( STR0057 + STR0056 + TcSqlError()) //"Ocorreu erro ao tentar atualizar a tabela INT_TAREFA. "
Else
	TcSqlExec("commit") 
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma ณGPM810BkPn3บAutor  ณAlberto Deviciente  บ Data ณ 05/Jan/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Guarda o codigo da simulacao anterior.                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ Integracao Protheus x RM Classis Net (RM) - Folha de Pagto.ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GPM810BkPn3()
cCodSimAnt:=cCodSimula
cSitFunAnt:=cGetSitFun
cProcDeAnt:=cProcDe
cProcAtAnt:=cProcAt
Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGPM810BrowบAutor  ณAlberto Deviciente  บ Data ณ 29/Dez/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para preenchimento de Browse de Log de Inconsistenciaบฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ Integracao Protheus x RM Classis Net (RM) - Folha de Pagto.ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GPM810Brow()      
Local nInd := 0
Local cQuery := ""

aBrowse4 := {}

TcSqlExec('delete from INT_SR5INCOSNSIS') 
TcSqlExec("commit") 

for nInd:=1 to len(aInconsSR5)
	//Antes de inserir verifica se jah existe
	cQuery := "select count(*) QTD "
	cQuery += "  from INT_SR5INCOSNSIS "
	cQuery += " where ltrim(rtrim(R5I_OBSITEM)) = '"+ Replace(aInconsSR5[nInd],"'","") +"'"
	dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), "INTSR5", .F., .F. )
	
	if INTSR5->QTD == 0
		cQuery := " insert into INT_SR5INCOSNSIS "
		cQuery += " (R5I_OBSITEM, R5I_DATA, R5I_HORA) "
		cQuery += " VALUES('" + Replace(aInconsSR5[nInd],"'","") +"','"+dToS(Date())+"','"+Time()+"') "
		if TCSQLExec( cQuery ) < 0
			MsgStop(STR0058 + STR0056 +  TcSqlError())  //"Ocorreu erro ao tentar inserir registro na tabela INT_SR5INCOSNSIS."
		Else
			TcSqlExec("commit") 
		EndIf
	EndIf
	INTSR5->( dbCloseArea() )
next nInd

cQuery := "select R5I_OBSITEM from INT_SR5INCOSNSIS order by R5I_ID"
cQuery := ChangeQuery( cQuery )
dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), "R5I", .F., .F. )
R5I->( dbgotop() )
while R5I->( !EoF() ) 
	aAdd(aBrowse4 ,{ R5I->R5I_OBSITEM } )
	R5I->( dbskip() )	
end

if len(aBrowse4) == 0
	AAdd(aBrowse4 ,{Space(200)} )
	oSay1:LVISIBLECONTROL := .F.
	oBrowse4:LVISIBLECONTROL := .F.
	oWizard:OBACK:LVISIBLE := .F.
EndIf

aBrowse4 := aClone(aBrowse4)
oBrowse4:SetArray(aBrowse4)
oBrowse4:bLine := {||{ aBrowse4[oBrowse4:nAt,01] } }
oBrowse4:Refresh()
R5I->( dbclosearea() )

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณIntSxbAtivบAutor  ณAlberto Deviciente  บ Data ณ 11/Jan/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณSXB especifico para Integracao entre Protheus e RM          บฑฑ
ฑฑบ          ณ															  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ Integracao Protheus x RM Classis Net (RM) - Folha de Pagto.ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function IntSxbAtiv()

local oPesquisa
local oList13
local cFiltrAti    := Space(15)
local lNota
local oTOk
local oCancela
local nCont        := 0
local nRecno       := 0 
Local aCampoTRB    := {}
Local aCpoTRBRet    := {}
Local aHeader    := {}
Local lseek
Local i			   := 0		
local lMSSQL	   := "MSSQL"$Upper(TCGetDB())							//Variaveis para tratamento de Banco de dados
local nPosCol	   := 0

Local oTmpRetAtv	:= Nil
Local oTmpAti		:= Nil
	
private aCols      := {}

private nUsado     := 3
private oDlg
private oFiltrAti
private aColsTmp1  := {} 
private lFirstLoad := .f. 
private oGetFiltro 
private cGetFiltro := Space(30)
private oGet 
private cGetFilAnt := "" 
private nRecIncic  := 0 
private nRecnoFim  := 0    
private cValTop    := " "
private cLimit     := " "
private cTopWhere  := " " 
Private cIDAtiAnt	:= Space(15)


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define os campos do Arquivo de Trabalho    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aCampoTRB := {	{ "TRB_IDATI"	, "C",  15, 0 },;
				{ "TRB_CODATI"	, "C",  15, 0 },;
				{ "TRB_DESC"	, "C",  30, 0 } }

//Colunas da tela
aHeader := {	{ "TRB_IDATI"	,, "ID"		, "@!" },;
				{ "TRB_CODATI"	,, STR0060	, "@!" },; //"C๓digo"
				{ "TRB_DESC"	,, STR0061	, "@!" } } //"Descri็ใo"
				
if Select("TRBATI") > 0
	dbSelectArea("TRBATI")
	dbCloseArea()
EndIf

if Select("TRBRETATV") > 0
	dbSelectArea("TRBRETATV")
	dbCloseArea()
EndIf

aCpoTRBRet := {{ "TRB_RETID", "C",  15, 0 } }

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cria o Arquivo de Trabalho (TRBRETATV) apenas para armazenar o Retorno da cunsulta  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oTmpRetAtv := FwTemporaryTable():New("TRBRETATV")
oTmpRetAtv:SetFields( aCpoTRBRet )
oTmpRetAtv:Create() 


RecLock("TRBRETATV",.T.)
If cPaisLoc == "BRA"
	TRBRETATV->TRB_RETID := M->X59_CODATV
	cIDAtiAnt := M->X59_CODATV
Else
	TRBRETATV->TRB_RETID := M->CODATIVID
	cIDAtiAnt := M->CODATIVID
EndIf
TRBRETATV->( MsUnLock() )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cria o Arquivo de Trabalho (TRBATI) para armazenar as Atividades Existente na tabela INT_ATIVIDADE  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oTmpAti := FwTemporaryTable():New("TRBATI")
oTmpAti:SetFields( aCampoTRB )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cria Indice 1 do Arquivo de Trabalho  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oTmpAti:AddIndex( "I1", { "TRB_CODATI" } )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cria Indice 2 do Arquivo de Trabalho  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oTmpAti:AddIndex( "I2", { "TRB_DESC" } )


//Alimenta o TRBATI com as Atividades existentes na tabela INT_ATIVIDADE
cQuery := " select "
cQuery += "  cast(ATI_ID as varchar(15)) as ATI_ID,"
cQuery += "  cast(ATI_IDATIVIDADE as varchar(15)) as ATI_IDATIVIDADE,"
cQuery += "  ATI_DESCRICAO "
cQuery += "  from INT_ATIVIDADE "
cQuery += " where ATI_FILIAL in ( '00', '"+SM0->M0_CODFIL+"' ) " 
cQuery += " order by ATI_IDATIVIDADE " 
cQuery := ChangeQuery( cQuery )
dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), "QRYATI", .F., .F. )

while QRYATI->( !EoF() )
	RecLock("TRBATI", .T.)
	TRBATI->TRB_IDATI	:= QRYATI->ATI_ID
	TRBATI->TRB_CODATI	:= QRYATI->ATI_IDATIVIDADE
	TRBATI->TRB_DESC 	:= Upper(QRYATI->ATI_DESCRICAO)
	TRBATI->( MsUnLock() )
	QRYATI->( dbSkip() )
end
QRYATI->( dbCloseArea() )

TRBATI->( dbGoTop() )

oDlg := MSDIALOG():Create()
oDlg:cName := "oDlg"
oDlg:cCaption := STR0059 //"Consulta Integracao - Atividades"
oDlg:nLeft := 0
oDlg:nTop := 0
oDlg:nWidth := 555
oDlg:nHeight := 448
oDlg:lShowHint := .F.
oDlg:lCentered := .t.

oFiltrAti := TCOMBOBOX():Create(oDlg)
oFiltrAti:cName := "oFiltrAti"
oFiltrAti:nLeft := 11
oFiltrAti:nTop := 6
oFiltrAti:nWidth := 460
oFiltrAti:nHeight := 21
oFiltrAti:lShowHint := .F.
oFiltrAti:lReadOnly := .F.
oFiltrAti:Align := 0
oFiltrAti:cVariable := "cFiltrAti"
oFiltrAti:bSetGet := {|u| If(PCount()>0, cFiltrAti:=u, cFiltrAti) }
oFiltrAti:lVisibleControl := .T.
oFiltrAti:aItems := {STR0060,STR0061}//{"C๓digo","Descri็ใo"}
oFiltrAti:nAt := 1
oFiltrAti:bChange := {|| GPM810Pos1(aHeader,oTmpAti, oTmpRetAtv) }

oPesquisa := TBUTTON():Create(oDlg)
oPesquisa:cName := "oPesquisa"
oPesquisa:cCaption := STR0062 //"Pesquisar"
oPesquisa:nLeft := 476
oPesquisa:nTop := 4
oPesquisa:nWidth := 70
oPesquisa:nHeight := 22
oPesquisa:lShowHint := .F.
oPesquisa:lReadOnly := .F.
oPesquisa:Align := 0
oPesquisa:lVisibleControl := .T.
oPesquisa:bAction := {|| .t.,GPM810Pes1(Rtrim(cGetFiltro)) } 

oGetFiltro := TGET():Create(oDlg)
oGetFiltro:cName := "oGetFiltro"
oGetFiltro:nLeft := 11
oGetFiltro:nTop := 29
oGetFiltro:nWidth := 460
oGetFiltro:nHeight := 21
oGetFiltro:lShowHint := .F.
oGetFiltro:lReadOnly := .F.
oGetFiltro:Align := 0
oGetFiltro:lVisibleControl := .T.
oGetFiltro:lPassword := .F.
oGetFiltro:lHasButton := .F.
oGetFiltro:cVariable := "cGetFiltro"
oGetFiltro:bSetGet := {|u| If(PCount()>0,cGetFiltro:=u,cGetFiltro) }
oGetFiltro:Picture := "@!"

oTOk := TBUTTON():Create(oDlg)
oTOk:cName := "oTOk"
oTOk:cCaption := "OK"
oTOk:nLeft := 2
oTOk:nTop := 400
oTOk:nWidth := 65
oTOk:nHeight := 22
oTOk:lShowHint := .F.
oTOk:lReadOnly := .F.
oTOk:Align := 0
oTOk:lVisibleControl := .T.
oTOk:bAction := {|| GPM810RtAt("1",oTmpAti, oTmpRetAtv) }

oCancela := TBUTTON():Create(oDlg)
oCancela:cName := "oCancela"
oCancela:cCaption := STR0063 //"Cancelar"
oCancela:nLeft := oTOk:nLeft+oTOk:nWidth+2
oCancela:nTop := 400
oCancela:nWidth := 65
oCancela:nHeight := 22
oCancela:lShowHint := .F.
oCancela:lReadOnly := .F.
oCancela:Align := 0
oCancela:lVisibleControl := .T.
oCancela:bAction := {|| GPM810RtAt("2",oTmpAti, oTmpRetAtv) }

dbSelectArea("TRBATI")

oGet := MsSelect():New( "TRBATI", , , aHeader, , , { 035, 005, 185, 270 } ,,, oDlg )
oGet:oBrowse:BLDBLCLICK := {|| GPM810RtAt("3",oTmpAti, oTmpRetAtv) }
dbSelectArea("TRBATI")

oDlg:Activate()

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGPM810Pos1บAutor  ณAlberto Deviciente  บ Data ณ 11/Jan/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica posi็ใo relativa ao filtro das colunas conforme    บฑฑ
ฑฑบ          ณaltera็๕es no combo de filtros                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ Integracao Protheus x RM Classis Net (RM) - Folha de Pagto.ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿  
*/
Static Function GPM810Pos1(aHeader,oTmpAti, oTmpRetAtv) 

//Ordena o TRB de acordo com o filtro escolhido
dbSelectArea("TRBATI")
dbSetOrder(oFiltrAti:nAt)
TRBATI->( dbGoTop() )

//Destroi o objeto
MsFreeObj(oGet:oBrowse,.F.)
oGet := Nil

//Recria o objeto atualizado
oGet := MsSelect():New( "TRBATI", , , aHeader, , , { 035, 005, 185, 270 } ,,, oDlg )
oGet:oBrowse:BLDBLCLICK := {|| GPM810RtAt("3",oTmpAti, oTmpRetAtv) }
oGet:oBrowse:Refresh()
CursorArrow()
CursorArrow()
CursorArrow()

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGPM810Pes1บAutor  ณAlberto Deviciente  บ Data ณ 11/Jan/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFiltrando registros ap๓s filtro pelo campo Get              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ Integracao Protheus x RM Classis Net (RM) - Folha de Pagto.ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GPM810Pes1(cGet)
Local nRenoAnt := TRBATI->( Recno() )

If!TRBATI->( dbSeek(cGet) )
	MsgAlert(STR0064) //"Atividade nใo encontrada."
	TRBATI->( dbGoTo(nRenoAnt) )
EndIf

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGPM810RtAtบAutor  ณAlberto Deviciente  บ Data ณ 11/Jan/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna o ID da Atividade e fecha a tela de consulta.       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ Integracao Protheus x RM Classis Net (RM) - Folha de Pagto.ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GPM810RtAt(cOper,oTmpAti, oTmpRetAtv)

if cOper == "1" //OK
	RecLock("TRBRETATV",.F.)
	TRBRETATV->TRB_RETID := Padr(TRBATI->TRB_IDATI,15)
	TRBRETATV->( MsUnlock() )
ElseIf cOper == "2" //Cancelar
	RecLock("TRBRETATV",.F.)
	TRBRETATV->TRB_RETID := Padr(cIDAtiAnt,15)
	TRBRETATV->( MsUnlock() )
Else //Duplo Click
	RecLock("TRBRETATV",.F.)
	TRBRETATV->TRB_RETID := Padr(TRBATI->TRB_IDATI,15)
	TRBRETATV->( MsUnlock() )
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Apaga o Arquivo de Trabalho TRBATI e os Indices.                         ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
TRBATI->(dbCloseArea())

If oTmpAti <> Nil
	oTmpAti:Delete()
	oTmpAti := Nil
Endif

If oTmpRetAtv <> Nil
	oTmpRetAtv:Delete()
	oTmpRetAtv := Nil
Endif

oDlg:End() //Fecha janela da Consulta padrao

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ_IntVldAtiบAutor  ณAlberto Deviciente  บ Data ณ 12/Jan/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida se o ID da Atividade informado eh valido.           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ Integracao Protheus x RM Classis Net (RM) - Folha de Pagto.ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function _IntVldAti(cIdAtivi)
Local lRet 		:= .T.
Local cQuery 	:= ""

If TcCanOpen("INT_ATIVIDADE")
	If!empty(cIdAtivi)
		cQuery := "SELECT count(*) QTD "
		cQuery += "  FROM INT_ATIVIDADE"
		cQuery += " WHERE ATI_ID = "+AllTrim(cIdAtivi)
		cQuery := ChangeQuery( cQuery )
		dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), "_QRYATV", .F., .F. )
		
		if _QRYATV->QTD == 0
			lRet := .F.
			MsgAlert(STR0065) //"O ID da atividade informado nใo ้ vแlido."
		EndIf
		_QRYATV->( dbCloseArea() )
	EndIf
Else
	cMsgAlert := STR0003 + CHR(10)+CHR(10) //"A tabela INT_ATIVIDADE nใo foi encontrada na base de dados." 
	cMsgAlert += STR0004					//"A instala็ใo da Integra็ใo entre os sistemas Protheus x RM Classis Net nใo foi feita corretamente."
	MsgStop(cMsgAlert)
	lRet := .F.
	MsgAlert(STR0065) //"O ID da atividade informado nใo ้ vแlido."
EndIf
dbSelectArea("SRA")

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGPM810SitFบAutor  ณAlberto Deviciente  บ Data ณ 27/Ago/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Seleciona ou valida as Situacoes de Funcionario.           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ Integracao Protheus x RM Classis Net (RM) - Folha de Pagto.ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GPM810SitF(lValid)
Local xRet
Local cSitSX5 := ""
Local nInd
Local lEncont

dbSelectArea("SX5")

if lValid //Validacao
	lEncont := .T.
	if dbSeek(xFilial("SX5")+"31")
		while SX5->( !EoF() ) .and. SX5->X5_TABELA == "31"
			cSitSX5 += "|"+Left(SX5->X5_CHAVE,1)+"|"
			SX5->( dbSkip() )
		end
		for nInd:=1 to len(rtrim(cGetSitFun))
			if SubStr(cGetSitFun,nInd,1) <> "*" .and. !(SubStr(cGetSitFun,nInd,1) $ cSitSX5)
				MsgStop(STR0071+SubStr(cGetSitFun,nInd,1)+STR0072)
				lEncont := .F.
				exit
			EndIf
		next nInd
		
		If!lEncont
			//Chama a funcao padrao do SIGAGPE
			xRet := fSituacao() //Tela padrao para selecionar as Situacoes
		EndIf
	Else
		xRet := .T.
	EndIf
Else
	//Chama a funcao padrao do SIGAGPE
	xRet := fSituacao() //Tela padrao para selecionar as Situacoes
EndIf

Return xRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGPM810Sxb2บAutor  ณAlberto Deviciente  บ Data ณ 09/Dez/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ SXB especifico para Integracao entre Protheus e RM.        บฑฑ
ฑฑบ          ณ Exibe os Tipos de Cursos do RM Classis Net (RM).           บฑฑ
ฑฑบ          ณ															  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ Integracao Protheus x RM Classis Net (RM) - Folha de Pagto.ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GPM810Sxb2()
Local oPesquisa    	
Local cFilTipCur    := Space(2)
Local oTOk         	
Local oCancela     	
Local aCampoTRB    	:= {}
Local aCpoTRBRet   	:= {}
Local aHeader    	:= {}
Local i			   	:= 0
Local nDBProtheus, nDBRMClass
Local lTopOk

Local oTmpRetCxt := Nil
Local oTmpRm1	 := Nil

Private oDlgRM1
Private oFilTipCur
Private oGetFiltro 
Private cGetFiltro := Space(30)
Private oGet 
Private cTipCurso  := Space(2)

//Busca conexao com as bases de dados (Protheus e RM)
lTopOk := _IntRMTpCon(@nDBProtheus,@nDBRMClass)

If!lTopOk
	Return .F.
EndIf

// Alterna o TOP para a Base do RM Classis Net (RM)
TCSetConn( nDBRMClass )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define os campos do Arquivo de Trabalho    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aCampoTRB := {	{ "TRB_TIPCUR"	, "C",  2, 0 },;
				{ "TRB_DESC"	, "C",  60, 0 } }

//Colunas da tela
aHeader := {	{ "TRB_TIPCUR"	,, STR0060	, "99" },; //"C๓digo"
				{ "TRB_DESC"	,, STR0061	, "@!" } } //"Descri็ใo"
				
if Select("TRBRM1") > 0
	dbSelectArea("TRBRM1")
	dbCloseArea()
EndIf

if Select("TRBRETCXT") > 0
	dbSelectArea("TRBRETCXT")
	dbCloseArea()
EndIf

aCpoTRBRet := {{ "TRB_RET", "C",  2, 0 } }

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cria o Arquivo de Trabalho (TRBRETCXT) apenas para armazenar o Retorno da cunsulta  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oTmpRetCxt := FwTemporaryTable():New("TRBRETCXT")
oTmpRetCxt:SetFields( aCpoTRBRet )
oTmpRetCxt:Create()

RecLock("TRBRETCXT",.T.)
If cPaisLoc == "BRA"
	TRBRETCXT->TRB_RET := M->X59_CONTEX
	cTipCurso := M->X59_CONTEX
Else
	TRBRETCXT->TRB_RET := M->CONTEXT
	cTipCurso := M->CONTEXT
EndIf
TRBRETCXT->( MsUnLock() )


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cria o Arquivo de Trabalho (TRBRM1) para armazenar os Tipos de Cursos Existentes na tabela STIPOCURSO da Base do RMณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oTmpRm1 := FwTemporaryTable():New("TRBRM1")
oTmpRm1:SetFields( aCampoTRB )
oTmpRm1:Create()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cria Indice 1 do Arquivo de Trabalho  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oTmpRm1:AddIndex( "I1", { "TRB_TIPCUR" } )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cria Indice 2 do Arquivo de Trabalho  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oTmpRm1:AddIndex( "I2", { "TRB_DESC" } )


//Alimenta o TRBRM1 com os Tipos de Cursos existentes na tabela STIPOCURSO da base do RM
cQuery := " select CODTIPOCURSO CODTIPCUR, NOME"
cQuery += "  from STIPOCURSO "
cQuery += " where CODCOLIGADA = "+AllTrim(str(val(SM0->M0_CODIGO)))
cQuery += " order by CODTIPOCURSO " 
cQuery := ChangeQuery( cQuery )
dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), "QRYRM1", .F., .F. )

while QRYRM1->( !EoF() )
	RecLock("TRBRM1", .T.)
	TRBRM1->TRB_TIPCUR	:= cValToChar(QRYRM1->CODTIPCUR)
	TRBRM1->TRB_DESC 	:= Upper(QRYRM1->NOME)
	TRBRM1->( MsUnLock() )
	QRYRM1->( dbSkip() )
end
QRYRM1->( dbCloseArea() )

TRBRM1->( dbGoTop() )

oDlgRM1 := MSDIALOG():Create()
oDlgRM1:cName := "oDlgRM1"
oDlgRM1:cCaption := STR0073 //"Consulta Integra็ใo - Tipo de Curso"
oDlgRM1:nLeft := 0
oDlgRM1:nTop := 0
oDlgRM1:nWidth := 555
oDlgRM1:nHeight := 448
oDlgRM1:lShowHint := .F.
oDlgRM1:lCentered := .t.

oFilTipCur := TCOMBOBOX():Create(oDlgRM1)
oFilTipCur:cName := "oFilTipCur"
oFilTipCur:nLeft := 11
oFilTipCur:nTop := 6
oFilTipCur:nWidth := 460
oFilTipCur:nHeight := 21
oFilTipCur:lShowHint := .F.
oFilTipCur:lReadOnly := .F.
oFilTipCur:Align := 0
oFilTipCur:cVariable := "cFilTipCur"
oFilTipCur:bSetGet := {|u| If(PCount()>0, cFilTipCur:=u, cFilTipCur) }
oFilTipCur:lVisibleControl := .T.
oFilTipCur:aItems := {STR0060,STR0061}//{"C๓digo","Descri็ใo"}
oFilTipCur:nAt := 1
oFilTipCur:bChange := {|| GPM810Pos2(aHeader, oTmpRetCxt, oTmpRm1) }

oPesquisa := TBUTTON():Create(oDlgRM1)
oPesquisa:cName := "oPesquisa"
oPesquisa:cCaption := STR0062 //"Pesquisar"
oPesquisa:nLeft := 476
oPesquisa:nTop := 4
oPesquisa:nWidth := 70
oPesquisa:nHeight := 22
oPesquisa:lShowHint := .F.
oPesquisa:lReadOnly := .F.
oPesquisa:Align := 0
oPesquisa:lVisibleControl := .T.
oPesquisa:bAction := {|| .t.,GPM810Pes2(Rtrim(cGetFiltro)) } 

oGetFiltro := TGET():Create(oDlgRM1)
oGetFiltro:cName := "oGetFiltro"
oGetFiltro:nLeft := 11
oGetFiltro:nTop := 29
oGetFiltro:nWidth := 460
oGetFiltro:nHeight := 21
oGetFiltro:lShowHint := .F.
oGetFiltro:lReadOnly := .F.
oGetFiltro:Align := 0
oGetFiltro:lVisibleControl := .T.
oGetFiltro:lPassword := .F.
oGetFiltro:lHasButton := .F.
oGetFiltro:cVariable := "cGetFiltro"
oGetFiltro:bSetGet := {|u| If(PCount()>0,cGetFiltro:=u,cGetFiltro) }
oGetFiltro:Picture := "@!"

oTOk := TBUTTON():Create(oDlgRM1)
oTOk:cName := "oTOk"
oTOk:cCaption := "OK"
oTOk:nLeft := 2
oTOk:nTop := 400
oTOk:nWidth := 65
oTOk:nHeight := 22
oTOk:lShowHint := .F.
oTOk:lReadOnly := .F.
oTOk:Align := 0
oTOk:lVisibleControl := .T.
oTOk:bAction := {|| GPM810RtTC("1",oTmpRetCxt, oTmpRm1) }

oCancela := TBUTTON():Create(oDlgRM1)
oCancela:cName := "oCancela"
oCancela:cCaption := STR0063 //"Cancelar"
oCancela:nLeft := oTOk:nLeft+oTOk:nWidth+2
oCancela:nTop := 400
oCancela:nWidth := 65
oCancela:nHeight := 22
oCancela:lShowHint := .F.
oCancela:lReadOnly := .F.
oCancela:Align := 0
oCancela:lVisibleControl := .T.
oCancela:bAction := {|| GPM810RtTC("2",oTmpRetCxt, oTmpRm1) }

dbSelectArea("TRBRM1")

oGet := MsSelect():New( "TRBRM1", , , aHeader, , , { 035, 005, 185, 270 } ,,, oDlgRM1 )
oGet:oBrowse:BLDBLCLICK := {|| GPM810RtTC("3",oTmpRetCxt, oTmpRm1) }
dbSelectArea("TRBRM1")

oDlgRM1:Activate()

if lTopOk
	TCUNLINK(nDBRMClass) // Finaliza a conexao do TOP com o ambiente RM Classis Net (RM)
EndIf

// Alterna o TOP para a Base do Protheus
TCSetConn( nDBProtheus )

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGPM810Pos2บAutor  ณAlberto Deviciente  บ Data ณ 09/Dez/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica posi็ใo relativa ao filtro das colunas conforme    บฑฑ
ฑฑบ          ณaltera็๕es no combo de filtros                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ Integracao Protheus x RM Classis Net (RM) - Folha de Pagto.ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿  
*/
Static Function GPM810Pos2(aHeader,oTmpRetCxt, oTmpRm1) 

//Ordena o TRB de acordo com o filtro escolhido
dbSelectArea("TRBRM1")
dbSetOrder(oFilTipCur:nAt)
TRBRM1->( dbGoTop() )

//Destroi o objeto
MsFreeObj(oGet:oBrowse,.F.)
oGet := Nil

//Recria o objeto atualizado
oGet := MsSelect():New( "TRBRM1", , , aHeader, , , { 035, 005, 185, 270 } ,,, oDlgRM1 )
oGet:oBrowse:BLDBLCLICK := {|| GPM810RtTC("3",oTmpRetCxt, oTmpRm1) }
oGet:oBrowse:Refresh()
CursorArrow()
CursorArrow()
CursorArrow()

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGPM810Pes2บAutor  ณAlberto Deviciente  บ Data ณ 09/Dez/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFiltrando registros ap๓s filtro pelo campo Get              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ Integracao Protheus x RM Classis Net (RM) - Folha de Pagto.ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GPM810Pes2(cGet)
Local nRecnoAnt := TRBRM1->( Recno() )

If!TRBRM1->( dbSeek(cGet) )
	MsgAlert(STR0074) //"Tipo de Curso nใo encontrado."
	TRBRM1->( dbGoTo(nRecnoAnt) )
EndIf

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGPM810RtTCบAutor  ณAlberto Deviciente  บ Data ณ 09/Dez/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna o Tipo de Curso e fecha a tela de consulta.         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ Integracao Protheus x RM Classis Net (RM) - Folha de Pagto.ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GPM810RtTC(cOper,oTmpRetCxt, oTmpRm1)

if cOper == "1" //OK
	RecLock("TRBRETCXT",.F.)
	TRBRETCXT->TRB_RET := TRBRM1->TRB_TIPCUR
	TRBRETCXT->( MsUnlock() )
ElseIf cOper == "2" //Cancelar
	RecLock("TRBRETCXT",.F.)
	TRBRETCXT->TRB_RET := cTipCurso
	TRBRETCXT->( MsUnlock() )
Else //Duplo Click
	RecLock("TRBRETCXT",.F.)
	TRBRETCXT->TRB_RET := TRBRM1->TRB_TIPCUR
	TRBRETCXT->( MsUnlock() )
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Apaga o Arquivo de Trabalho TRBRM1 e os Indices.                         ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
TRBRM1->(dbCloseArea())

If oTmpRetCxt <> Nil
	oTmpRetCxt:Delete()
	oTmpRetCxt := Nil
Endif

If oTmpRm1 <> Nil
	oTmpRm1:Delete()
	oTmpRm1 := Nil
Endif

oDlgRM1:End() //Fecha janela da Consulta padrao

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGPM810VldCบAutor  ณAlberto Deviciente  บ Data ณ 09/Dez/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida se o Tipo de Curso informado eh valido.             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ Integracao Protheus x RM Classis Net (RM) - Folha de Pagto.ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GPM810VldC(cTpCur)
Local lRet 			:= .T.
Local cQuery 		:= ""
Local nDBProtheus, nDBRMClass
Local lTopOk

If!empty(cTpCur)
	
	if SubStr(cTpCur,1,1) == "0" //Nao permite que o primeiro digito seja "0" (zero)
		MsgAlert(STR0075) //"O Tipo de Curso informado nใo ้ vแlido."
		Return .F.
	EndIf
	
	//Busca conexao com as bases de dados (Protheus e RM)
	lTopOk := _IntRMTpCon(@nDBProtheus,@nDBRMClass)
	
	If!lTopOk
		Return .F.
	EndIf
	
	// Alterna o TOP para a Base do RM Classis Net (RM)
	TCSetConn( nDBRMClass )
	
	cQuery := "SELECT count(*) QTD "
	cQuery += "  FROM STIPOCURSO"
	cQuery += " WHERE CODCOLIGADA = "+AllTrim(str(val(SM0->M0_CODIGO)))
	cQuery += "   AND CODTIPOCURSO = "+AllTrim(cTpCur)
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), "_QRYTIPCUR", .F., .F. )
	
	if _QRYTIPCUR->QTD == 0
		lRet := .F.
		MsgAlert(STR0075) //"O Tipo de Curso informado nใo ้ vแlido."
	EndIf
	_QRYTIPCUR->( dbCloseArea() )
	
	if lTopOk
		TCUNLINK(nDBRMClass) // Finaliza a conexao do TOP com o ambiente RM Classis Net (RM)
		
		// Alterna o TOP para a Base do Protheus
		TCSetConn( nDBProtheus )
	EndIf
	
EndIf

dbSelectArea("SRA")

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGPM810CmpoบAutor  ณAlberto Deviciente  บ Data ณ 10/Dez/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se existe o campo na base de dados para as tabelasบฑฑ
ฑฑบ          ณ de integracao.                                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ Integracao Protheus x RM Classis Net (RM) - Folha de Pagto.ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GPM810Cmpo(cTabela, cCampo)
Local aArea := GetArea()
Local lRet := .F.
Local cQuery := ""

if lOracle
	cQuery := " SELECT COUNT(*) QTD FROM ALL_TAB_COLUMNS "
	cQuery += "  WHERE TABLE_NAME = '"+cTabela+"' AND COLUMN_NAME = '"+cCampo+"'"
ElseIf lDB2
	cQuery := "SELECT COUNT(*) QTD FROM SYSCAT.COLUMNS campos, SYSCAT.TABLES tabelas "
	cQuery += " WHERE campos.COLNAME = '"+cCampo+"' AND tabelas.TABNAME = '"+cTabela+"' "
ElseIf lMySQL
	cQuery := " SELECT COUNT(*) QTD FROM INFORMATION_SCHEMA.COLUMNS "
	cQuery += "  WHERE TABLE_NAME = '"+cTabela+"' AND COLUMN_NAME = '"+cCampo+"'"
Else //Sql Server
	cQuery := "SELECT COUNT(*) QTD FROM dbo.syscolumns campos, dbo.sysobjects tabelas "
	cQuery += " WHERE campos.name = '"+cCampo+"' AND tabelas.name = '"+cTabela+"' "
	cQuery += " AND campos.id = tabelas.id "
EndIf

dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), "_INTCAMPO", .F., .F.)

if _INTCAMPO->QTD > 0
	lRet := .T.
EndIf

_INTCAMPO->( dbCloseArea() )

RestArea(aArea)

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGPM810ExecบAutor  ณLeandro Drumond     บ Data ณ 12/11/14    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExecuta o processamento da integracao                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ Integracao Protheus x RM Classis Net (RM) - Folha de Pagto.ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function GPM810Exec()
Local aPerAberto	:= {}
Local cQuery  		:= ""
Local cChaveTar		:= ""   
Local nQtdDias		:= 0
Local nVlrTot		:= 0
Local nValor		:= 0
Local nMVSeman 		:= GetNewPar('MV_ACSEMAN', 4.5) //Para calculo exclusivo da Folha de Pagamento
Local lOk 			:= .T.
Local nCount 		:= 0
Local cCountTot		:= ""
Local nCountReg		:= 0
Local cINProfs 		:= ""
Local cMsgSR5 		:= ""
Local nFator		:= 0
Local cTitulacao   	:= ""
Local lPerOk		:= .F.
Local cRoteiro		:= ""
Local cLastPer 		:= ""
Local cLastNroPagto := ""
Local cLastAnoMes   := ""
Local cTitula		:= ""
Local cDiasMes		:= GetMv( "MV_DIASMES" )
Local nDiasMes		:= 0
Local nLinS024		:= 0
Local aSeek			:= {}
Local cTipoRGB		:= ""
Local nHoras		:= 0
Local cVerba		:= ""
Local cTarefa		:= ""
Local nTamContext 	:= 0 //Tamanho do campo Contexto  na S024
Local nTamCodTit 	:= 0 //Tamanho do campo Titulacao na S024
Local nTamCodAtivid := 0 //Tamanho do campo Atividade na S024
Local nTamDescri 	:= 0 //Tamanho do campo Descricao na S024
Local nTamVerba  	:= 0 //Tamanho do campo Verba na S024
Local nTamTipFalta  := 0 //Tamanho do campo Tipo Falta na S024

Private cTabRCB		:= If(cPaisLoc=="MEX","S024","S071")

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAdiciona a matricula dos professores marcados numa string e retira a ultima virgulaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aEval( aBrowse, { |x| cINProfs += iif(x[1] .and. !(AllTrim(x[2]) $ cINProfs), "'"+AllTrim(x[2])+"',", "" ) } )
cINProfs := SubStr(cINProfs,1,len(cINProfs)-1)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณBusca os apontamentos da INT_TAREFA dos professores marcadosณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cQuery := "SELECT TAR_COLIGADA, TAR_FILIAL, TAR_CODPROF, TAR_TITULACAO, TAR_CCUSTO, TAR_FILIAL, "
cQuery += " TAR_AULASEMANA, TAR_QTDNOT, TAR_VALORFIXO, TAR_VALORHORA, TAR_QTDHORA, TAR_CODGRUPOATIV, TAR_IDATIVIDADE, "
cQuery += " TAR_TIPOFALTA, TAR_QTDFALTA, TAR_TIPOTAREFA, TAR_ID, TAR_ITEMCONTABIL, TAR_CLASSEVALOR, TAR_TIPOATV, "
If ClsVersion("TAR_CONTEXTO")
	cQuery += " TAR_CONTEXTO, "
EndIf
If lMSSQL                                                                      
	cQuery += " convert(varchar(8),TAR_DATAINI,112) TAR_DATAINI, "
	cQuery += " convert(varchar(8),TAR_DATAFIM,112) TAR_DATAFIM "
Else                                                                          
	cQuery += " to_char(TAR_DATAINI,'YYYYMMDD') TAR_DATAINI, "
	cQuery += " to_char(TAR_DATAFIM,'YYYYMMDD') TAR_DATAFIM "
EndIf
cQuery += "  FROM INT_TAREFA "
cQuery += " WHERE TAR_COLIGADA = " + AllTrim(str(val(SM0->M0_CODIGO)))
cQuery += "   AND TAR_FILIAL = '" + SM0->M0_CODFIL + "'"
cQuery += "   AND TAR_CODSIMULAC = '" + AllTrim(cCodSimula) + "'"   	//Somente do lote selecionado
cQuery += "   AND TAR_CODPROF in ("+cINProfs+")"						//Somente os professores marcados
cQuery += "   AND TAR_STATUSIMPORT IN ('1','3')" 						//Somente registros que ainda nao foram processados
cQuery += " ORDER BY TAR_CODPROF, TAR_TIPOTAREFA "
cQuery := ChangeQuery( cQuery )
iif(Select("PROFS")>0,PROFS->(dbCloseArea()),Nil)
dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), "PROFS", .F., .F. )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta a regua de processamentoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
PROFS->(dbEval({|| nCount++ }))
PROFS->(dbGoTop())
ProcRegua(nCount)
cCountTot := AllTrim(str(nCount))

dbSelectArea("SRA")
SRA->( dbSetOrder(1) ) 
aInconsSR5 := {}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณColeta os tamanhos dos campos da S024 na RCBณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cQuery := " SELECT RCB_CAMPOS NOME, RCB.RCB_TAMAN TAM FROM " + retsqlname('RCB') + " RCB "
cQuery += " WHERE RCB.RCB_FILIAL = '" + xFilial('RCB') + "'" 
cQuery += " 	AND RCB.RCB_CODIGO = '"+cTabRCB+"'" 
cQuery += " 	AND RCB.RCB_VERSAO = (SELECT MAX(RCB2.RCB_VERSAO) VERSAO FROM "
cQuery += 		  						retsqlname('RCB') + " RCB2 "
cQuery += " 							WHERE RCB2.RCB_FILIAL = RCB.RCB_FILIAL "
cQuery += " 								AND RCB2.RCB_CODIGO = RCB.RCB_CODIGO "
cQuery += " 								AND RCB2.RCB_CAMPOS = RCB.RCB_CAMPOS "
cQuery += " 								AND RCB2.D_E_L_E_T_ = ' ' )"
cQuery += " 	AND RCB.D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY RCB.RCB_ORDEM ASC "
iif(Select('TCQ')>0,TCQ->(dbCloseArea()),Nil)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TCQ", .F., .T.)
If TCQ->(!Eof())
	While TCQ->(!Eof())
		Do Case
			Case AllTrim(TCQ->NOME) == "CONTEXT"
				nTamContext := TCQ->TAM
			Case AllTrim(TCQ->NOME) == "CODTIT"
		        nTamCodTit := TCQ->TAM
		 	Case AllTrim(TCQ->NOME) == "CODATIVID"
		        nTamCodAtivid := TCQ->TAM		 	
		 	Case AllTrim(TCQ->NOME) == "TIPFALTA"
			    nTamTipFalta := TCQ->TAM		 	
		 	Case AllTrim(TCQ->NOME) == "DESCRI"
		        nTamDescri := TCQ->TAM
		 	Case AllTrim(TCQ->NOME) == "VERBA"	
		        nTamVerba := TCQ->TAM		 	
		EndCase	
		TCQ->(dbSkip())
	EndDo
Else
	cMsgSR5 := STR0078 //"Nใo existem registros validos na tabela S024 (GPE). Processo abortado"
	If aScan(aInconsSR5, cMsgSR5 ) == 0
		aAdd(aInconsSR5, cMsgSR5 )
	EndIf
	Return .T.
EndIf

                                                                                      
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณProcessa os professores encontradosณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If PROFS->( !EoF())
	While PROFS->(!EoF())
		
		//Posiciona na SRA
		SRA->(dbSeek(xFilial("SRA")+PROFS->TAR_CODPROF))
                
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณColeta o roteiro	Folha ou Autonomo ณ	
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู		
		cRoteiro := fGetCalcRot(If(SRA->RA_CATFUNC$"A*P" .and. cPaisLoc == "BRA","9","1"))
		
		If cChaveTar <> SRA->(RA_FILIAL + RA_MAT) + PROFS->TAR_DATAINI
			aPerAberto := {}
			fRetPerComp(SubStr(PROFS->TAR_DATAINI,5,2), SubStr(PROFS->TAR_DATAINI,1,4),, SRA->RA_PROCES,cRoteiro,@aPerAberto )
			cChaveTar := SRA->(RA_FILIAL + RA_MAT) + PROFS->TAR_DATAINI
		EndIf
           	    
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณObtem o prox periodo em abertoณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		lPerOk := !Empty(aPerAberto)
		
		If lPerOk
			cLastPer 		:= aPerAberto[1,1]
			cLastNroPagto 	:= aPerAberto[1,2]
			cLastAnoMes		:= aPerAberto[1,4] + aPerAberto[1,3]
			nQtdDias		:= aPerAberto[1,6] - aPerAberto[1,5]
			nDiasMes		:= If(cDiasMes=="S",nQtdDias,30) //Qtde. de dias a ser considerado no Mes Comercial
			
			If cPaisLoc == "BRA" .and. GetNewPar("MV_GPRMCME", .F.) //Descosidera o calculo do periodo processado (Data Inicial / Data Final). Neste caso Subentende-se que o periodo que sera processado sera sempre mensal (padrao 30 dias)
				//Considera o Fator (conforme parametro MV_ACSEMAN) a ser aplicado no Calculo de horas para o periodo padrao de 30 dias ao Mes
				nFator := nMVSeman
			Else
                
				If cPaisLoc == "MEX"
					nFator := Round(nQtdDias/7  ,2)
				Else
					nFator := (nMVSeman / nDiasMes) * nQtdDias
				EndIf
			EndIf
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณColeta qual o fator de multiplica็ใo de acordo com o tamanho do periodoณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู		
		
			//Busca a Titulacao do Professor		
			cTitulacao := SRA->RA_CODTIT
				
			If PROFS->TAR_TIPOTAREFA == "H" //Tratamento para AULA NORMAL
		   		//Posiciona na S024 - Chave eh Filial, Contexto, Titulacao, Tipo de Falta, Tipo de Atividade
		   	    aSeek := {}
		   	    aAdd(aSeek,{Gp810Conca(xFilial('RGB') ,2) ,"==",1	}) 					//Filial
		   	    aAdd(aSeek,{Gp810Conca(PROFS->TAR_CONTEXTO,nTamContext),"=="	,4	}) 	//Contexto (Tipo Curso)
		   	    aAdd(aSeek,{Gp810Conca(cTitulacao,nTamCodTit) ,"==" ,5 }) 				//Titulacao
		   	    aAdd(aSeek,{Gp810Conca(" ",nTamTipFalta) ,"=="	,6 	}) 					//Tipo de Falta
		   	    aAdd(aSeek,{Gp810Conca(" ",nTamCodAtivid),"=="	,7 	}) 					//Tipo de Atividade
		  	    nLinS024 := Gp810Seek(aSeek) 	 					   	    			//Busca na S024
	            
				If nLinS024 > 0
			        cVerba  	:= fTabela(cTabRCB,nLinS024,10)			//Coleta a verba
			        cTarefa		:= fTabela(cTabRCB,nLinS024,3)			//Tarefa
			      	cTitula   	:= AllTrim(PROFS->TAR_TITULACAO)	    //Coleta a titulacao
	       			cContexto 	:= AllTrim(PROFS->TAR_CONTEXTO)	       	//Coleta o contexto
					cCCusto 	:= AllTrim(PROFS->TAR_CCUSTO)			//Coleta o Centro de Custo
					cItemCTB 	:= AllTrim(PROFS->TAR_ITEMCONTABIL)		//Coleta Item Contabil
					cClassVL 	:= AllTrim(PROFS->TAR_CLASSEVALOR)		//Coleta Classe de Valor
					nHoras 		:= Round(PROFS->TAR_QTDHORA,2) * nFator
		    		  			
					//Verifica se eh Hora Aula ou Valor Fixo
					If PROFS->TAR_VALORFIXO > 0
				   		//Coleta o total de horas
				   		cTipoRGB := "V"
	
				   		//Coleta o valor total
				   		nVlrTot := PROFS->TAR_VALORFIXO
				   		
						//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
						//ณInclui ou altera registro na tabela RGB       ณ
						//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
						GPM810RGB(SRA->RA_MAT,cLastPer,"01",cRoteiro,cVerba,cTipoRGB,nHoras,cCCusto,cItemCTB,cClassVL,nVlrTot)
				   		
					Else
						//Coleta o valor Hora do Professor
						//O mesmo pode estar presente no RM ou no Protheus. Vide Documenta็ใo.
						If PROFS->TAR_VALORHORA > 0
							//Valor da RM
							nValor := PROFS->TAR_VALORHORA
						Else                                             
	                        //Valor do Protheus
	                        nValor := fTabela(cTabRCB,nLinS024,9)
					    EndIf
					    
						cTipoRGB := "H"
						
	    				//Coleta o valor total a pagar
	    				nVlrTot := Round(nValor * nHoras,2)
	    				
						If cPaisLoc == "BRA"
							GPM810SRO(AllTrim(PROFS->TAR_CODPROF),cTarefa,AllTrim(PROFS->TAR_CCUSTO),;
								AllTrim(PROFS->TAR_ITEMCONTABIL),AllTrim(PROFS->TAR_CLASSEVALOR),PROFS->TAR_DATAINI,PROFS->TAR_DATAFIM,;
								PROFS->TAR_TIPOTAREFA,0,nHoras,nValor,nVlrTot,cVerba,PROFS->TAR_AULASEMANA)
						Else
							GPM810RGB(SRA->RA_MAT,cLastPer,"01",cRoteiro,cVerba,cTipoRGB,nHoras,cCCusto,cItemCTB,cClassVL,nVlrTot)
						EndIf

					EndIf		
									
					lOk := .T.
				Else
					cMsgSR5 := STR0079 + cTitulacao +  STR0080 //"Nao foram encontrados registros do tipo de Valor Hora/Fixo para a titula็ใo: "  + xxx + " na tabela S024. Item desconsiderado"
					If aScan(aInconsSR5, cMsgSR5 ) == 0
						aAdd(aInconsSR5, cMsgSR5 )
					EndIf
					lOk := .F.
				EndIf
			ElseIf PROFS->TAR_TIPOTAREFA == "P" //Tratamento para ATIVIDADES EXTRAS
				//Busca a atividade na INT_ATIVIDADE
				cQuery := "SELECT ATI_ID ID "
				cQuery += "  FROM INT_ATIVIDADE "
				cQuery += " WHERE ATI_IDATIVIDADE = "+AllTrim(str(PROFS->TAR_IDATIVIDADE))
				//cQuery += "   AND ATI_TIPOATV = '"+PROFS->TAR_TIPOATV+"'"
				cQuery := ChangeQuery( cQuery )
				iif(Select('TCQ')>0,TCQ->(dbCloseArea()),Nil)
				dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), "TCQ", .F., .F. )
				
				If !Empty(TCQ->ID)       		   		
       		   		//Posiciona na S024 - Chave eh Filial, Contexto, Titulacao, Tipo de Falta, Tipo de Atividade
			   	    aSeek := {}
			   	    aAdd(aSeek,{Gp810Conca(xFilial('RGB') ,2) ,"==",1	}) 						//Filial
			   	    aAdd(aSeek,{Gp810Conca(PROFS->TAR_CONTEXTO,nTamContext),"=="	,4	}) 		//Contexto (Tipo Curso)
			   	    aAdd(aSeek,{Gp810Conca(cTitulacao,nTamCodTit) ,"==" ,5 }) 					//Titulacao
			   	    aAdd(aSeek,{Gp810Conca(" ",nTamTipFalta) ,"=="	,6 	}) 						//Tipo de Falta
			   	    aAdd(aSeek,{Gp810Conca(TCQ->ID,nTamCodAtivid),"=="	,7 	}) 					//Tipo de Atividade
			  	    nLinS024 := Gp810Seek(aSeek) 	 					   	    				//Busca na S024
		            
					If nLinS024 > 0
				        cVerba  	:= fTabela(cTabRCB,nLinS024,10)			//Coleta a verba
				        cTarefa		:= fTabela(cTabRCB,nLinS024,3)			//Tarefa
				      	cTitula   	:= AllTrim(PROFS->TAR_TITULACAO)		//Coleta a titulacao
		       			cContexto 	:= AllTrim(PROFS->TAR_CONTEXTO)		    //Coleta o contexto
						cCCusto 	:= AllTrim(PROFS->TAR_CCUSTO)			//Coleta o Centro de Custo
						cItemCTB 	:= AllTrim(PROFS->TAR_ITEMCONTABIL)		//Coleta Item Contabil
						cClassVL 	:= AllTrim(PROFS->TAR_CLASSEVALOR)		//Coleta Classe de Valor
	                    
		                //Verifica se eh Hora Aula ou Valor Fixo
						If PROFS->TAR_VALORFIXO > 0
					   		//Coleta o total de horas
					   		cTipoRGB := "V"
					   		nHoras 	 := 0
		
					   		//Coleta o valor total
					   		nVlrTot := PROFS->TAR_VALORFIXO
					   		
							//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
							//ณInclui ou altera registro na tabela RGB       ณ
							//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
							GPM810RGB(SRA->RA_MAT,cLastPer,"01",cRoteiro,cVerba,cTipoRGB,nHoras,cCCusto,cItemCTB,cClassVL,nVlrTot)
						Else
							//Coleta o valor Hora do Professor
							//O mesmo pode estar presente no RM ou no Protheus. Vide Documenta็ใo.
							If PROFS->TAR_VALORHORA > 0
								//Valor da RM
								nValor := PROFS->TAR_VALORHORA
							Else                                             
		                        //Valor do Protheus
		                        nValor := fTabela(cTabRCB,nLinS024,9)
						    EndIf
		    				//Coleta o total de horas
		    				nHoras := PROFS->TAR_QTDHORA
							cTipoRGB := "H"
							
		    				//Coleta o valor total a pagar
		    				nVlrTot := Round(nValor * nHoras,2)
		    				
		    				If cPaisLoc == "BRA"
								GPM810SRO(AllTrim(PROFS->TAR_CODPROF),cTarefa,AllTrim(PROFS->TAR_CCUSTO),;
															AllTrim(PROFS->TAR_ITEMCONTABIL),AllTrim(PROFS->TAR_CLASSEVALOR),PROFS->TAR_DATAINI,PROFS->TAR_DATAFIM,;
															PROFS->TAR_TIPOTAREFA,0,nHoras,nValor,nVlrTot,cVerba,PROFS->TAR_AULASEMANA)
							Else
								GPM810RGB(SRA->RA_MAT,cLastPer,"01",cRoteiro,cVerba,cTipoRGB,nHoras,cCCusto,cItemCTB,cClassVL,nVlrTot)
							EndIf
						EndIf		

						lOk := .T.
                  Else
   						cMsgSR5 := STR0081 + cTitulacao + STR0080 //"Nao foram encontrados registros do Tipo de Atividades para a titula็ใo: " + xxx + " na tabela S024. Item desconsiderado"
						If aScan(aInconsSR5, cMsgSR5 ) == 0
							aAdd(aInconsSR5, cMsgSR5 )
						EndIf
						lOk := .F.
                  EndIf
                Else
               		cMsgSR5 := STR0082  + AllTrim(str(PROFS->TAR_IDATIVIDADE)) + STR0083 //"A Atividade: " + xxx + " nใo foi encontrada na INT_ATIVIDADE. Registro Ignorado "
					If aScan(aInconsSR5, cMsgSR5 ) == 0
						aAdd(aInconsSR5, cMsgSR5 )
					EndIf
                EndIf 
					
			ElseIf PROFS->TAR_TIPOTAREFA == "F" //Tratamento para FALTAS
		      	
		      	//Posiciona na S024 - Chave eh Filial, Contexto, Titulacao, Tipo de Falta, Tipo de Atividade
		   	    aSeek := {}
		   	    aAdd(aSeek,{Gp810Conca(xFilial('RGB') ,2) ,"==",1	}) 					//Filial
		   	    aAdd(aSeek,{Gp810Conca(PROFS->TAR_CONTEXTO,nTamContext),"=="	,4	}) 	//Contexto (Tipo Curso)
		   	    aAdd(aSeek,{Gp810Conca(cTitulacao,nTamCodTit) ,"==" ,5 }) 				//Titulacao
		   	    aAdd(aSeek,{Gp810Conca(PROFS->TAR_TIPOFALTA,nTamTipFalta) ,"==",6 	}) 	//Tipo de Falta
		   	    aAdd(aSeek,{Gp810Conca(" ",nTamCodAtivid),"=="	,7 	}) 					//Tipo de Atividade
		  	    nLinS024 := Gp810Seek(aSeek) 	 					   	    			//Busca na S024
	            
				If nLinS024 > 0
			        cVerba  	:= fTabela(cTabRCB,nLinS024,10)			//Coleta a verba
			        cTarefa		:= fTabela(cTabRCB,nLinS024,3)			//Tarefa
			      	cTitula   	:= AllTrim(PROFS->TAR_TITULACAO)		//Coleta a titulacao
	       			cContexto 	:= AllTrim(PROFS->TAR_CONTEXTO)	       	//Coleta o contexto
					cCCusto 	:= AllTrim(PROFS->TAR_CCUSTO)			//Coleta o Centro de Custo
					cItemCTB 	:= AllTrim(PROFS->TAR_ITEMCONTABIL)		//Coleta Item Contabil
					cClassVL 	:= AllTrim(PROFS->TAR_CLASSEVALOR)		//Coleta Classe de Valor
                     
	                //Verifica se eh Hora Aula ou Valor Fixo
					If PROFS->TAR_VALORFIXO > 0
				   		//Coleta o total de horas
				   		cTipoRGB := "V"
				   		nHoras 	 := 0
	
				   		//Coleta o valor total
				   		nVlrTot := Round(PROFS->TAR_VALORFIXO * PROFS->TAR_QTDFALTA,2)
				   		
						//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
						//ณInclui ou altera registro na tabela RGB       ณ
						//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
						GPM810RGB(SRA->RA_MAT,cLastPer,"01",cRoteiro,cVerba,cTipoRGB,0,cCCusto,cItemCTB,cClassVL,nVlrTot)
					Else
						//Coleta o valor Hora do Professor
						//O mesmo pode estar presente no RM ou no Protheus. Vide Documenta็ใo.
						If PROFS->TAR_VALORHORA > 0
							//Valor da RM
							nValor := PROFS->TAR_VALORHORA
						Else                                             
	                        //Valor do Protheus
	                        nValor := fTabela(cTabRCB,nLinS024,9)
					    EndIf
						cTipoRGB := "V"
						
	    				//Coleta o valor total a pagar
	    				nVlrTot := Round(nValor * PROFS->TAR_QTDFALTA,2)
	    				
	    				If cPaisLoc == "BRA"
							GPM810SRO(AllTrim(PROFS->TAR_CODPROF),cTarefa,AllTrim(PROFS->TAR_CCUSTO),;
								AllTrim(PROFS->TAR_ITEMCONTABIL),AllTrim(PROFS->TAR_CLASSEVALOR),PROFS->TAR_DATAINI,PROFS->TAR_DATAFIM,;
								PROFS->TAR_TIPOTAREFA,0,Round(PROFS->TAR_QTDFALTA,2),nValor,nVlrTot,cVerba,PROFS->TAR_AULASEMANA)	
						Else
							GPM810RGB(SRA->RA_MAT,cLastPer,"01",cRoteiro,cVerba,cTipoRGB,0,cCCusto,cItemCTB,cClassVL,nVlrTot)
						EndIf
					EndIf		
						
					lOk := .T.
				Else
					cMsgSR5 := STR0084  + cTitulacao + STR0080 //"Nao foram encontrados registros do Tipo de Faltas para a titula็ใo: " + xxx + " na tabela S024. Item desconsiderado"
					If aScan(aInconsSR5, cMsgSR5 ) == 0
						aAdd(aInconsSR5, cMsgSR5 )
					EndIf
					lOk := .F.
				EndIf				
			Else
				cMsgSR5 := STR0054 + PROFS->TAR_TIPOTAREFA + ")"
				If aScan(aInconsSR5, cMsgSR5 ) == 0
					aAdd(aInconsSR5, cMsgSR5 )
				EndIf
				lOk := .F.
			EndIf
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณAtualiza a tabela INT_TAREFA com TAR_STATUSIMPORT -> "2=Processado"ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู			
			if lOk 
				GPM810AtINT(AllTrim(Str(PROFS->TAR_ID)))
			EndIf	
		Else
			cMsgSR5 := STR0085 + AllTrim(SRA->RA_MAT) + STR0086 //"Nao encontrou o periodo em aberto para a Matricula: " + xxx + ". Item desconsiderado"
			if aScan(aInconsSR5, cMsgSR5 ) == 0
				aAdd(aInconsSR5, cMsgSR5 )
			EndIf
		EndIf
		
		//Proximo registro
		PROFS->( dbSkip())
		IncProc(STR0049 +AllTrim(str(nCountReg))+STR0050+cCountTot)
		lOk := .F.
	 EndDo
	 PROFS->(dbCloseArea())
Else
	MsgStop(STR0055) //"Nenhum registro foi encontrado para processamento na tabela INT_TAREFA."
EndIf

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGPM810RGB บAutor  ณCesar A. Bianchi    บ Data ณ 11/06/2010  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInclui ou altera registro na tabela RGB                     บฑฑ
ฑฑบ          ณ (Valor periodo Mexico)                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ Integracao Protheus x RM Classis Net (RM) - Folha de Pagto.ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function GPM810RGB(cMatPrf,cPeriodo,cSemana,cRoteiro,cVerba,cTipo,nHoras,cCCusto,cItemCTB,cClassVL,nValor)
Local aArea := getArea()
Local cQuery := ""

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณColeta qual o proximo ID disponivelณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cQuery := " SELECT MAX(RGB.RGB_SEQ) SEQ FROM " + retsqlname('RGB') + " RGB "
cQuery += " WHERE RGB.RGB_FILIAL = '" + xFilial('RGB') + "'"
cQuery += " 	AND RGB.RGB_PROCES = '" + Posicione('SRA',1,xFilial('SRA')+cMatPrf,'RA_PROCES') + "'"
cQuery += "		AND RGB.RGB_PERIOD = '" + cPeriodo + "'"
cQuery += " 	AND RGB.RGB_SEMANA = '" + cSemana + "'"
cQuery += "		AND RGB.RGB_ROTEIR = '" + cRoteiro + "'"
cQuery += " 	AND RGB.RGB_MAT = '" + cMatPrf + "'"
cQuery += " 	AND RGB.D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery)
iif(Select('TCQ')>0,TCQ->(dbCloseArea()),Nil)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TCQ", .F., .T.)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณGrava na RGBณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤู
RecLock("RGB",.T.)
RGB->RGB_FILIAL		:= xFilial("RGB")
RGB->RGB_PROCES		:= AllTrim(Posicione('SRA',1,xFilial('SRA')+cMatPrf,'RA_PROCES'))
RGB->RGB_PERIOD   	:= cPeriodo
RGB->RGB_SEMANA  	:= cSemana
RGB->RGB_ROTEIR    	:= cRoteiro
RGB->RGB_MAT       	:= cMatPrf
RGB->RGB_PD        	:= cVerba
RGB->RGB_TIPO1     	:= cTipo
RGB->RGB_HORAS     	:= nHoras
RGB->RGB_VALOR     	:= nValor
RGB->RGB_DTREF     	:= Date()
RGB->RGB_CC        	:= cCCusto
RGB->RGB_ITEM      	:= cItemCTB
RGB->RGB_CLVL      	:= cClassVL
RGB->RGB_PARCEL    	:= 1
RGB->RGB_TIPO2     	:= "C"
RGB->RGB_SEQ       	:= Soma1(TCQ->SEQ)
RGB->RGB_CODFUN    	:= Posicione('SRA',1,xFilial('SRA')+cMatPrf,'RA_CODFUNC')
RGB->RGB_POSTO		:= Posicione('SRA',1,xFilial('SRA')+cMatPrf,'RA_POSTO')
RGB->RGB_DEPTO		:= Posicione('SRA',1,xFilial('SRA')+cMatPrf,'RA_DEPTO')
RGB->(MsUnlock())
TCQ->(dbCloseArea())
			
RestArea(aArea)
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGP810Seek บAutor  ณCesar A. Bianchi    บ Data ณ  15/06/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRealiza consecutivas execucoes da funcao fPosTab, ate localiบฑฑ
ฑฑบ          ณzar o registro informado atraves da chave passada como paramบฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Uso      ณ Integracao Protheus x RM Classis Net (RM) - Folha de Pagto.บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function Gp810Seek(aSeek)
Local nLin 		:= 0
Local nX		:= 0
Local cValor	:= ""
Local cOper 	:= ""
Local nCol		:= 0
Local nLastLine := 0

For nX := 1 to len(aSeek)
	cValor 	:= aSeek[nX,1]
	cOper	:= aSeek[nX,2]
	nCol	:= aSeek[nX,3]
	
	nLin := fPosTab(cTabRCB,cValor,cOper,nCol,/*cValor2*/,/*cOper2*/,/*nCol2*/,/*nColRet*/,nLastLine)
	nLastLine := iif(nLin > 0,nLin,nLastLine)
Next nX


Return nLin

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGp810ConcaบAutor  ณCesar A. Bianchi	 บ Data ณ  15/06/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRealiza a concatenacao de espacos em branco uma string de   บฑฑ
ฑฑบ          ณacordo com seu tamanho passado como parametro.              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Uso      ณ Integracao Protheus x RM Classis Net (RM) - Folha de Pagto.บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function Gp810Conca(cString,nTam)
Local cRet := ""

//Converte parametro para numerico caso seja string
If ValType(cString) == 'N'
	cString := AllTrim(str(cString))
EndIf

cString := AllTrim(cString)
cRet := cString + Replicate(" ",nTam-len(cString))
Return cRet
