#Include "totvs.ch"
#include "protheus.ch"
#Include "fwmvcdef.ch"
#INCLUDE 'OGA200A.CH'

Static oArqTemp := Nil

/** {Protheus.doc} OGA200A
Função para avaliação de reservas

@param: 	Nil
@author: 	Bruna Rocio
@since: 	07/11/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/

Function OGA200A()
	Local   aCampos    	:= {}
	Local   cDesTRes   	:= ""
	local	cNome      	:= ""
	Local   cNomLJ     	:= ""
	Local   cDesPro    	:= ""
	Local   aNewButton 	:= {}

	Private cTGet1 		:= ""

	Private cAliMKB
	Private aMKB     	:= {}
	Private cMarca   	:= GetMark()
	Private nQtdRom  	:= 0
	Private nQtdRes  	:= 0

	Private cObs     	:= Space( TamSX3( "NJB_OBSLIB" )[1] )
	Private nQtde    	:= 0
	Private nQtdCred 	:= 0
	Private cPergunta	:= "OGA200A"

	SetPrvt("oDlg1","oSay1","oSay2","oSay3","oSay4","oSay5","oSay6","oSay7","oSay8","oSay9","oSay10")
	SetPrvt("oGet2","oGet3","oGet4","oGet5","oGet6","oGet7","oGet8","oGet9","oGet10","oPanel2","oSay11","oSay12")
	SetPrvt("oCBox2","oGet11","oGet12","oGet13","oBtn1","oBtn2","oBrw1")

	/**** TT ***/

	aAdd(aMKB,{"OK"    , "C", 02, 0})
	aAdd(aMKB,{"CODRES","C",TamSX3("NJB_CODRES")[1],0})
	aAdd(aMKB,{"DATRES","D",TamSX3("NJB_DATRES")[1],0})
	aAdd(aMKB,{"CODCTR","C",TamSX3("NJB_CODCTR")[1],0})
	aAdd(aMKB,{"CODROM","C",TamSX3("NJB_CODROM")[1],0})
	aAdd(aMKB,{"TABELA","C",TamSX3("NJB_TABELA")[1],0})
	aAdd(aMKB,{"QTDTOT","N",TamSX3("NJB_QTDTOT")[1],0})
	aAdd(aMKB,{"QTDCRE","N",TamSX3("NJB_QTDCRE")[1],0})
	aAdd(aMKB,{"PERRET","N",TamSX3("NJB_PERRET")[1],2})
	aAdd(aMKB,{"QTDPRO","N",TamSX3("NJB_QTDPRO")[1],0})
	aAdd(aMKB,{"UM1PRO","C",TamSX3("NJB_UM1PRO")[1],0})

	/**** Array de Campos Apresentados ***/
	aAdd(aCampos,{"OK"    ,NIL,""      , ""})
	aAdd(aCampos,{"CODRES",NIL,STR0002 ,"@!"})
	aAdd(aCampos,{"DATRES",NIL,STR0003 ,""})
	aAdd(aCampos,{"CODCTR",NIL,STR0004 ,"@!"})
	aAdd(aCampos,{"CODROM",NIL,STR0006 ,"@!"})
	aAdd(aCampos,{"TABELA",NIL,STR0007 ,"@!"})
	aAdd(aCampos,{"QTDTOT",NIL,STR0008 ,"@E 999,999,999.99"})
	aAdd(aCampos,{"QTDCRE",NIL,STR0009 ,"@E 999,999,999.99"})
	aAdd(aCampos,{"PERRET",NIL,STR0010 ,"@E 99.99"})
	aAdd(aCampos,{"QTDPRO",NIL,STR0011 ,"@E 999,999,999.99"})
	aAdd(aCampos,{"UM1PRO",NIL,STR0012 ,"@!"})

	cAliMKB := GetNextAlias() 
	oAliasNF := AGRCRTPTB(cAliMKB, {aMKB, {{"","CODRES"}, {"","OK"}} })

	OGA200APER()

	//SE LOJA FOR PREENCHIDO
	If !Empty(MV_PAR02)	   
		dbSelectArea('NJ0')
		dbSetOrder(1)
		If dbSeek(xFilial('NJ0') + MV_PAR01 + MV_PAR02)
			cNome  := NJ0->( NJ0_NOME )
			cNomLJ := NJ0->( NJ0_NOMLOJ )
		Endif
	Else
		//FUNCAO CRIADA PARA TRATAR A BUSCA DE TODAS AS ENTIDADES
		//COM O MESMO CODIGO E LOJAS DIFERENTES
		cNome := OGA200VENT()	
	EndIf		
	
	dbSelectArea('NJ2')
	dbSetOrder(1)
	If dbSeek(xFilial('NJ2') + MV_PAR03 )
		cDesTRes := NJ2->( NJ2_DESCRI )
	Endif

	dbSelectArea('SB1')
	dbSetOrder(1)
	If dbSeek(xFilial('SB1') + MV_PAR04)
		cDesPro := SB1->( B1_DESC )
	Endif

	oDlg1      := MSDialog():New( 091,232,549,1200,STR0001,,,.F.,,,,,,.T.,,,.T. )

	oPanelPai       := TPanel():New( 001,001,,oDlg1,,.F.,.F.,,,464,125,.F.,.F. )
	oPanelPai:Align := CONTROL_ALIGN_ALLCLIENT

	oPanel1         := TPanel():New( 001,001,,oPanelPai,,.F.,.F.,,,464,060,.F.,.F. )
	oPanel1:Align   := CONTROL_ALIGN_TOP
	
//Labels campos tela acima browse
	oSay1      := TSay():New( 008,028,{||STR0015},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,024,008)
	oSay2      := TSay():New( 020,028,{||STR0017},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,020,008)
	oSay3      := TSay():New( 008,104,{||STR0016},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,020,008)
	oSay4      := TSay():New( 020,104,{||STR0018},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,020,008)
	oSay5      := TSay():New( 008,212,{||STR0019},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,024,008)
	oSay6      := TSay():New( 020,212,{||STR0021},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,024,008)
	oSay7      := TSay():New( 008,292,{||STR0020},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,024,008)
	oSay8      := TSay():New( 020,292,{||STR0022},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,024,008)
	oSay9      := TSay():New( 036,024,{||STR0023},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,024,008)
	oSay10     := TSay():New( 036,204,{||STR0024},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)

//campos acima browse
	oGet1      := TGet():New( 008,052,bSetGet(MV_PAR01),oPanel1,044,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.t.,.F.,"","",,)
	oGet2      := TGet():New( 020,052,bSetGet(MV_PAR02),oPanel1,044,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.t.,.F.,"","",,)
	oGet3      := TGet():New( 008,124,bSetGet( cNome ),oPanel1,076,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.t.,.F.,"","",,)
	oGet4      := TGet():New( 020,124,bSetGet( cNomLJ ),oPanel1,076,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.t.,.F.,"","",,)
	oGet5      := TGet():New( 008,236,bSetGet(MV_PAR03),oPanel1,032,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.t.,.F.,"","",,)
	oGet6      := TGet():New( 020,236,bSetGet(MV_PAR04),oPanel1,048,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.t.,.F.,"","",,)
	oGet7      := TGet():New( 008,316,bSetGet(cDesTRes),oPanel1,140,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.t.,.F.,"","",,)
	oGet8      := TGet():New( 020,316,bSetGet(cDesPro),oPanel1,140,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.t.,.F.,"","",,)

//Observação e Qtde Credito
	oGet9      := TGet():New( 036,052,{ |u| If( PCount() > 0, cObs := u, cObs ) },oPanel1,148,008,'@!',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,,.F.,"","cObs",,)
	oGet10     := TGet():New( 036,236,bSetGet(nQtde),oPanel1,060,008,'@E 999,999,999.99',{|| OGA200AFIFO(.F.)},CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,,.F.,"","",,)


	oPanel2       := TPanel():New( 0200,0200,,oPanelPai,,.F.,.F.,,,464,090,.F.,.F. )
	oPanel2:Align := CONTROL_ALIGN_ALLCLIENT
	dbSelectArea(cAliMKB)
	dbSetOrder(01)
	dbGoTop()
	oMark := MsSelect():New(cAliMKB,"OK",,aCampos,,@cMarca,{008,024,50,100},,,oPanel2)
	oMark:oBrowse:cToolTip := STR0026 //"Reservas"
	oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oMark:oBrowse:bLDblClick := {|| OGA200ACLK()}

//----- Painel lateral do browse de documentos relacionados, para adicionar botoes -----//
	oPnlBtn1:=TPanel():New(50,20,,oPanel2,,,,,,15,15,.F.,.F.)
	oPnlBtn1:Align := CONTROL_ALIGN_LEFT

//------ Botao para Filtro das reservas -----//			
	oBtnFiltro			   := TBtnBmp():NewBar("brw_filtro","brw_filtro",,,,{|| OGA200APER()},,oPnlBtn1,,,"",,,,,"")
	oBtnFiltro:cToolTip := STR0027 //"Filtrar"
	oBtnFiltro:Align    := CONTROL_ALIGN_TOP

//Botão para selecionar todas as reservas
	oBtnChk := TBtnBmp():NewBar("CHECKED","CHECKED",,,,{||OGA200ACHK(1)},,oPnlBtn1,,,"",,,,,"")
	oBtnChk:cToolTip := STR0028
	oBtnChk:Align    := CONTROL_ALIGN_TOP

//Botão para desselecionar todas as entidades
	oBtnDChk := TBtnBmp():NewBar("UNCHECKED","UNCHECKED",,,,{||OGA200ACHK(2)},,oPnlBtn1,,,"",,,,,"")
	oBtnDChk:cToolTip := STR0029
	oBtnDChk:Align    := CONTROL_ALIGN_TOP

	oPanel3       := TPanel():New( 291,291,,oPanelPai,,.F.,.F.,,,464,020,.F.,.F. )
	oPanel3:Align := CONTROL_ALIGN_BOTTOM
	oSay11        := TSay():New( 006,065,{||STR0030},oPanel3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,036,008)
	oSay13        := TSay():New( 006,176,{||STR0031},oPanel3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,040,008)
	oSay12        := TSay():New( 006,285,{||STR0032},oPanel3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,044,008)
	oGet11        := TGet():New( 004,100,bSetGet(nQtdRom) ,oPanel3,060,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","",,)
	oGet13        := TGet():New( 004,215,bSetGet(nQtdCred),oPanel3,060,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","",,)
	oGet12        := TGet():New( 004,330,bSetGet(nQtdRes) ,oPanel3,060,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","",,)

	OGA200ACHK(1)

	ACTIVATE MSDIALOG oDlg1 ON INIT EnchoiceBar(ODlg1,{||If(OGA200AOK(),ODlg1:End(),NIL)},;
		{||ODlg1:End()},,aNewButton) CENTERED
				
    //Elimina a tabela temporária, se houver
    AGRDLTPTB(oArqTemp)
    				
Return

/** {Protheus.doc} OGA200ACHK
Função para marcar/desmarcar todos

@param: 	Nil
@author: 	Bruna Rocio
@since: 	07/11/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function OGA200ACHK(nOp)
	
	If nOp == 2
		nQtdRom  := 0
		nQtdRes  := 0
		nQtdCred := 0
		OGA200AUNSEL()
	Else
		nQtdRom := 0
		nQtdRes := 0
		nQtdCred := 0
		OGA200ATSEL()
	Endif
	
	DbSelectArea(cAliMKB)
	(cAliMKB)->( DbGoTop() )

	oMark:oBrowse:Refresh()

Return

/** {Protheus.doc} OGA200ACLK
Função chamada no evento de duplo click para marcar/desmarcar 

@param: 	Nil
@author: 	Bruna Rocio
@since: 	07/11/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/

Static Function OGA200ACLK( )
	
	If !(cAliMKB)->( Eof() )
			
		dbSelectArea('NJB')
		dbSetOrder(1)
		If dbSeek( xFilial('NJB') +  (cAliMKB)->CODRES)
	
			RecLock(cAliMKB, .F.)
			(cAliMKB)->OK := If(IsMark("OK",cMarca), " ", cMarca)
			
			If (cAliMKB)->OK != cMarca
				(cAliMKB)->QTDCRE := 0
				(cAliMKB)->QTDPRO := ((NJB->NJB_QTDTOT - NJB->NJB_QTDFIN) * (NJB->NJB_PERRET / 100))
			Endif
			
			MsUnlock(cAliMKB)
		Endif
	EndIf
	
	OGA200AFIFO(.T.)
			
	DbSelectArea(cAliMKB)
	(cAliMKB)->( DbGoTop() )
		
	oMark:oBrowse:Refresh()
	
	oGet11:CtrlRefresh()
	oGet12:CtrlRefresh()
	oGet13:CtrlRefresh()
		
Return

/** {Protheus.doc} OGA200
Rotina para avaliação

@param: 	Nil
@author: 	Bruna Rocio
@since: 	07/11/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function OGA200APER()
	Local lRetorno := .t.

	If Pergunte(cPergunta, .t.)
	
		OGA200AFil()
	
	Endif

Return ( lRetorno )

/** {Protheus.doc} OGA200
Rotina que faz o filtro dos dados para avaliação

@param: 	Nil
@author: 	Bruna Rocio
@since: 	07/11/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function OGA200AFil()
	Local cQuery   := ""
	
	dbSelectArea(cAliMKB)
	ZAP

	cQuery := "SELECT '  ' OK, NJB.NJB_CODRES CODRES, NJB.NJB_DATRES DATRES, "
	cQuery +=       " NJB.NJB_CODCTR CODCTR, NJB.NJB_CODROM CODROM, NJB.NJB_TABELA TABELA, "
	cQuery +=       " NJB.NJB_QTDTOT QTDTOT, NJB.NJB_QTDCRE QTDCRE, NJB.NJB_PERRET PERRET, "
	cQuery +=       " NJB.NJB_QTDPRO QTDPRO, NJB.NJB_UM1PRO UM1PRO"
	cQuery +=  "FROM" + RetSqlName("NJB") + " NJB  "
	cQuery += " WHERE NJB.NJB_FILIAL = '" + xFilial( 'NJB' ) + "'"  
	cQuery +=   " AND NJB.NJB_CODENT = '" + MV_PAR01 + "'"
	if !Empty(MV_PAR02)
		cQuery += " AND NJB.NJB_LOJENT = '"   + MV_PAR02  + "'"
	endif
	cQuery += " AND NJB.NJB_TIPRES = '"   + MV_PAR03  + "'"
	cQuery += " AND NJB.NJB_CODPRO = '"   + MV_PAR04  + "'"
	cQuery += " AND NJB.NJB_AVALIA = '0' "
	cQuery += " AND NJB.D_E_L_E_T_ = ' ' "
			
	MsgRun(STR0025,STR0026,{||SqlToTrb(cQuery, aMKB, cAliMKB)})
	
	dbSelectArea(cAliMKB)
	dbGoTOp()
		
	If Type("oMark") <> "U"
		oMark:oBrowse:Refresh()
		nQtdRom := 0
		nQtdRes := 0
		nQtdCred := 0
		OGA200ACHK(1)
	EndIf
Return

/** {Protheus.doc} OGA200AOK
Função de gravação da avaliação das reservas

@param: 	Nil
@author: 	Bruna Rocio
@since: 	18/11/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/

Function OGA200AOK()
	Local aTmpArea := (cAliMKB)->( GetArea() )
	Local nQtdAnt   := 0
	
	dbSelectArea(cAliMKB)
	(cAliMKB)->( dbSetOrder(2) )
	(cAliMKB)->( dbSeek(cMarca) )
	While !(cAliMKB)->( Eof() ) .And. (cAliMKB)->OK == cMarca
		
		//Caso (NJB_QTDTOT - NJB_QTDCRE - NJB_QTDFIN) <= 0 então liberar a reserva automaticamente:  
		
		dbSelectArea('NJB')
		dbSetOrder(1)
		If dbSeek( xFilial('NJB') + (cAliMKB)->CODRES)
			RecLock('NJB',.f.)
			nQtdAnt         := NJB->NJB_QTDPRO
			NJB->NJB_QTDPRO := (cAliMKB)->QTDPRO
			NJB->NJB_OBSLIB := cObs
			NJB->NJB_AVALIA := "1" //Avaliado
			NJB->NJB_QTDCRE := (cAliMKB)->QTDCRE
			
			If (NJB->NJB_QTDTOT - NJB->NJB_QTDCRE - NJB->NJB_QTDFIN) <= 0
				NJB->NJB_LIBERA := "2" //Crédito
				NJB->NJB_STATUS := "2" //Liberado
				NJB->NJB_DATLIB := dDatabase
			Endif
			
			msUnlock('NJB')
			
			OGA200ACTR( NJB->NJB_CODCTR, nQtdAnt, NJB->NJB_QTDPRO)
							
			NJB->( dbSkip())
		Endif
					
		dbSelectArea(cAliMKB)
		(cAliMKB)->( dbSkip() )
	EndDo
	
	oMark:oBrowse:Refresh()
	
	RestArea(aTmpArea)
	
	OGA200AFil()
	
Return .T.

/** {Protheus.doc} OGA200AFIFO
Função chamada no evento de duplo click para marcar/desmarcar 

@param: 	Nil
@author: 	Bruna Rocio
@since: 	18/11/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/

Function OGA200AFIFO(lCkSel)
	Local aTmpArea  := (cAliMKB)->( GetArea() )
	Local nControle := nQtde
	Local nCredito  := 0
	
	nQtdRom  := 0
	nQtdRes  := 0
	nQtdCred := 0
	
	If nControle > 0
	
		dbSelectArea(cAliMKB)
		(cAliMKB)->( dbGoTop() )
		
		if !lCkSel		/*Faz todos os registros*/
			While !(cAliMKB)->( Eof() )
				
				dbSelectArea('NJB')
				dbSetOrder(1)
				If dbSeek( xFilial('NJB') +  (cAliMKB)->CODRES)
						
					RecLock(cAliMKB,.f.)
					If nControle > 0
						If nControle > NJB->NJB_QTDTOT
							nCredito          := NJB->NJB_QTDTOT
							(cAliMKB)->QTDCRE := nCredito
							(cAliMKB)->QTDPRO := ((NJB->NJB_QTDTOT - nCredito - NJB->NJB_QTDFIN) * (NJB->NJB_PERRET / 100))
							nControle         -= nCredito
							(cAliMKB)->OK     := cMarca
						Else
							nCredito          := nControle
							(cAliMKB)->QTDPRO := ((NJB->NJB_QTDTOT - nCredito - NJB->NJB_QTDFIN) * (NJB->NJB_PERRET / 100))
							nControle         := 0
							(cAliMKB)->QTDCRE := nCredito
							(cAliMKB)->OK     := cMarca
						Endif
					else
						(cAliMKB)->QTDCRE := 0
						(cAliMKB)->QTDPRO := ((NJB->NJB_QTDTOT - NJB->NJB_QTDFIN) * (NJB->NJB_PERRET / 100))
						(cAliMKB)->OK     := cMarca
					Endif
					msUnLock(cAliMKB)
											
					NJB->( dbSkip())
				Endif
				dbSelectArea(cAliMKB)
				
				(cAliMKB)->( dbSkip() )
			EndDo
		Else /*Só faz os marcados*/
			While !(cAliMKB)->( Eof() )
				if (cAliMKB)->OK == cMarca
					If nControle > 0
						dbSelectArea('NJB')
						dbSetOrder(1)
						If dbSeek( xFilial('NJB') +  (cAliMKB)->CODRES)
							
							RecLock(cAliMKB,.f.)
							If nControle > NJB->NJB_QTDTOT
								nCredito          := NJB->NJB_QTDTOT
								(cAliMKB)->QTDCRE := nCredito
								(cAliMKB)->QTDPRO := ((NJB->NJB_QTDTOT - nCredito - NJB->NJB_QTDFIN) * (NJB->NJB_PERRET / 100))
								nControle         -= nCredito
							Else
								nCredito          := nControle
								(cAliMKB)->QTDPRO := ((NJB->NJB_QTDTOT - nCredito - NJB->NJB_QTDFIN) * (NJB->NJB_PERRET / 100))
								nControle         := 0
								(cAliMKB)->QTDCRE := nCredito
							Endif
							msUnLock(cAliMKB)
												
							NJB->( dbSkip())
						Endif
						dbSelectArea(cAliMKB)
					Endif
				endif
				(cAliMKB)->( dbSkip() )
			EndDo
		endif
			
	Else
		dbSelectArea(cAliMKB)
		(cAliMKB)->( dbGoTop() )
		While !(cAliMKB)->( Eof() )
			
			dbSelectArea('NJB')
			dbSetOrder(1)
			If dbSeek( xFilial('NJB') +  (cAliMKB)->CODRES)
				RecLock(cAliMKB,.f.)
				(cAliMKB)->QTDPRO := ((NJB->NJB_QTDTOT - NJB->NJB_QTDFIN) * (NJB->NJB_PERRET / 100))
				(cAliMKB)->QTDCRE := 0
				msUnLock(cAliMKB)
			Endif
					
			dbSelectArea(cAliMKB)
			(cAliMKB)->( dbSkip() )
		EndDo
	Endif
	
	OGA200TOT()
		
	DbSelectArea(cAliMKB)
	(cAliMKB)->( DbGoTop() )
				
	oMark:oBrowse:Refresh()
	
	oGet11:CtrlRefresh()
	oGet12:CtrlRefresh()
	oGet13:CtrlRefresh()
			
	RestArea(aTmpArea)
	
Return .T.

/** {Protheus.doc} OGA200ACTR
Função chamada para atualizar quantidade reserva no contrato

@param: 	Nil
@author: 	Bruna Rocio
@since: 	18/11/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/

Function OGA200ACTR( cContrato, qtdSub, qtdSoma )
	Local aTmpArea := (cAliMKB)->( GetArea() )
	Local lRetorno := .t.
	
	dbSelectArea('NJR')
	dbSetOrder(1)
	If dbSeek( xFilial('NJR') + cContrato )
	
		RecLock('NJR', .f.)
							
		If (NJR->NJR_QTDRES - qtdSub) >= 0
			NJR->NJR_QTDRES -= qtdSub
		Else
			NJR->NJR_QTDRES := 0
		Endif
		
		NJR->NJR_QTDRES += qtdSoma
		
		msUnLock('NJR')
	Endif

	RestArea(aTmpArea)

Return lRetorno

/** {Protheus.doc} OGA200AUNSEL
Função chamada para verificar a existência de registro selecionado 

@param: 	Nil
@author: 	Bruna Rocio
@since: 	24/11/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function OGA200AUNSEL()
	
	dbSelectArea(cAliMKB)
	(cAliMKB)->( dbGoTop() )
	While !(cAliMKB)->( Eof() )
		
		dbSelectArea('NJB')
		dbSetOrder(1)
		If dbSeek( xFilial('NJB') +  (cAliMKB)->CODRES)
			RecLock(cAliMKB,.f.)
			(cAliMKB)->OK := ' '
			(cAliMKB)->QTDPRO := ((NJB->NJB_QTDTOT - NJB->NJB_QTDFIN) * (NJB->NJB_PERRET / 100))
			(cAliMKB)->QTDCRE := 0
			msUnLock(cAliMKB)
		Endif
				
		dbSelectArea(cAliMKB)
		(cAliMKB)->( dbSkip() )
	EndDo
Return

/** {Protheus.doc} OGA200ATSEL
Função chamada para verificar a existência de registro selecionado 

@param: 	Nil
@author: 	Bruna Rocio
@since: 	24/11/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function OGA200ATSEL()
	
	dbSelectArea(cAliMKB)
	(cAliMKB)->( dbGoTop() )
	While !(cAliMKB)->( Eof() )
		
		dbSelectArea('NJB')
		dbSetOrder(1)
		If dbSeek( xFilial('NJB') +  (cAliMKB)->CODRES)
			RecLock(cAliMKB,.f.)
			(cAliMKB)->OK := cMarca
			nQtdRom 	+= (cAliMKB)->QTDTOT
			nQtdRes 	+= (cAliMKB)->QTDPRO
			nQtdCred   += (cAliMKB)->QTDCRE
			msUnLock(cAliMKB)
		Endif
				
		dbSelectArea(cAliMKB)
		(cAliMKB)->( dbSkip() )
	EndDo
Return

/** {Protheus.doc} OGA200TOT
Função chamada para Calcular Totais

@param: 	Nil
@author: 	Bruna Rocio
@since: 	24/11/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function OGA200TOT()
	
	nQtdRom  := 0
	nQtdRes  := 0
	nQtdCred := 0
	
	dbSelectArea(cAliMKB)
	(cAliMKB)->( dbGoTop() )
	While !(cAliMKB)->( Eof() )
		if  (cAliMKB)->OK == cMarca
			nQtdRom 	+= (cAliMKB)->QTDTOT
			nQtdRes 	+= (cAliMKB)->QTDPRO
			nQtdCred   += (cAliMKB)->QTDCRE
		endif
		(cAliMKB)->( dbSkip() )
	EndDo
Return

/** {Protheus.doc} OGA200
Rotina para avaliação entidades

@param: 	Nil
@author: 	Equipe Agroindustria
@since: 	23/02/2016
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function OGA200VENT()
	Local cCodigo	:= MV_PAR01
	Local cQuery	:= ""
	
	Private cAliasNJB := GetNextAlias()

	cQuery := ""
	cQuery += " SELECT DISTINCT NJ0_NOME"
	cQuery +=   " FROM " + RetSqlName('NJ0')+ " NJ0 "
	cQuery +=  " WHERE NJ0.D_E_L_E_T_  = '' "
	cQuery +=    " AND NJ0.NJ0_FILIAL = '" + xFilial( 'NJ0' ) + "'"
	cQuery +=    " AND NJ0.NJ0_CODENT  = '" + cCodigo  + "' "
	cQuery := ChangeQuery(cQuery)
	If select("cAliasNJB") <> 0
		cAliasNJB->( dbCloseArea() )
	EndIf
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasNJB,.T.,.T.)
	
	DbSelectArea( cAliasNJB )		
	(cAliasNJB)->( dbGoTop() )
	
	cNome := (cAliasNJB)->NJ0_NOME

Return(cNome)
